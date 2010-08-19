class LoansController < ApplicationController
  include CustomerAuthentication
  include ActiveMerchant::Utils

  require 'tzinfo'
  include ActionView::Helpers::NumberHelper
  before_filter :login_required


  if RAILS_ENV == 'production'
    ssl_required :payment
  end

  # In-Place Editing methods
  #
  in_place_edit_for :loan_transaction, :check_number

  in_place_edit_for :loan, :amount
  in_place_edit_for :loan, :total_owed

  in_place_edit_for :loan_transaction, :total
  in_place_edit_for :loan_transaction, :amount
  in_place_edit_for :loan_transaction, :total_owed

  in_place_edit_for :scheduled_payment, :total_owed
  in_place_edit_for :scheduled_payment, :formatted_amount
  in_place_edit_for :scheduled_payment, :principal

  # Customer
  in_place_edit_for :customer, :first_name
  in_place_edit_for :customer, :last_name
  in_place_edit_for :customer, :gender, { :format => 'key_value', :values => ["Male:m", "Female:f"] }
  in_place_edit_for :customer, :email
  in_place_edit_for :customer, :birth_date, { :format => 'date' }
  in_place_edit_for :customer, :dl_number
  in_place_edit_for :customer, :dl_state, { :format => 'key_value', :values => Common::US_STATES.sort.map{|k,v|"#{k} - #{v}:#{k}"} }
  in_place_edit_for :customer, :military, { :format => 'key_value', :values => ["Yes:true", "No:false"] }
  in_place_edit_for :customer, :home_phone, { :format => "phone" }
  in_place_edit_for :customer, :cell_phone, { :format => "phone" }
  in_place_edit_for :customer, :fax, { :format => "phone" }
  in_place_edit_for :customer, :address
  in_place_edit_for :customer, :city
  in_place_edit_for :customer, :state, { :format => 'key_value', :values => Common::US_STATES.sort.map{|k,v|"#{k} - #{v}:#{k}"} }
  in_place_edit_for :customer, :zip
  in_place_edit_for :customer, :monthly_income, { :format => 'currency' }
  in_place_edit_for :customer, :income_source, { :format => 'key_value', :values => ["Employment:EMPLOYMENT", "Benefits:BENEFITS"]}
  in_place_edit_for :customer, :pay_frequency, { :format => 'key_value', :values => ["Weekly:WEEKLY", "Bi-Weekly:BI_WEEKLY", "Twice Monthly:TWICE_MONTHLY", "Monthly:MONTHLY"]}
  in_place_edit_for :customer, :employer_name
  in_place_edit_for :customer, :occupation
  in_place_edit_for :customer, :months_employed
  in_place_edit_for :customer, :employer_address
  in_place_edit_for :customer, :employer_city
  in_place_edit_for :customer, :employer_state
  in_place_edit_for :customer, :employer_zip
  in_place_edit_for :customer, :employer_phone, { :format => "phone" }
  in_place_edit_for :customer, :employer_phone_ext
  in_place_edit_for :customer, :employer_fax, { :format => "phone" }
  in_place_edit_for :customer, :supervisor_name
  in_place_edit_for :customer, :supervisor_phone, { :format => "phone" }
  in_place_edit_for :customer, :supervisor_phone_ext
  in_place_edit_for :customer, :residence_type, { :format => 'key_value', :values => ["Rent:RENT", "Own:OWN"] }
  in_place_edit_for :customer, :monthly_residence_cost
  in_place_edit_for :customer, :months_at_address
  in_place_edit_for :customer, :landlord_name
  in_place_edit_for :customer, :landlord_phone, { :format => "phone" }
  in_place_edit_for :customer, :landlord_address
  in_place_edit_for :customer, :landlord_city
  in_place_edit_for :customer, :landlord_state, { :format => 'key_value', :values => Common::US_STATES.sort.map{|k,v|"#{k} - #{v}:#{k}"} }
  in_place_edit_for :customer, :landlord_zip
  in_place_edit_for :customer, :contact_by_mail
  in_place_edit_for :customer, :contact_by_email
  in_place_edit_for :customer, :contact_by_sms
  in_place_edit_for :customer, :reference_1_name
  in_place_edit_for :customer, :reference_1_phone, { :format => "phone" }
  in_place_edit_for :customer, :reference_1_address
  in_place_edit_for :customer, :reference_1_city
  in_place_edit_for :customer, :reference_1_state, { :format => 'key_value', :values => Common::US_STATES.sort.map{|k,v|"#{k} - #{v}:#{k}"} }
  in_place_edit_for :customer, :reference_1_zip
  in_place_edit_for :customer, :reference_1_relationship, { :format => 'key_value', :values => ["Co-Worker:COWORKER", "Friend:FRIEND", "Parent:PARENT", "Sibling:SIBLING", "Other:OTHER"]}
  in_place_edit_for :customer, :reference_2_name
  in_place_edit_for :customer, :reference_2_phone, { :format => "phone" }
  in_place_edit_for :customer, :reference_2_address
  in_place_edit_for :customer, :reference_2_city
  in_place_edit_for :customer, :reference_2_state, { :format => 'key_value', :values => Common::US_STATES.sort.map{|k,v|"#{k} - #{v}:#{k}"} }
  in_place_edit_for :customer, :reference_2_zip
  in_place_edit_for :customer, :reference_2_relationship, { :format => 'key_value', :values => ["Co-Worker:COWORKER", "Friend:FRIEND", "Parent:PARENT", "Sibling:SIBLING", "Other:OTHER"]}

  # Loan
  in_place_edit_for :bank_account, :bank_name
  in_place_edit_for :bank_account, :bank_account_type, { :format => 'key_value', :values => ["Checking:CHECKING", "Savings:SAVINGS"]}
  in_place_edit_for :bank_account, :months_at_bank
  in_place_edit_for :bank_account, :bank_address
  in_place_edit_for :bank_account, :bank_city
  in_place_edit_for :bank_account, :bank_state, { :format => 'key_value', :values => Common::US_STATES.sort.map{|k,v|"#{k} - #{v}:#{k}"} }
  in_place_edit_for :bank_account, :bank_zip
  in_place_edit_for :bank_account, :bank_phone, { :format => "phone" }
  in_place_edit_for :loan, :signature_page_loan_amount
  in_place_edit_for :loan, :garnishment_sub_status

  # Reminder
  in_place_edit_for :reminder, :remind_on
  in_place_edit_for :reminder, :comment

  def index
    if params[:filters]
      @filters = params[:filters].keys
    else
      if current_user.role == "collections"
        @filters = ['collections']
      else
        @filters = ['underwriting','no_reply', 'approved']
      end
    end
    if current_user.role == "collections"
      @loans = Loan.find(:all, :conditions => ["aasm_state in (?) && underwriter_id=?",@filters,current_user.id]).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC', :include => [:comments, :customer]
    else
      @loans = Loan.find(:all, :conditions => ["aasm_state in (?)", @filters]).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC', :include => [:comments, :customer]
    end
  end


  def show

    @loan = Loan.find(params[:id])
    customer = @loan.customer
    @local_time = @loan.customer.local_time()
    @next_scheduled_payment = @loan.scheduled_payments.first
    
    @loan_transaction = LoanTransaction.new(:loan_id => @loan.id)

    # Set up possible aasm_states to which the user can change the loan
    @aasm_state_options = []
    if current_user.role == 'administrator'
      case @loan.aasm_state
      when 'underwriting'
        @aasm_state_options = ['approved','denied']
      when 'active'
        @aasm_state_options = ['collections','recission_requested']
      when 'collections'
        @aasm_state_options = ['garnishments','paid_in_full','pending_write_off','written_off']
      when 'garnishments'
        @aasm_state_options = ['paid_in_full','pending_write_off','written_off']
      end
    end
    
    if @loan.verified_employment_with_employer == true && @loan.verified_personal == true &&  @loan.verified_financial == true &&  @loan.verified_tila == true
      @show_status='summary'
    elsif  @loan.verified_employment_with_employer == true && @loan.verified_personal == false &&  @loan.verified_financial == false &&  @loan.verified_tila == false
      @show_status='personal'
    elsif  @loan.verified_employment_with_employer == true && @loan.verified_personal == true &&  @loan.verified_financial == false &&  @loan.verified_tila == false
      @show_status='financial'
    elsif  @loan.verified_employment_with_employer == true && @loan.verified_personal == true &&  @loan.verified_financial == true &&  @loan.verified_tila == false
      @show_status='tila'
    else
      @show_status='employment'
    end
    
    @current_tab = params[:tab].blank? ? @show_status : params[:tab]
    @documents = Document.find(:all, :conditions => ['loan_id = ? and parent_id  is ?',@loan.id,nil])
    @customer = @loan.customer
    @bank_account = @customer.bank_accounts.funding_accounts.first
    @home_listings = @loan.customer.customer_phone_listings.find_all_by_phone(@loan.customer.home_phone)
    @work_listings = @loan.customer.customer_phone_listings.find_all_by_phone(@loan.customer.work_phone)
    @cell_listings = @loan.customer.customer_phone_listings.find_all_by_phone(@loan.customer.cell_phone)
    @employer_listings = @loan.customer.customer_phone_listings.find_all_by_phone(@loan.customer.employer_phone)
    @reference_1_listings = @loan.customer.customer_phone_listings.find_all_by_phone(@loan.customer.reference_1_phone)
    @reference_2_listings = @loan.customer.customer_phone_listings.find_all_by_phone(@loan.customer.reference_2_phone)
    @prior_instances_of_customer_with_discrepancies = []
    #unless @employer_listings.empty?
    customers_employed_by_same_company = Customer.find(:all, :conditions => ["employer_phone = ? and id <> ?",@loan.customer.employer_phone,@loan.customer_id])
    for prior_customer in customers_employed_by_same_company
      if prior_customer.first_name.downcase == @loan.customer.first_name.downcase && prior_customer.last_name.downcase == @loan.customer.last_name.downcase && prior_customer.state == @loan.customer.state
        # Appears to be the same person.
        if  prior_customer.home_phone != @loan.customer.home_phone ||
            prior_customer.address != @loan.customer.address ||
            prior_customer.zip != @loan.customer.zip ||
            prior_customer.birth_date != @loan.customer.birth_date ||
            prior_customer.gender != @loan.customer.gender ||
            prior_customer.ssn != @loan.customer.ssn ||
            prior_customer.dl_number != @loan.customer.dl_number ||
            prior_customer.dl_state != @loan.customer.dl_state ||
            prior_customer.residence_type != @loan.customer.residence_type ||
            prior_customer.supervisor_name != @loan.customer.supervisor_name ||
            prior_customer.supervisor_phone != @loan.customer.supervisor_phone
          @prior_instances_of_customer_with_discrepancies << prior_customer
        end
      end
    end
    #end
    begin
      @factor_trust = @loan.customer.factor_trust.application_response['ApplicationResponse']['ApplicationInfo']
    rescue
      @factor_trust = nil
    end

    today = Date.today
    year = today.year
    month = today.month
    day = today.day
    @can_be_rescinded = false
    today_5pm_mt_utc = TZInfo::Timezone.get('America/Denver').local_to_utc(DateTime.new(year,month,day,17,0,0))
    now_utc = Time.now.utc
    logger.info "today_5pm_mt: #{today_5pm_mt_utc.to_s(:rfc822)}  now_utc: #{now_utc.to_s(:rfc822)}"
    @can_be_rescinded = true if @loan.aasm_state == 'active' && now_utc < today_5pm_mt_utc
  end

  def loan_remark
    @remark = Loan.find(params[:id])
    @remark.remark = params[:remark_value]
    @remark.save
    render :text => "Remark was saved"
  end

  def my_loans
    case current_user.role
    when 'underwriter'
      @loans = underwriter_my_loans
      @role = current_user.role
    when 'collections'
      @loans = collection_my_loans
      @role = current_user.role
    when 'garnishments'
      @loans = garnishment_my_loans
      @role = current_user.role
    end
  end

  def payment_plans
    @loans = Loan.paginate(:conditions => ["aasm_state = 'payment_plan' and collections_agent_id = ?",current_user.id], :page => params[:page], :per_page => 20)
  end

  def garnishment_payment_plans
    @loans = Loan.paginate(:conditions => ["aasm_state = 'payment_plan' and garnishments_agent_id = ?",current_user.id], :page => params[:page], :per_page => 20)
  end

  def garnishment_paying
    @loans = Loan.paginate(:conditions => ["garnishment_sub_status = 'paying' and garnishments_agent_id = ?",current_user.id], :page => params[:page], :per_page => 20)
  end

  def garnishment_follow_up
    @loans = Loan.paginate(:conditions => ["garnishment_sub_status in (?) and garnishments_agent_id = ?",['court_order','skip_trace','release'],current_user.id], :page => params[:page], :per_page => 20)
  end
  
  def loan_activity
    @loan_transactions = LoanTransaction.find(:all, :conditions => ["loan_id = ?",params[:id]], :order => 'created_at desc')
    render :partial => 'loans/loan_activity', :layout => false
  end

  def tila
    @loan = Loan.find(params[:id])
    render :partial => "/includes/truth_in_lending_agreement", :locals => { :loan => @loan, :customer => @loan.customer, :ip_address => request.remote_ip, :current_user => current_user, :pdf => false }, :layout => 'loan_confirmation'
  end

  def employer_information
    @loan = Loan.find(params[:id])
    @customer = @loan.customer
    render :partial => 'loans/employer_information', :layout => false
  end

  def update_validation_status
    @loan = Loan.find(params[:id])
    new_status = params[:v]
    if params[:t] == "personal"
      @loan.update_attribute(:verified_personal, new_status)
     
    elsif params[:t] == "financial"
      @loan.update_attribute(:verified_financial, new_status)
     
    elsif params[:t] == "employment_with_customer"
      @loan.update_attribute(:verified_employment_with_customer, new_status)
      
    elsif params[:t] == "employment_with_employer"
      @loan.update_attribute(:verified_employment_with_employer, new_status)
    elsif params[:t] == "tila"
      @loan.update_attribute(:verified_tila, new_status)
    end
    @loan.logs << Log.new(:message => "#{current_user.full_name} updated #{params[:t]} verification status to #{Customer::VERIFICATION_STATES[new_status.to_i]}", :user => current_user)
    #@loan.comments << Comment.new(:comment => "#{current_user.full_name} updated #{params[:t]} verification status to #{Customer::VERIFICATION_STATES[new_status.to_i]}", :user => current_user)
    @comment = Comment.new
    if not params[:comment].blank?
      @comment.comment = params[:comment]
      @comment.commentable_id = params[:id]
      @comment.commentable_type = "Loan"
      @comment.user_id = current_user.id

      @comment.save
      #@loan.comments << Comment.new(:message => "#{params[:comment]} updated #{params[:t]} verification status to #{Customer::VERIFICATION_STATES[new_status.to_i]}", :user => current_user)
    end
    
  end

  def add_comment_customer
    @comment = Comment.new
    if not params[:comment].blank?
      @comment.comment = params[:comment]
      @comment.commentable_id = params[:id]
      @comment.commentable_type = "Loan"
      @comment.user_id = current_user.id
      @comment.save
      @data = "Comment was successfully saved"
      render :text => @data
    end
  end

  def add_comment_ajax
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user.id
    return_text = @comment.save ? 'OK' : 'Error'
    render :text => return_text
  end

  #  def set_bank_account_bank_aba_number
  #    @alert  = HighRiskBankBranch.find_by_aba_routing_number(params[:value])
  #    @loan = Loan.find(params[:id])
  #    if @alert.nil?
  #      @bank = BankAccount.find_by_customer_id(@loan.customer_id)
  #      @bank.bank_aba_number = params[:value]
  #      @bank.save
  #      render :text => params[:value]
  #    else
  #      redirect_to "/loans/#{@loan.id}?tab=financial"
  #    end
  #  end

  def edit_financial_data
    @loan = Loan.find(params[:id])
    @customer = Customer.find(@loan.customer_id)
    @bank_account = BankAccount.find(@customer.id)
    
    @fin_data = params[:fin_data]
    @data = @fin_data.split(",")
    @high_risk_aba_number = HighRiskBankBranch.find_by_aba_routing_number(@data[5])

    if @customer.monthly_income != @data[0]
      @loan.financial_data_change = true
    elsif @customer.income_source != @data[1]
      @loan.financial_data_change = true
    elsif @customer.pay_frequency != @data[2]
      @loan.financial_data_change = true
    elsif @bank_account.bank_name != @data[3]
      @loan.financial_data_change = true
    elsif @bank_account.bank_account_type != @data[4]
      @loan.financial_data_change = true
    elsif @bank_account.bank_aba_number != @data[5]
      @loan.financial_data_change = true
    elsif @bank_account.bank_account_number != @data[6]
      @loan.financial_data_change = true
    elsif @bank_account.months_at_bank != @data[7]
      @loan.financial_data_change = true
    elsif @bank_account.bank_address != @data[8]
      @loan.financial_data_change = true
    elsif @bank_account.bank_city != @data[9]
      @loan.financial_data_change = true
    elsif @bank_account.bank_state != @data[10]
      @loan.financial_data_change = true
    elsif @bank_account.bank_zip != @data[11]
      @loan.financial_data_change = true
    end

    @customer.monthly_income = @data[0]
    @customer.income_source = @data[1]
    @customer.pay_frequency = @data[2]
    @bank_account.bank_name = @data[3]
    @bank_account.bank_account_type = @data[4]
    @bank_account.bank_aba_number = @data[5]
    @bank_account.bank_account_number = @data[6]
    @bank_account.months_at_bank = @data[7]
    @bank_account.bank_address = @data[8]
    @bank_account.bank_city = @data[9]
    @bank_account.bank_state = @data[10]
    @bank_account.bank_zip = @data[11]
    @customer.save
    @bank_account.save
    @loan.save

    fin_data = (@customer.monthly_income.to_s + ',' +
        @customer.income_source.to_s + ',' +
        @customer.pay_frequency.to_s + ',' +
        @bank_account.bank_name.to_s + ',' +
        @bank_account.bank_account_type.to_s + ',' +
        @bank_account.bank_aba_number.to_s + ',' +
        @bank_account.bank_account_number.to_s + ',' +
        @bank_account.months_at_bank.to_s + ',' +
        @bank_account.bank_address.to_s + ',' +
        @bank_account.bank_city.to_s + ',' +
        @bank_account.bank_state.to_s + ',' +
        @bank_account.bank_zip.to_s)

    if @high_risk_aba_number.nil?
      @simple_msg = "A faxed bank account statement is required"
      data = fin_data + ",#{@simple_msg}"
      render :text => data
    else
      @risk_msg = "The ABA number is a part of High Risk Bank Branches"
      @simple_msg = "A faxed bank account statement is required"
      data = fin_data + ",#{@simple_msg}"+ ",#{@risk_msg}"
      render :text => data
    end
  end

  def update_disclosure_status
    @loan = Loan.find(params[:id])
    customer = @loan.customer

    val = params[:v] == 'true' ? Time.now : nil
    logger.info "val: #{val.inspect}"
    case params[:d]
    when 'finance_charge_amount'
      @loan.disclosed_finance_charge_amount_at = val
    when 'due_date'
      @loan.disclosed_due_date_at = val
    when 'apr'
      @loan.disclosed_apr_at = val
    when 'extend_12_weeks_max'
      @loan.disclosed_extend_12_weeks_max_at = val
    when 'auto_extend_upon_funding'
      @loan.auto_extend_to_upon_funding = params[:v] == 'true' ? @loan.customer.next_pay_date_2 : nil
    when 'partial_payments'
      @loan.disclosed_partial_payments_at = val
    when 'recission'
      @loan.disclosed_recission_at = val
    when 'must_request_extensions'
      @loan.disclosed_must_request_extensions_at = val
    when 'member_area'
      @loan.disclosed_member_area_at = val
    when 'send_sms_messages'
      #@loan.customer.send_sms_messages = val
    
    end
    @loan.save
    
    #    if (params[:d] == 'auto_extend_upon_funding')
    #      final_payment = @loan.signature_page_loan_amount + @loan.projected_interest_on_date_for_proposed_loan(@loan.customer.next_pay_date_2)
    #      final_payment_formatted = sprintf("$%4.2f",final_payment)
    #      render :text => final_payment_formatted
    #    end
    logger.info "loan saved"
  end

  def edit_tila_loan_amount_form
    @loan = Loan.find(params[:id])
    render :partial => 'loans/edit_tila_loan_amount_form', :layout => false
  end

  def set_signature_page_loan_amount
    @loan = Loan.find(params[:id])
    loan_amount = params[:amount].to_f
    loan_amount = @loan.customer.credit_limit if loan_amount > @loan.customer.credit_limit
    @loan.signature_page_loan_amount = loan_amount
    @loan.save
    interest = @loan.projected_interest_on_due_date_for_proposed_loan
    total = @loan.signature_page_loan_amount + interest
    render :text => sprintf("$%4.2f,$%4.2f,$%4.2f",@loan.signature_page_loan_amount,interest,total)
  end

  def loans_history_table
    loan = Loan.find(params[:id])
    render :partial => 'loans/loans_history', :locals => { :customer => loan.customer }
  end

  def complete_approval_process
    @loan = Loan.find(params[:id])
    accept_or_reject = params[:accept_or_reject]
    if accept_or_reject == "accept"
      if !@loan.signature_page_loan_amount.blank?
        if current_user.matching_password?(params[:password].to_s)
          # We made it.  Let's mark this customer as approved and give them money.
          @loan.mark_as_approved(current_user)
          if !params[:comments].blank?
            @loan.add_comment(params[:comments], current_user)
          end
          flash[:attention] = "#{@loan.customer.full_name} (Loan ##{@loan.id}) was successfully approved and has been placed in the queue for ACH transaction"
          redirect_to my_loans_path and return
        else
          flash[:error] = "Your entered password does not match your user password. Please try again"
          redirect_to loan_path(@loan) and return
        end
      else
        flash[:error] = "You must select an approved loan amount"
        redirect_to loan_path(@loan) and return
      end
    elsif accept_or_reject == "reject"
      reject_reason = params[:loan][:reject_reason]
      if !reject_reason.blank?
        if current_user.matching_password?(params[:password].to_s)
          @loan.mark_as_denied(reject_reason, current_user)
          if !params[:comments].blank?
            @loan.add_comment(params[:comments], current_user)
          end
          flash[:attention] = "#{@loan.customer.full_name} (Loan ##{@loan.id}) was denied a loan due to #{reject_reason}."
          redirect_to my_loans_path and return
        else
          flash[:error] = "Your entered password does not match your user password. Please try again"
          redirect_to loan_path(@loan) and return
        end
      else
        flash[:error] = "You must select a reason for rejecting the loan"
        redirect_to loan_path(@loan) and return
      end
    else
      flash[:error] = "You must select either 'approve' or 'reject'"
      redirect_to loan_path(@loan) and return
    end
  end
  
  def update_signature_loan_amount
    puts params.inspect
  end
  

  def loan_amount_tila
    @loan = Loan.find(params[:loan])
    @loan.signature_page_loan_amount = params[:loan_amt]
    @loan.disclosed_apr_at = "0000-00-00 00:00:00"
    @loan.disclosed_due_date_at = "0000-00-00 00:00:00"
    @loan.disclosed_extend_12_weeks_max_at = "0000-00-00 00:00:00"
    @loan.disclosed_finance_charge_amount_at = "0000-00-00 00:00:00"
    @loan.disclosed_member_area_at = "0000-00-00 00:00:00"
    @loan.disclosed_must_request_extensions_at = "0000-00-00 00:00:00"
    @loan.disclosed_next_due_date = "0000-00-00 00:00:00"
    @loan.disclosed_partial_payments_at = "0000-00-00 00:00:00"
    @loan.disclosed_recission_at = "0000-00-00 00:00:00"
    @loan.save
    render :update do |page|
      #page.replace loan_amount_tila, :partial => 'tila', :object => @loan
    end
  end

  #  def set_customer_pay_frequency
  #    customer = Customer.find(params[:id])
  #    customer.pay_frequency = params[:value]
  #    logger.info "Customer: #{customer.inspect}"
  #    customer.save!
  #  end

  def payment
    if request.get?
      flash[:error] = "Form POST required."
      redirect_to :action => :show, :id => params[:scheduled_payment][:loan_id], :tab => 'payment'
      return
    end

    loan = Loan.find(params[:scheduled_payment][:loan_id])
    customer = loan.customer


    unless ['active','collections','garnishments'].include? loan.aasm_state
      flash[:error] = 'Loan must be in either active, collections, or garnishments state'
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    if !loan.scheduled_payments.ach_submitted.empty?
      flash[:attention] = 'There is currently an ACH draft in process for this loan.  No new payments may be scheduled until the transaction is complete.'
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    if loan.total_principal_of_scheduled_payments >= loan.principal_owed
      flash[:attention] = "Existing Scheduled Payments Are Sufficient to Pay Off Loan.  If you want to change the payment schedule, cancel an existing scheduled payment first."
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    sp = params[:scheduled_payment]

    # PAYMENT PLAN

    if params[:payment_plan]
      setup_payment_plan(loan,sp)
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    unless params[:scheduled_payment][:amount] && params[:scheduled_payment][:amount].match(/^[0-9]\d{0,2}(\.\d{2})?$/)
      flash[:error] = 'Amount is missing or invalid (ddd or ddd.cc)'
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    if params[:scheduled_payment][:draft_date].blank?
      flash[:error] = 'Date is missing'
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    if params[:scheduled_payment][:amount].to_f > loan.payoff_amount
      flash[:error] = "Payment amount exceeds loan payoff amount"
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    @scheduled_payment = ScheduledPayment.new(params[:scheduled_payment])

    if params[:principal_only] == '1'
      @scheduled_payment.principal = @scheduled_payment.amount
    else
      @scheduled_payment.allocate_payment
    end

#    logger.info "AFTER ALLOCATION, total: #{@scheduled_payment.amount} principal: #{@scheduled_payment.principal} interest: #{@scheduled_payment.interest} fees: #{@scheduled_payment.fees}"
    if params[:payment_method].downcase == 'check'
      LoanTransaction.transaction do
        LoanTransaction.create(
          :loan => loan,
          :tran_type => LoanTransaction::PAYMENT,
          :total => @scheduled_payment.amount * -1,
          :principal => @scheduled_payment.principal * -1,
          :interest => @scheduled_payment.interest * -1,
          :fees => @scheduled_payment.fees * -1,
          :check_number => @scheduled_payment.check_number
        )
        loan.last_payment_confirmed_on = Date.today
        loan.save
        loan.logs << Log.new(:message => "#{current_user.full_name} posted a check payment in the amount of #{number_to_currency(@scheduled_payment.amount)}", :user => current_user)
      end
      loan.reload
      logger.info "Updating amounts owed"
      loan.update_amounts_owed
      flash[:success] = "Payment by check posted."
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    # Was either a bank account or a credit card specified?
    if @scheduled_payment.bank_account_id
      bank_account = BankAccount.find(@scheduled_payment.bank_account_id)
      @scheduled_payment.payment_account_id = bank_account.payment_account.id
    else
      if @scheduled_payment.credit_card_id
        credit_card = CreditCard.find(@scheduled_payment.credit_card_id)
        @scheduled_payment.payment_account_id = credit_card.payment_account.id
      end
    end

    if @scheduled_payment.payment_account_id.nil?
      # Add a new bank account or credit card
      @scheduled_payment.payment_account = create_payment_account(customer,sp)
      unless @scheduled_payment.payment_account
        redirect_to :action => :show, :id => loan.id, :tab => 'payment'
        return
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
          flash[:error] = "DECLINED: #{response.message}"
        else
          flash[:error] = "ERROR: #{error_message}"
        end
        redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
        return
      end

      # Approved.  Apply payment to loan
      Loan.transaction do
        LoanTransaction.create!(
          :loan => loan,
          :tran_type => LoanTransaction::PAYMENT,
          :total => @scheduled_payment.amount * -1,
          :principal => @scheduled_payment.principal * -1,
          :interest => @scheduled_payment.interest * -1,
          :fees => @scheduled_payment.fees * -1,
          :payment_account => @scheduled_payment.payment_account
        )
        loan.last_payment_confirmed_on = Date.today
        loan.update_amounts_owed
      end
      flash[:success] = 'Credit Card Payment Approved'
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    unless @scheduled_payment.valid?
      flash[:error] = "scheduled payment validation failed"
      redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
      return
    end

    @scheduled_payment.save!
    flash[:success] = 'Payment scheduled'
    redirect_to :action => :show, :id=>loan.id, :tab=>'payment'
  end

  def setup_payment_plan(loan,sp)
    unless ['bank_account','credit_card'].include? params[:payment_method]
      flash[:error] = 'Payment method must be either ACH or Bankcard'
      return
    end

    payment_account = nil
    case params[:payment_method]
    when 'bank_account'
      unless params[:scheduled_payment][:bank_account_id].blank?
        bank_account = BankAccount.find(params[:scheduled_payment][:bank_account_id])
        payment_account = bank_account.payment_account
      end
    when 'credit_card'
      unless params[:scheduled_payment][:credit_card_id].blank?
        credit_card = CreditCard.find(params[:scheduled_payment][:credit_card_id])
        payment_account = credit_card.payment_account
      end
    end

    unless payment_account
      payment_account = create_payment_account(loan.customer,sp)
      unless payment_account
        flash[:error] = 'No payment account specified or error creating payment account.'
        return
      end
    end

    scheduled_payments_created = 0
    for i in 1..10
      amount_key = "amount_#{i}".to_sym
      date_key = "date_#{i}".to_sym

      logger.info "#{i}: #{params[amount_key]} #{params[date_key]}"
      break if params[amount_key].blank? || params[date_key].blank?

      date_parts = params[date_key].split('/')
      month = date_parts[0].to_i
      day = date_parts[1].to_i
      year = date_parts[2].to_i

      logger.info "year: #{year} month: #{month} day: #{day}"

      scheduled_payment = ScheduledPayment.new(
        :customer_id => loan.customer_id,
        :loan_id => loan.id,
        :payment_account => payment_account,
        :draft_date => Date.new(year,month,day),
        :amount => params[amount_key]
      )
      scheduled_payment.allocate_payment
      scheduled_payment.save!
      scheduled_payments_created += 1
    end
    loan.mark_as_payment_plan!
    flash[:success] = "Payment Plan Set Up (#{scheduled_payments_created} payments)"
  end

  def extension_by_staff
    @loan = Loan.find(params[:id])
    begin
      @loan.extend_to_next_payday!
    rescue Exception => e
      render :text => e.message, :layout => false
    end
    @loan.reload
    @scheduled_payment = @loan.scheduled_payments.last
    render :partial => 'extension_row', :layout => false
  end

  def next_due_date_after
    loan = Loan.find(params[:id])
    date_parts = params[:date].split('/')
    month = date_parts[0].to_i
    day = date_parts[1].to_i
    year = date_parts[2].to_i
    base_date = Date.civil(year,month,day)
    logger.info "base_date: #{base_date.to_s(:mmddyyy)}"
    logger.info "due_date: #{loan.due_date.to_s(:mmddyyyy)}"
    logger.info "next_due_date: #{loan.next_due_date.to_s(:mmddyyyy)}"
    while loan.due_date <= base_date
      loan.due_date = loan.next_due_date
      logger.info "new due_date: #{loan.due_date.to_s(:mmddyyyy)}"
    end
    render :text => loan.due_date.to_s(:mmddyyyy)
  end

  def payment_old

    #if current_user.role == "garnishments"
    # @loan = Loan.find(params[:loan_transaction][:loan_id])
    #@loan_transaction =  LoanTransaction.new(params[:loan_transaction])

    #end
    sp = params[:loan_tran]
    @loan = Loan.find(params[:loan_transaction][:loan_id])
    @customer = @loan.customer
    @loan_transaction =  LoanTransaction.new(params[:loan_transaction])
    @loan_transaction.loan_id = @loan.id
    #@loan_transaction.total = sp[:total_owed]
    @loan_transaction.allocate_payment
    
    if @loan_transaction.payment_account_id.nil?
      @customer.payment_accounts.credit_cards.each do |payment_account|
        logger.info "payment_account.account type: #{payment_account.account.class.to_s}"
        if (sp[:card_number][-4,4] == payment_account.account.last_4_digits)
          @loan_transaction.errors.add_to_base('This card is already in your Credit Card list.')
          flash[:notice] = 'This card is already in your Credit Card list.'
          setup_make_payment_page
          redirect_to :action=>'show',:id=>@loan.id,:tab=>'payment'
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
        @loan_transaction.errors.add_to_base('Invalid Credit Card')
        flash[:notice] = 'Invalid Credit Card.'
        setup_make_payment_page
        redirect_to :action=>'show',:id=>@loan.id,:tab=>'payment'
        return
      end

      begin
        payment_account = PaymentAccount.new(
          :customer_id => @loan.customer_id,
          :account_id => credit_card.id,
          :account_type => CreditCard.to_s,
          :create_authnet_customer_profile => true,
          :create_authnet_payment_profile => true,
          :credit_card => credit_card
        )

        payment_account.save!
        @loan_transaction.payment_account = payment_account
      rescue Exception => e
        logger.info "Controller caught: #{e.inspect}"
        raise e
      end
    end

    # If payment method is credit card and payment date is today, process immediately without scheduling
    
    cim_gateway = get_authnet_cim_payment_gateway
    transaction_hash = {
      :type => :auth_capture,
      :amount => 2.50, # TODO - Use Real amount
      :customer_profile_id => @customer.authnet_customer_profile_id,
      :customer_payment_profile_id => @loan_transaction.payment_account.authnet_payment_profile_id
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

    unless response.success?
      if response
        @loan_transaction.errors.add_to_base("DECLINED: #{response.message}")
      else
        @loan_transaction.errors.add_to_base("ERROR: #{error_message}")
      end
      setup_make_payment_page
      #return
    end


    # Approved.  Apply payment to loan
    LoanTransaction.create!(
      :loan => @loan,
      :tran_type => LoanTransaction::PAYMENT,
      :total => @loan_transaction.total * -1,#@loan_transaction.total * -1,
      :principal => @loan_transaction.principal * -1,
      :interest => @loan_transaction.interest * -1,
      :fees => @loan_transaction.fees * -1,
      :payment_account => @loan_transaction.payment_account
    )
    @loan.update_amounts_owed
    #end
    flash[:notice] = 'Credit Card Payment Approved'
    redirect_to (loan_info_history_path(:id=>@loan.id))
    #return

  end

  def scheduled_payments_for_payment_modal
    @loan = Loan.find(params[:id])
    render :partial => 'scheduled_payments_for_payment_modal', :layout => false
  end

  def delete_checked_scheduled_payments
    ScheduledPayment.destroy(params[:ids])
  end

  def edit_new_loan_payment_amount_form
    render :partial => 'edit_new_loan_payment_amount_form'
  end

  def allocate_check_number
    @loan = Loan.find(session[:loan_id])
    @loan_transaction = LoanTransaction.new
    @loan_transaction.loan_id = session[:loan_id]
    @loan_transaction.tran_type = "payment"
    @loan_transaction.total = @loan.total_owed
    @loan_transaction.principal = @loan.total_owed
    @loan_transaction.interest = @loan.interest_owed
    @loan_transaction.fees = @loan.fees_owed
    @loan_transaction.check_number = params[:id]

    @loan_transaction.save
    
    render :text => sprintf(params[:id].to_s)
  end

  def edit_check_number_form
    session[:loan_id] = params[:id]
    render :partial => 'edit_check_number_form'
  end

  def allocate_hypothetical_loan_payment
    loan = Loan.find(params[:id])
    a = loan.allocate_hypothetical_loan_payment(params[:amount].to_f,Date.today)
    render :text => sprintf("$%4.2f,$%4.2f,$%4.2f,$%4.2f",a[:total],a[:principal],a[:interest],a[:fees])
  end

  def loan_tran_payments
    @loan = Loan.find(params[:id])
    @customer = @loan.customer
    if @customer.loans.active.empty?
      render :partial => 'loans/no_active_loan', :layout => true
      return
    end
    @loan = current_customer.loans.active.first
  end

  def loan_info_history
    @loan = Loan.find(params[:id])
    @customer = @loan.customer
  end

  def request_recission
    loan = Loan.find(params[:id])
    loan.mark_as_recission_requested
    redirect_to loan_path(loan)
  end

  def write_down
    # Validate format of amounts
    if params[:loan][:principal_owed]
      unless params[:loan][:principal_owed].match(/^[0-9]\d{0,2}(\.\d{2})?$/)
        render :text => "Principal format invalid (ddd or ddd.cc)"
        return
      end
    end
    if params[:loan][:interest_owed]
      unless params[:loan][:interest_owed].match(/^[0-9]\d{0,2}(\.\d{2})?$/)
        render :text => "Interest format invalid (ddd or ddd.cc)"
        return
      end
    end
    if params[:loan][:fees_owed]
      unless params[:loan][:fees_owed].match(/^[0-9]\d{0,2}(\.\d{2})?$/)
        render :text => "Fees format invalid (ddd or ddd.cc)"
        return
      end
    end
    
    loan = Loan.find(params[:id])
    principal_adjustment = 0
    interest_adjustment = 0
    fees_adjustment = 0

    if params[:loan][:principal_owed]
      new_principal = params[:loan][:principal_owed].to_f
      principal_adjustment = new_principal - loan.principal_owed
    end
    if params[:loan][:interest_owed]
      new_interest = params[:loan][:interest_owed].to_f
      interest_adjustment = new_interest - loan.interest_owed
    end
    if params[:loan][:fees_owed]
      new_fees = params[:loan][:fees_owed].to_f
      fees_adjustment = new_fees - loan.fees_owed
    end
    total_adjustment = principal_adjustment + interest_adjustment + fees_adjustment
    Loan.transaction do
      loan.update_attributes(params[:loan])
      LoanTransaction.create(
        :loan => loan,
        :tran_type => LoanTransaction::ADJUSTMENT,
        :total => total_adjustment,
        :principal => principal_adjustment,
        :interest => interest_adjustment,
        :fees => fees_adjustment,
        :memo => params[:memo]
      )
    end
    loan.logs << Log.new(:message => "#{current_user.full_name} made adjustment. New Values -- Principal: #{number_to_currency(loan.principal_owed)} Interest: #{number_to_currency(loan.interest_owed)} Fees: #{number_to_currency(loan.fees_owed)}", :user => current_user)
    render :text => 'OK'
  end

  def set_aasm_state
    loan = Loan.find(params[:id])
    case params[:loan][:aasm_state]
    when 'approved'
      loan.mark_as_approved(current_user)
    when 'collections'
      loan.mark_as_collections
    when 'denied'
      loan.mark_as_denied('Admin Decision')
      loan.logs << Log.new(:message => "Set to recission_requested by #{current_user.full_name}", :user => current_user)
    when 'garnishments'
      loan.mark_as_garnishments(current_user)
    when 'paid_in_full'
      loan.mark_as_paid_in_full()
      loan.logs << Log.new(:message => "Set to paid_in_full by #{current_user.full_name}", :user => current_user)
    when 'pending_write_off'
      loan.mark_as_pending_write_off(current_user)
    when 'recission_requested'
      loan.mark_as_recission_requested
      loan.logs << Log.new(:message => "Set to recission_requested by #{current_user.full_name}", :user => current_user)
    when 'written_off'
      loan.mark_as_written_off(current_user)
    end
    render :text => 'OK'
  end
  
  def set_garnishment_status
    @loan = Loan.find(params[:id])
    @loan.garnishment_sub_status = params[:status]
    if @loan.garnishment_sub_status == 'approved'
      @loan.garnishment_approved_on = Date.today
    end
    @loan.save
    render :text => @loan.garnishment_sub_status_display
  end


  def set_loan_as_garnishment
    @loan = Loan.find(params[:id])
    @loan.mark_as_garnishments(current_user)
    value = " "
    render :text => value
  end

  def set_loan_disposition_from_collections
    raise Exception.new(:message => 'User is not a collections agent') unless current_user.is_collections_agent?
    loan = Loan.find(params[:id])
    case params[:aasm_state]
    when 'garnishments'
      loan.mark_as_garnishments(current_user)
      flash[:success] = "#{loan.customer.full_name} - sent to garnishments"
    when 'payment_plan'
      loan.mark_as_payment_plan
      flash[:success] = "#{loan.customer.full_name} - payment plan initiated"
    when 'paid_in_full'
      loan.mark_as_paid_in_full
      flash[:success] = "#{loan.customer_full_name} - marked as paid in full"
    when 'pending_write_off'
      loan.mark_as_pending_write_off
      flash[:success] = "#{loan.customer_full_name} - pending write off"
    end
    render :text => "OK"
  end

  def get_garnishment_fax_info
    loan = Loan.find(params[:id])
    confirmed_at = loan.garnishment_fax_confirmed_at ? loan.garnishment_fax_confirmed_at.to_s(:day_date_time) : 'Not Confirmed'
    render :text => "#{loan.garnishment_fax_attempts}|#{confirmed_at}|#{!loan.garnishment_packet_sent_by_mail_on.nil?}"
  end
  #
  #  def confirm_garnishment_fax
  #    loan = Loan.find(params[:id])
  #    loan.garnishment_fax_confirmed_at = Time.now
  #    result = loan.save ? 'OK' : 'Error'
  #    render :text => result
  #  end
  
  def garnishment_fax_dialog
    loan = Loan.find(params[:loan_id])
    loan.customer.employer_fax = params[:customer][:employer_fax].gsub!(/-/,'')
    loan.customer.save
    if params[:customer][:resend_garnishment_fax] == '1'
      loan.send_garnishment_packet(current_user)
    end
    if params[:customer][:garnishment_fax_received] == '1'
      loan.garnishment_fax_confirmed_at = Time.now
    else
      loan.garnishment_fax_confirmed_at = nil
    end
    loan.garnishment_packet_sent_by_mail_on = Date.today
    loan.save
    render :text => 'OK'
  end

  def garnishment_status_form
    @loan = Loan.find(params[:id])
    render :partial => 'garnishment_status_form', :layout => false
  end

  def garnishment_telephone_status_form
    @loan = Loan.find(params[:id])
    render :partial => 'garnishment_telephone_status_form', :layout => false
  end

  def update_garnishment_status
    loan = Loan.find(params[:id])
    loan.garnishment_approved = params[:loan][:garnishment_approved] == '1'
    loan.court_order = params[:loan][:court_order] == '1'
    loan.save!
    if params[:loan][:aasm_state] == 'pending_write_off'
      loan.mark_as_pending_write_off(current_user)
    end
    render :text => 'OK'
  end

  def update_garnishment_telephone_status
    loan = Loan.find(params[:id])
    loan.garnishment_telephone_status = params[:loan][:garnishment_telephone_status]
    loan.save!
    render :text => 'OK'
  end

  def utc_offset_hours
    loan = Loan.find(params[:id])
    render :text => loan.customer.utc_offset_hours
  end

  def tila_pdf
    @loan = Loan.find(params[:id])
    pdf = @loan.tila_pdf(request.remote_ip,current_user)
    send_data(pdf,:filename => 'tila.pdf',:type => 'application/pdf', :disposition => 'inline')
  end

  private

  def underwriter_my_loans
    @loans = Array.new
    #   if params[:id]
    #     @user=User.find(params[:id])
    #     @loans = loans_for_user_based_on_role(@user)
    #     @role = @user.role
    #   else
    underwriting_loans_state = ['underwriting']
    no_reply_loans_state = ['no_reply']
    pending_signature_loans_state = ['pending_signature']
    loan_approved = ['approved']
    loan_denied = ['denied']
    #aasm_states = state.gsub!('--- \n-' ,'')
    #@loans = Array.new
    #@loan_funded_on_and_aasm_state_underwirting = Loan.loan_aasm_state([['underwriting'],['no_reply']],current_user.id)
    @underwriting_loans_state = Loan.loan_verification("0","0","0","0","0",current_user.id).loan_aasm_state(underwriting_loans_state,current_user.id)
    @no_reply_loans_state = Loan.loan_verification("0","0","0","0","0",current_user.id).loan_aasm_state(no_reply_loans_state,current_user.id)
    @pending_signature_loans_state = Loan.loan_verification("0","0","0","0","0",current_user.id).loan_aasm_state(pending_signature_loans_state,current_user.id)
      
    @employer_verification = Loan.loan_verification("0","0","0","0","1",current_user.id)
    @personal_verification_loan = Loan.loan_verification("1","0","0","0","1",current_user.id)
    @financial_verification_loan = Loan.loan_verification("1","1","0","0","1",current_user.id)
    @customer_verification_loan = Loan.loan_verification("1","1","0","1","1",current_user.id)
    #@tila_verification_loan = Loan.loan_verification("1","1","1","1","1")
    @approved_loans = Loan.loan_aasm_state(loan_approved,current_user.id)
    @denied_loan = Loan.loan_aasm_state(loan_denied,current_user.id)

    @underwriting_loans_state.each do |underwriting_loans_state|
      @loans << underwriting_loans_state
    end

    @no_reply_loans_state.each do |no_reply_loans_state|
      @loans << no_reply_loans_state
    end

    @pending_signature_loans_state.each do |pending_signature_loans_state|
      @loans << pending_signature_loans_state
    end


    @employer_verification.each do |employer_verification|
      @loans << employer_verification
    end

    @personal_verification_loan.each do |personal_verification_loan|
      @loans << personal_verification_loan
    end
    #
    @financial_verification_loan.each do |financial_verification_loan|
      @loans << financial_verification_loan
    end
    #
    @customer_verification_loan.each do |customer_verification_loan|
      @loans << customer_verification_loan
    end

    @approved_loans.each do |approved_loan|
      @loans << approved_loan
    end

    @denied_loan.each do |denied_loan|
      @loans << denied_loan
    end
    @loans = @loans.paginate :page => params[:page],:per_page=>10
    return @loans
    #end
  end

  def collection_my_loans
    if params[:filters]
      @loans = Loan.find(:all, :conditions => ["aasm_state in (?)", @filters]).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC', :include => [:comments, :customer]
    else
      @filters = ['collections']
      @loans = current_user.loans_as_collections_agent.in_collections
    end
    return @loans.paginate :page => params[:page],:per_page=>15
  end

  def garnishment_my_loans
    logger.info "params[:filters].nil?: #{params[:filters].nil?}"
    @filters = []
    loans = []
    approved_loans_no_payments_within_30_days = []
    packet_sent_loans = []
    packet_confirmed_loans = []
    approved_loans_within_one_day = []
    no_sub_status_loans = []

    if params[:filters]
      @filters = params[:filters].keys
    end

      if params[:filters].nil? || (params[:filters] && params[:filters][:no_payments_30_days] == 'on')
        logger.info "INCLUDING NO PAYMENT LOANS"
        approved_loans_no_payments_within_30_days = Loan.find(:all, :conditions => ["aasm_state = 'garnishments' and garnishment_sub_status = 'approved' and last_payment_confirmed_on <= ? and garnishments_agent_id = ?",Date.today-30,current_user.id],:include => :customer)
      end

      if params[:filters].nil? || (params[:filters] && params[:filters][:packet_sent] == 'on')
        logger.info "INCLUDING PACKET SENT LOANS"
        packet_sent_loans = Loan.find(:all, :conditions => ["aasm_state = 'garnishments' and garnishment_sub_status = 'packet_sent' and garnishment_fax_confirmed_at is null and garnishments_agent_id = ?",current_user.id],:include => :customer)
        logger.info "packet_sent loans: #{packet_sent_loans.size}"
      #        packet_sent_loans = Loan.garnishment_sub_status("packet_sent",current_user.id)
      end

      if params[:filters].nil? || (params[:filters] && params[:filters][:packet_confirmed] == 'on')
        logger.info "INCLUDING PACKET CONFIRMED LOANS"
        packet_confirmed_loans = Loan.find(:all, :conditions => ["aasm_state = 'garnishments' and garnishment_fax_confirmed_at is not null and garnishments_agent_id = ?",current_user.id],:include => :customer)
        logger.info "packet confirmed loans: #{packet_confirmed_loans.size}"
#        packet_confirmed_loans = Loan.packet_confirmed(current_user.id)
      end


      if params[:filters].nil? || (params[:filters] && params[:filters][:approved] == 'on')
        logger.info "INCLUDING APPROVED LOANS"
        approved_loans_within_one_day = Loan.find(:all, :conditions => ["aasm_state = 'garnishments' and garnishment_sub_status = 'approved' and garnishment_approved_on >= ? and garnishments_agent_id = ?",Date.today-1,current_user.id])
      end

      if params[:filters].nil?
        no_sub_status_loans = Loan.no_garnishment_sub_status(current_user.id)
      end
#    end

    approved_loans_no_payments_within_30_days.each do |loan|
      loans << loan
    end

    packet_sent_loans.each do |loan|
      loans << loan
    end

    packet_confirmed_loans.each do |loan|
      loans << loan
    end

    no_sub_status_loans.each do |loan|
      loans << loan
    end

    approved_loans_within_one_day.each do |loan|
      loans << loan
    end
    @loans = loans.paginate :page => params[:page],:per_page=>15
#    end
    @loans
  end

  def loans_for_user_based_on_role(user)
    case user.role
    when User::UNDERWRITER
      return user.loans_as_underwriter.accepted
    when User::COLLECTIONS
      return user.loans_as_collections_agent.in_collections
    when User::GARNISHMENTS
      return user.loans_as_garnishments_agent.in_garnishments
    end
    []
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
    @loan_transaction.total = @loan.total_owed
    @loan_transaction.allocate_payment
  end

  def create_payment_account(customer,sp)
      payment_account = nil
      if params[:payment_method] == 'bank_account'
        # Check for duplicate
        customer.payment_accounts.bank_accounts.each do |payment_account|
          if sp[:bank_account_number] == payment_account.account.bank_account_number
            flash[:error] = "This account is already in customer's Bank Account list."
            return nil
          end
        end

        bank_account = BankAccount.new(
          :customer_id => customer.id,
          :bank_name => sp[:bank_name],
          :bank_account_type => sp[:bank_account_type],
          :bank_aba_number => sp[:bank_aba_number],
          :bank_account_number => sp[:bank_account_number],
          :months_at_bank => 0,
          :bank_direct_deposit => false
        )
        if bank_account.valid?
          bank_account.save!
          payment_account = PaymentAccount.new(
            :customer_id => customer.id,
            :account_id => bank_account.id,
            :account_type => BankAccount.to_s,
            :create_authnet_customer_profile => false,
            :create_authnet_payment_profile => false
          )
          payment_account.save!
          return payment_account
        else
          flash[:error] = 'Invalid or Duplicate Bank Account'
          return nil
        end
      end

      if params[:payment_method] == 'credit_card'
        # Check for duplicate
        customer.payment_accounts.credit_cards.each do |payment_account|
          if sp[:card_number][-4,4] == payment_account.account.last_4_digits
            flash[:error] = "This card is already in Credit Card list."
            return nil
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
          flash[:error] = 'Invalid Credit Card'
          return nil
        end

        begin
          payment_account = PaymentAccount.new(
            :customer_id => customer.id,
            :account_id => credit_card.id,
            :account_type => CreditCard.to_s,
            :create_authnet_customer_profile => true,
            :create_authnet_payment_profile => true,
            :credit_card => credit_card
          )

          payment_account.save!
        rescue Exception => e
          logger.info "Controller caught: #{e.inspect}"
          raise e
        end
      end
      payment_account
  end
end
