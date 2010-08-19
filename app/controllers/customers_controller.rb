class CustomersController < ApplicationController
  before_filter :login_required, :except => [:opt_out_of_marketing_emails]
  
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
  in_place_edit_for :customer, :pay_frequency, { :format => 'key_value', :values => ["Weekly:WEEKLY", "Bi-Weekly:BIWEEKLY", "Twice Monthly:TWICEMONTHLY", "Monthly:MONTHLY"]}
  in_place_edit_for :customer, :employer_name
  in_place_edit_for :customer, :occupation
  in_place_edit_for :customer, :months_employed
  in_place_edit_for :customer, :employer_address
  in_place_edit_for :customer, :employer_city
  in_place_edit_for :customer, :employer_state
  in_place_edit_for :customer, :employer_zip
  in_place_edit_for :customer, :employer_phone, { :format => "phone" }
  in_place_edit_for :customer, :employer_phone_ext
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
  in_place_edit_for :customer, :bank_name
  in_place_edit_for :customer, :bank_account_type, { :format => 'key_value', :values => ["Checking:CHECKING", "Savings:SAVINGS"]}
  in_place_edit_for :customer, :months_at_bank
  in_place_edit_for :customer, :bank_address
  in_place_edit_for :customer, :bank_city
  in_place_edit_for :customer, :bank_state, { :format => 'key_value', :values => Common::US_STATES.sort.map{|k,v|"#{k} - #{v}:#{k}"} }
  in_place_edit_for :customer, :bank_zip
  in_place_edit_for :customer, :bank_phone, { :format => "phone" }
  in_place_edit_for :customer, :next_pay_date_1
  in_place_edit_for :customer, :next_pay_date_2
  in_place_edit_for :customer, :loan_amount
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

  def index
    if params[:filters]
      @filters = params[:filters].keys
    else
      @filters = ['pending','no_reply', 'approved']
    end
    @customers = Customer.find(:all, :conditions => ["aasm_state in (?)", @filters]).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC', :include => :comments
  end
  
  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(params[:customer])
    @customer.lead_source = 'internal'
    @customer.income_source = 'EMPLOYMENT'
    @customer.ip_address = request.remote_ip
    @customer.lead_provider_id = 1
    @customer.combine_multi_part_fields
    @customer.aasm_state = :manually_entered
    @customer.country_code = 'US'
    #if current_user.role == 'underwriter'
      # Assign customer to the underwriter who entered it
      #@customer.underwriter_id = session[:user_id]
#      @customer.underwriter_type = 'User'
    #end
    if @customer.save
      @customer.reload
      ft = @customer.submit_to_factor_trust
      factor_trust = FactorTrust.create(:customer_id => @customer.id, :response_xml => ft.response_xml)
      redirect_to :controller => :loans, :action => :show, :id => @customer.loans.first.id
      return
    else
      logger.info "errors: #{@customer.errors.inspect}"
      render :action => :new
    end
  end
  
  def show
    @current_tab = params[:tab].blank? ? "summary" : params[:tab]
    @customer = Customer.find(params[:id])
    @home_listings = @customer.customer_phone_listings.find_all_by_phone(@customer.home_phone)
    @work_listings = @customer.customer_phone_listings.find_all_by_phone(@customer.work_phone)
    @cell_listings = @customer.customer_phone_listings.find_all_by_phone(@customer.cell_phone)
    @employer_listings = @customer.customer_phone_listings.find_all_by_phone(@customer.employer_phone)
    @reference_1_listings = @customer.customer_phone_listings.find_all_by_phone(@customer.reference_1_phone)
    @reference_2_listings = @customer.customer_phone_listings.find_all_by_phone(@customer.reference_2_phone)
    @prior_instances_of_customer_with_discrepancies = []
    #unless @employer_listings.empty?
      customers_employed_by_same_company = Customer.find(:all, :conditions => ["employer_phone = ? and id <> ?",@customer.employer_phone,params[:id]])
      for prior_customer in customers_employed_by_same_company
        if prior_customer.first_name.downcase == @customer.first_name.downcase && prior_customer.last_name.downcase == @customer.last_name.downcase && prior_customer.state == @customer.state
          # Appears to be the same person.
          if  prior_customer.home_phone != @customer.home_phone ||
              prior_customer.address != @customer.address ||
              prior_customer.zip != @customer.zip ||
              prior_customer.birth_date != @customer.birth_date ||
              prior_customer.gender != @customer.gender ||
              prior_customer.ssn != @customer.ssn ||
              prior_customer.dl_number != @customer.dl_number ||
              prior_customer.dl_state != @customer.dl_state ||
              prior_customer.residence_type != @customer.residence_type ||
              prior_customer.supervisor_name != @customer.supervisor_name ||
              prior_customer.supervisor_phone != @customer.supervisor_phone
            @prior_instances_of_customer_with_discrepancies << prior_customer
          end
        end
      end
    #end
    begin
      @factor_trust = @customer.factor_trust.application_response['ApplicationResponse']['ApplicationInfo']
    rescue
      @factor_trust = nil
    end
  end

  def destroy
    Customer.destroy(params[:id])
    flash[:information] = 'Customer deleted sucessfully.'
    redirect_to :action => :index
  end
  
  def add_comment
    @customer = Customer.find(params[:id])
    if !params[:message].blank?
      @customer.add_comment(params[:message], current_user)
    else
      flash[:attention] = "Please enter your comments in the text field below to add notes to this customer"
    end
    redirect_to "/customers/#{@customer.id}?tab=comments"
  end

  def get_formatted_employer_fax_number
    @customer = Customer.find(params[:id])
    render :text => @customer.employer_fax ? @customer.employer_fax.using('###-###-####') : ''
  end

  def opt_out_of_marketing_emails
    @customer = Customer.find(params[:id])
    @customer.send_marketing_emails = false
    @customer.save
    render :layout => 'flobridge'
  end
  
end
