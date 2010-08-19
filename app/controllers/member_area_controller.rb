class MemberAreaController < ApplicationController
  include CustomerAuthentication
  include ActiveMerchant::Utils
  include ActionView::Helpers::NumberHelper
  before_filter :customer_login_required
  before_filter :hide_pre_form

  layout 'flobridge'

  if RAILS_ENV == 'production'
    ssl_required :make_payment
  end


  in_place_edit_for :scheduled_payment, :amount
  in_place_edit_for :scheduled_payment, :formatted_amount
  in_place_edit_for :scheduled_payment, :principal
  
  def index
#    @hide_pre_form = true
    @loan = current_customer.loans.first
  end

  def credit_limit
  end

  def tila
    @loan = current_customer.loans.first # loans association is reverse chrono so .first will be most recent
  end

  def tila_for_loan
    @loan = Loan.find(params[:id])
    render :action => :tila
  end

  def history
  end

  def loan_activity
    @loan_transactions = LoanTransaction.find(:all, :conditions => ["loan_id = ?",params[:id]], :order => 'created_at')
    render :partial => 'member_area/loan_activity', :layout => false
  end

  def new_loan
    
    @customer = current_customer

    current_customer.loans.each do |loan|
      logger.info "loan #{loan.id} state: #{loan.aasm_state}"
      if ['pending_signature','underwriting','active','collections','garnishments'].include? loan.aasm_state
        redirect_to member_area_new_loan_blocked_path
        return
      end
    end
    
    @bank_info=@customer.bank_accounts.funding_accounts.first
    
    if request.get?
      return
    end
    
    #Update Customer Information
    
    @customer = Customer.find_by_id(current_customer.id)
    @customer.update_attributes(params[:customer])
    @customer.combine_multi_part_fields

    @customer.save
    
    @checkbankAcc = BankAccount.find_by_bank_account_number_and_bank_aba_number_and_bank_name_and_customer_id(params[:customer][:bank_account_number], params[:customer][:bank_aba_number],params[:customer][:bank_name],params[:customer_id])
    
   
    if @checkbankAcc !=nil
      
      #Update Bank Account Information
      
      @bankAcc = @customer.bank_accounts.funding_accounts.first
      @bankAcc.update_attributes(:bank_name => params[:customer][:bank_name],:bank_account_type => params[:customer][:bank_account_type],:bank_aba_number => params[:customer][:bank_aba_number],:bank_account_number => params[:customer][:bank_account_number],:months_at_bank => params[:customer][:months_at_bank])
    
    else
     
      @bank_info = BankAccount.new
      @bank_info.customer_id=params[:customer_id]
      @bank_info.bank_name=params[:customer][:bank_name]
      @bank_info.bank_account_type=params[:customer][:bank_account_type]
      @bank_info.bank_aba_number=params[:customer][:bank_aba_number]
      @bank_info.bank_account_number=params[:customer][:bank_account_number]
      @bank_info.months_at_bank=params[:customer][:months_at_bank]
      @bank_info.bank_direct_deposit=false
      @bank_info.save
    end
    
    #Create New Loan
    
    if params[:customer][:requested_loan_amount] != ''
      @loan = Loan.new
      @loan.requested_loan_amount=params[:customer][:requested_loan_amount]
      @loan.aasm_state="pending_signature"
      @loan.customer_id=current_customer.id
      @loan.save
      render :action => :tila
    end
  end

  def new_loan_blocked
  end
  

  def make_payment
    
    @loan = current_customer.loans.first
    
    #
    # Development code
    #
    # TODO - uncomment restrition to development only before official launch
    if RAILS_ENV == 'development'
      @loan.force_to_active
    end


    customer = @loan.customer
    unless @loan.aasm_state == 'active'
      render :partial => 'member_area/no_active_loan', :layout => true
      return
    end
    if !@loan.scheduled_payments.ach_submitted.empty?
      flash[:notice] = 'There is currently an ACH draft in process for your loan.  No new payments may be scheduled until the transaction is complete.'
      redirect_to member_area_scheduled_payments_path
      return
    end
    
    if @loan.total_principal_of_scheduled_payments >= @loan.principal_owed
      flash[:notice] = "Existing Scheduled Payments Are Sufficient to Pay Off Loan.  If you want to change the payment schedule, cancel an existing scheduled payment first."
      redirect_to member_area_scheduled_payments_path
      return
    end

    @scheduled_payment = ScheduledPayment.new(params[:scheduled_payment])
    @scheduled_payment.loan_id = @loan.id
    @scheduled_payment.customer_id = session[:customer_id]
    sp = params[:scheduled_payment]
    
    if request.get?
      setup_make_payment_page
      return
    end

    # POST
    @scheduled_payment.allocate_payment

    if @scheduled_payment.payment_account_id.nil?
      # Customer wants to add a new bank account or credit card
      if params[:payment_method] == 'bank_account'
        # Check for duplicate
        customer.payment_accounts.bank_accounts.each do |payment_account|
          if sp[:bank_account_number] == payment_account.account.bank_account_number
            @scheduled_payment.errors.add_to_base('This account is already in your Bank Account list.')
            setup_make_payment_page
            return
          end
        end

        bank_account = BankAccount.new(
          :customer_id => current_customer.id,
          :bank_name => @scheduled_payment.bank_name,
          :bank_account_type => @scheduled_payment.bank_account_type,
          :bank_aba_number => @scheduled_payment.bank_aba_number,
          :bank_account_number => @scheduled_payment.bank_account_number,
          :months_at_bank => 0,
          :bank_direct_deposit => false
        )
        if bank_account.valid?
          bank_account.save!
          payment_account = PaymentAccount.create!(:customer_id => current_customer.id, :account_id => bank_account.id, :account_type => BankAccount.to_s)
          @scheduled_payment.payment_account = payment_account
        else
          @scheduled_payment.errors.add_to_base('Invalid or Duplicate Bank Account')
          setup_make_payment_page
          return
        end
      end
      if params[:payment_method] == 'credit_card'
        # Check for duplicate
        customer.payment_accounts.credit_cards.each do |payment_account|
          logger.info "payment_account.account type: #{payment_account.account.class.to_s}"
          if sp[:card_number][-4,4] == payment_account.account.last_4_digits
            @scheduled_payment.errors.add_to_base('This card is already in your Credit Card list.')
            setup_make_payment_page
            return
          end
        end

        credit_card = CreditCard.new(
          :last_4_digits => sp[:card_number][-4,4],
          :card_type => 'Visa',
          :card_number => sp[:card_number],
          :expires_month => sp[:expires_month],
          :expires_year => sp[:expires_year],
          :cvv => sp[:cvv],
          :first_name => sp[:first_name],
          :last_name => sp[:last_name],
          :billing_address => sp[:card_billing_address],
          :billing_zip => sp[:card_billing_zip]
        )
        if credit_card.valid?
          credit_card.save!
        else
          @scheduled_payment.errors.add_to_base('Invalid Credit Card')
          setup_make_payment_page
          return
        end

        begin
          payment_account = PaymentAccount.new(
            :customer_id => current_customer.id,
            :account_id => credit_card.id,
            :account_type => CreditCard.to_s,
            :create_authnet_customer_profile => true,
            :create_authnet_payment_profile => true,
            :credit_card => credit_card
          )

          payment_account.save!
          @scheduled_payment.payment_account = payment_account
        rescue Exception => e
          logger.info "Controller caught: #{e.inspect}"
          raise e
        end
      end
    end

    # If payment method is credit card and payment date is today, process immediately without scheduling
    date_parts = sp[:draft_date].split('/')
    month = date_parts[0].to_i
    day = date_parts[1].to_i
    year = date_parts[2].to_i
    draft_date = Date.civil(year,month,day)
    if params[:payment_method] == 'credit_card' && draft_date == Date.today
      cim_gateway = get_authnet_cim_payment_gateway
      transaction_hash = {
          :type => :auth_capture,
          :amount => @scheduled_payment.amount,
          :customer_profile_id => customer.authnet_customer_profile_id,
          :customer_payment_profile_id => @scheduled_payment.payment_account.authnet_payment_profile_id
        }
      response = nil
      error_message = nil
      begin
        response = cim_gateway.create_customer_profile_transaction(
          :transaction => transaction_hash
        )
      rescue Exception => e
        error_message = e.message
      rescue => e
        error_message = e
      end
      logger.info "response to create_customer_profile_transaction: #{response.inspect}"

      if response.nil? || !response.success?
        if response
          @scheduled_payment.errors.add_to_base("DECLINED: #{response.message}")
        else
          @scheduled_payment.errors.add_to_base("ERROR: #{error_message}")
        end
        setup_make_payment_page
        return
      end

      # Approved.  Apply payment to loan
      Loan.transaction do
        LoanTransaction.create!(
          :loan => @loan,
          :tran_type => LoanTransaction::PAYMENT,
          :total => @scheduled_payment.amount * -1,
          :principal => @scheduled_payment.principal * -1,
          :interest => @scheduled_payment.interest * -1,
          :fees => @scheduled_payment.fees * -1,
          :payment_account => @scheduled_payment.payment_account
        )
        @loan.update_amounts_owed
      end
      flash[:notice] = 'Credit Card Payment Approved'
      redirect_to :action => :history
      return
    end

    unless @scheduled_payment.valid?
      setup_make_payment_page
      return
    end
    
    @scheduled_payment.save!
    redirect_to member_area_scheduled_payments_path
  end

  def cancel_scheduled_payment
    scheduled_payment = ScheduledPayment.find(params[:id])

    ScheduledPayment.transaction do
      if scheduled_payment.due_date_before_extension
        loan = scheduled_payment.loan
        loan.due_date = scheduled_payment.due_date_before_extension
        loan.save
        ScheduledPayment.destroy_all(["created_at > ? and due_date_before_extension is not null",scheduled_payment.created_at])
      end
      scheduled_payment.destroy
    end
    flash[:notice] = 'Your Scheduled Payment Has Been Cancelled.  Check Your New Due Date.'
    redirect_to member_area_scheduled_payments_path
  end

  def scheduled_payments
    if current_customer.loans.active.empty?
      render :partial => 'member_area/no_active_loan', :layout => true
      return
    end
    @loan = current_customer.loans.active.first
  end

  def loan_interest_on_date
    loan = Loan.find(params[:id])
    date = Date.parse(params[:date])
    interest = loan.interest_on(date)
    formatted_interest = sprintf("%4.2f",interest)
    render :text => formatted_interest
  end

  def edit_principal_form
    @scheduled_payment = ScheduledPayment.find(params[:id])
    render :partial => 'member_area/edit_principal_form', :layout => false
  end

  def edit_new_scheduled_payment_amount_form
    render :partial => 'member_area/edit_new_scheduled_payment_amount_form'
  end

  def allocate_hypothetical_loan_payment
    loan = Loan.find(params[:id])
    a = loan.allocate_hypothetical_payment(params[:amount].to_f,Date.parse(params[:date]))
    render :text => sprintf("$%4.2f,$%4.2f,$%4.2f,$%4.2f",a[:total],a[:principal],a[:interest],a[:fees])
  end

  def set_payment_principal
    sp = ScheduledPayment.find(params[:id])
    sp.principal = params[:principal].strip
    saved = false
    if sp.valid?
      begin
        sp.save!
        saved = true
        sp.loan.recalculate_scheduled_payments
      rescue Exception => e
        logger.info "Exception: #{e.message}"
      rescue => e
        logger.info "Exception: #{e}"
      end
    end
    # Changing the principal of one payment will affect interest charges on subsequent payments
    sp.reload unless saved
    render :text => sprintf("$%4.2f,$%4.2f", sp.amount,sp.principal)
  end
  
  def extend_loan
    if current_customer.loans.active.length > 1
      raise Exception.new('More than one active loan')
    end
    @loan = current_customer.loans.active.first
    unless @loan
      render :partial => 'member_area/no_active_loan', :layout => true
      return
    end

    # Ensure not extending beyond 12 weeks from funding date
    extension_limit = @loan.funded_on+84
    if extension_limit < @loan.next_due_date
      render :partial => 'member_area/no_extension', :layout => true
      return
    end
    return if request.get?

    # POST
    @loan.extend_to_next_payday!

    flash[:notice] = 'Your Loan Has Been Extended'
    redirect_to member_area_home_path
  end

  def contact

    if request.post?
      email = params[:email]
      message = params[:message]
      if !email.blank? && !message.blank?
        begin
          Mailer.send_later :deliver_contact_flobridge,email,message
          flash.now[:notice] = "Thank you for your comments. We will respond shortly."
        rescue => e
          # Hoptoad Notify
        end
      else
        flash.now[:notice] = "Please fill out all required fields below."
      end
    end
  end

  private

  def hide_pre_form
    @hide_pre_form = true
  end

  def setup_make_payment_page
    if Date.today < @loan.due_date
      @max_date = @loan.due_date - 1
    else
      if Date.today == @loan.due_date
          @max_date = Date.today
      else
        @max_date = @loan.funded_on + 12.weeks
      end
    end
    @scheduled_payment.amount = @loan.total_owed
    @scheduled_payment.allocate_payment
  end
  
end
