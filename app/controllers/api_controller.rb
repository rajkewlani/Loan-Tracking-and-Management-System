class ApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
 
  def post
    if (params[:username].blank? || params[:password].blank? || params[:port_key].blank?)
      @customer = Customer.new
      render :layout => false
    else

      @lead_provider = LeadProvider.find_by_username_and_password(params[:username], params[:password])
      @portfolio = Portfolio.find_by_port_key(params[:port_key])
      if @lead_provider.nil? and @portfolio.nil?
        @customer = Customer.new
        render :layout => false
        return
      end
      if @lead_provider
        @customer = Customer.new
        @customer.lead_provider_id         = @lead_provider.id,
        @customer.portfolio_id             = @portfolio.id,
        @customer.ip_address               = params[:ip_address]
        @customer.lead_source              = params[:lead_source]
        @customer.tracker_id               = params[:tracker_id]
        @customer.first_name               = params[:first_name]
        @customer.last_name                = params[:last_name]
        @customer.mothers_maiden_name      = params[:mothers_maiden_name]
        @customer.ssn                      = params[:ssn]
        @customer.gender                   = params[:gender]
        @customer.email                    = params[:email]
        @customer.birth_date               = params[:birth_date]
        @customer.dl_number                = params[:dl_number]
        @customer.dl_state                 = params[:dl_state]
        @customer.military                 = (params[:military] == 'true') ? true : ((params[:military] == 'false') ? false : nil)
        @customer.home_phone               = params[:home_phone]
        @customer.work_phone               = params[:home_phone]
        @customer.cell_phone               = params[:cell_phone]
        @customer.fax                      = params[:fax]
        @customer.address                  = params[:address]
        @customer.city                     = params[:city]
        @customer.country_code             = params[:country_code]
        @customer.state                    = params[:state]
        @customer.zip                      = params[:zip]
        @customer.monthly_income           = params[:monthly_income]
        @customer.income_source            = params[:income_source]
        @customer.pay_frequency            = params[:pay_frequency]
        @customer.employer_name            = params[:employer_name]
        @customer.occupation               = params[:occupation]
        @customer.months_employed          = params[:months_employed]
        @customer.employer_phone           = params[:employer_phone]
        @customer.employer_phone_ext       = params[:employer_phone_ext]
        @customer.supervisor_name          = params[:supervisor_name]
        @customer.supervisor_phone         = params[:supervisor_phone]
        @customer.supervisor_phone_ext     = params[:supervisor_phone_ext]
        @customer.residence_type           = params[:residence_type]
        @customer.monthly_residence_cost   = params[:monthly_residence_cost]
        @customer.months_at_address        = params[:months_at_address]
        @customer.bank_name                = params[:bank_name]
        @customer.bank_account_type        = params[:bank_account_type]
        @customer.bank_aba_number          = params[:bank_aba_number]
        @customer.bank_account_number      = params[:bank_account_number]
        @customer.months_at_bank           = params[:months_at_bank]
        @customer.bank_direct_deposit      = (params[:bank_direct_deposit] == 'y') ? true : ((params[:bank_direct_deposit] == 'n') ? false : nil)
        @customer.bank_phone               = params[:bank_phone]
        @customer.credit_limit              = Date.parse(params[:next_pay_date_1]) unless params[:next_pay_date_1].blank?
        @customer.next_pay_date_1          = Date.parse(params[:next_pay_date_1]) unless params[:next_pay_date_1].blank?
        @customer.next_pay_date_2          = Date.parse(params[:next_pay_date_2]) unless params[:next_pay_date_2].blank?
        @customer.reference_1_name         = params[:reference_1_name]
        @customer.reference_1_phone        = params[:reference_1_phone]
        @customer.reference_1_relationship = params[:reference_1_relationship]
        @customer.reference_2_name         = params[:reference_2_name]
        @customer.reference_2_phone        = params[:reference_2_phone]
        @customer.reference_2_relationship = params[:reference_2_relationship]
        @customer.is_test                  = (params[:is_test] == 'true') ? true : ((params[:is_test] == 'false') ? false : nil)
        @customer.aasm_state               = "not_purchased"
        @customer.send_sms_messages        = 0
        if (@customer.is_test? || ((params[:force_post] == "true" && @lead_provider.status == 0) ? false : request.get?))
          @customer.valid?
          @customer.save
          flash[:attention] = "Submit the form as a POST for XML response. To override this, pass in the parameter <b>force_post</b> with the value of <b>'true'</b>"
          render :layout => false
        else
          render :xml => @customer.submit_for_purchase
          Mailer.send_later :deliver_new_customer_welcome_letter, self unless @customer.is_test?

#          # Create a loan associated with this customer.  The loan record is the loan application until it is approved.
#          Loan.create!(
#            :customer_id => @customer.id,
#            :requested_loan_amount => 150,
#            :portfolio_id => @portfolio.id
#          )
#
#          # Create a bank account associated with this customer.
#          bank_account = BankAccount.create!(
#            :customer_id => @customer.id,
#            :bank_name => params[:bank_name],
#            :bank_account_type => params[:bank_account_type],
#            :bank_aba_number => params[:bank_aba_number],
#            :bank_account_number => params[:bank_account_number],
#            :months_at_bank => params[:months_at_bank],
#            :bank_direct_deposit => params[:bank_direct_deposit],
#            :bank_phone => params[:bank_phone],
#            :funding_account => true
#          )
#          PaymentAccount.create!( :customer_id => @customer.id, :account_id => bank_account.id, :account_type => 'BankAccount')
        end
      else
        raise "Invalid username and/or password"
      end
    end
  end                                                            

  def send_test_email
    Mailer.deliver_test('bhaupt@xmission.com')
    redirect_to loans_path
  end

end
