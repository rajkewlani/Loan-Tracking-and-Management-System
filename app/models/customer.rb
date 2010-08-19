require 'common'
require 'digest/sha1'
require 'attr_encrypted'

class Customer < ActiveRecord::Base
#exit
  include AASM
  include ActiveMerchant::Utils
  include Exceptions
  
  acts_as_loggable
  acts_as_commentable
  belongs_to :lead_provider
  belongs_to :portfolio
  belongs_to :user, :class_name => 'User', :foreign_key => "underwriter_id"
  has_many :customer_phone_listings
  has_many :loans, :order => 'created_at desc'
  has_one :factor_trust
  has_many :bank_accounts
  has_many :payment_accounts
  has_many :scheduled_payments, :order => 'draft_date'
  has_many :documents, :as => :docs

  attr_accessor :imported
  attr_accessor :ssn_1, :ssn_2, :ssn_3
  attr_accessor :home_phone_area_code, :home_phone_prefix, :home_phone_suffix
  attr_accessor :work_phone_area_code, :work_phone_prefix, :work_phone_suffix
  attr_accessor :landlord_phone_area_code, :landlord_phone_prefix, :landlord_phone_suffix
  attr_accessor :employer_phone_area_code, :employer_phone_prefix, :employer_phone_suffix
  attr_accessor :employer_fax_area_code, :employer_fax_prefix, :employer_fax_suffix
  attr_accessor :supervisor_phone_area_code, :supervisor_phone_prefix, :supervisor_phone_suffix
  attr_accessor :ref1_first_name, :ref1_last_name, :ref2_first_name, :ref2_last_name
  attr_accessor :ref1_phone_area_code, :ref1_phone_prefix, :ref1_phone_suffix
  attr_accessor :ref2_phone_area_code, :ref2_phone_prefix, :ref2_phone_suffix
  attr_accessor :us_citizen
  # Pass through to loan record on new customers
  attr_accessor :suppress_default_loan
  attr_accessor :requested_loan_amount, :underwriter_id, :suppress_messages_after_create
  # Virtual attributes for garnishment fax dialog
  attr_accessor :resend_garnishment_fax, :confirm_garnishment_fax_received, :garnishment_packet_sent_by_mail

  # Pass through to bank account record on new customers
  attr_accessor :bank_name, :bank_account_type, :bank_aba_number, :bank_account_number
  attr_accessor :months_at_bank, :bank_direct_deposit
  attr_accessor :bank_address, :bank_city, :bank_state, :bank_zip, :bank_phone, :bank_account_balance
  
  liquid_methods :first_name, :last_name, :email

  named_scope :purchased, lambda { |*args| ((!args.first.blank?) && (!args.last.blank?))?({:conditions => ["aasm_state = ? and lead_provider_id = ?", args.first.to_s, args.last.to_s]}):{} }
    
  MONTHLY_INCOMES = [
      ["Under $1,000", 1000],
      ["$1,000 - $1,199", 1200],
      ["$1,500 - $1,799", 1500],
      ["$1,800 - $1,999", 1800],
      ["$2,000 - $2,499", 2000],
      ["$2,500 - $2,999", 2500],
      ["$3,000 - $3,499", 3000],
      ["$4,000 - $4,999", 4000],
      ["$5,000 - $5,999", 5000],
      ["$6,000 - $6,999", 6000],
      ["$7,000 - $7,999", 7000],
      ["$8,000 - $8,999", 8000],
      ["$9,000 or More", 9000]
    ]

  PAY_FREQUENCY = [
      ["Every Week", "WEEKLY"],
      ["Every Other Week", "BI_WEEKLY"],
      ["Once a Month", "MONTHLY"],
      ["Twice a Month", "TWICE_MONTHLY"]
    ]

  RELATIONSHIPS = [
      "Personal Friend",
      "Aunt",
      "Brother",
      "Brother-in-law",
      "Co-Worker",
      "Cousin",
      "Daughter",
      "Daughter-in-law",
      "Father",
      "Father-in-law",
      "Friend",
      "Mother",
      "Mother-in-law",
      "Nephew",
      "Niece",
      "Parent",
      "Sibling",
      "Sister",
      "Sister-in-law",
      "Son",
      "Son-in-law",
      "Stepbrother",
      "Stepdaughter",
      "Stepfather",
      "Stepmother",
      "Stepsister",
      "Stepson",
      "Uncle"
    ]

    MONTHS_AT = [["Less than 1 month", 0],
                 ["1 month", 1],
                 ["2 months", 2],
                 ["3 months", 3],
                 ["4 to 6 months", 6],
                 ["7 months to 1 year", 12],
                 ["1 year to 2 years", 24],
                 ["More than 2 years", 36]]

 


    US_STATES = [["Alaska", "AK"], ["Alabama", "AL"], ["Arkansas", "AR"], ["Arizona", "AZ"],
                 ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["District of Columbia", "DC"],
                 ["Delaware", "DE"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Iowa", "IA"],
                 ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Kansas", "KS"], ["Kentucky", "KY"],
                 ["Louisiana", "LA"], ["Massachusetts", "MA"], ["Maryland", "MD"], ["Maine", "ME"], ["Michigan", "MI"],
                 ["Minnesota", "MN"], ["Missouri", "MO"], ["Mississippi", "MS"], ["Montana", "MT"], ["North Carolina", "NC"],
                 ["North Dakota", "ND"], ["Nebraska", "NE"], ["New Hampshire", "NH"], ["New Jersey", "NJ"],
                 ["New Mexico", "NM"], ["Nevada", "NV"], ["New York", "NY"], ["Ohio", "OH"], ["Oklahoma", "OK"],
                 ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"],
                 ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Virginia", "VA"], ["Vermont", "VT"],
                 ["Washington", "WA"], ["Wisconsin", "WI"], ["West Virginia", "WV"], ["Wyoming", "WY"]]
  define_index do
    # fields
    indexes lead_provider.name, :as => :lead_provider, :sortable => true
    indexes first_name, :sortable => true
    indexes last_name, :sortable => true
    indexes email, :sortable => true
    indexes encrypted_ssn
    indexes ip_address
    indexes lead_source, :sortable => true
    indexes home_phone, :sortable => true
    indexes address
    indexes city, :sortable => true
    indexes state, :sortable => true
    indexes zip, :sortable => true
    indexes employer_name
#    indexes bank_name, :sortable => true
    indexes logs.message, :as => :logs

    # attributes
    has lead_provider_id, created_at, updated_at
  end
  
  attr_encrypted :ssn, :key => ENCRYPTION_KEY
  attr_encrypted :dl_number, :key => ENCRYPTION_KEY

  validates_presence_of :portfolio_id
  #validates_presence_of :requested_loan_amount, :if => Proc.new { |c| c.new_record? }
  validates_presence_of :lead_provider_id
  validates_presence_of :ip_address
  validates_format_of :ip_address, :with => /^(\d{1,3}\.){3}\d{1,3}$/
  validates_length_of :ip_address, :within => 7..20
  if RAILS_ENV == 'production'
    validates_exclusion_of :ip_address, :in => ["127.0.0.1", "0.0.0.0"]
  end
  validates_presence_of :lead_source, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :first_name
  validates_length_of :first_name, :maximum => 30
  validates_presence_of :last_name
  validates_length_of :last_name, :maximum => 30
  #validates_presence_of :ssn
  validates_inclusion_of :gender, :in => %w( m f ), :allow_blank => true
  validates_presence_of :email, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :email, :within => 6..50, :if => Proc.new { |c| c.strict_validation? }
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :if => Proc.new { |c| c.strict_validation? }
  validates_date :birth_date, :before => lambda { 18.years.ago + 1.day }, :before_message => "must be at least 18 years old", :if => Proc.new { |c| c.strict_validation? }
  #validates_presence_of :dl_number
  validates_presence_of :dl_state, :if => Proc.new { |c| c.strict_validation? }
  validates_inclusion_of :dl_state, :in => Common::US_STATES, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :home_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :home_phone, :is => 10, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :home_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :cell_phone, :is => 10, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :cell_phone, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :fax, :is => 10, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :fax, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :address, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :address, :maximum => 30, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :city, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :city, :maximum => 30, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :state, :if => Proc.new { |c| c.strict_validation? }
  validates_inclusion_of :state, :in => Common::US_STATES, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :zip, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :zip, :is => 5, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :zip, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :time_zone
  validates_presence_of :monthly_income
  validates_presence_of :income_source
  validates_inclusion_of :income_source, :in => %w( EMPLOYMENT BENEFITS )
  validates_presence_of :pay_frequency
  validates_inclusion_of :pay_frequency, :in => %w( WEEKLY BI_WEEKLY TWICE_MONTHLY MONTHLY )
  validates_presence_of :employer_name, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :employer_name, :maximum => 30, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :months_employed
  validates_length_of :employer_address, :maximum => 30, :allow_blank => true
  validates_length_of :employer_city, :maximum => 30, :allow_blank => true
  validates_inclusion_of :employer_state, :in => Common::US_STATES, :allow_blank => true
  validates_length_of :employer_zip, :is => 5, :allow_blank => true
  validates_numericality_of :employer_zip, :allow_blank => true
  validates_presence_of :employer_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :employer_phone, :is => 10, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :employer_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :employer_phone_ext, :maximum => 5, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :supervisor_name, :maximum => 30, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :supervisor_phone, :is => 10, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :supervisor_phone, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :supervisor_phone_ext, :maximum => 5, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :residence_type
  validates_inclusion_of :residence_type, :in => %w( RENT OWN )
  validates_presence_of :monthly_residence_cost
  validates_presence_of :months_at_address
  validates_length_of :landlord_name, :maximum => 50, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :landlord_phone, :is => 10, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :landlord_phone, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :landlord_address, :maximum => 30, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :landlord_city, :maximum => 30, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_inclusion_of :landlord_state, :in => Common::US_STATES, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :landlord_zip, :is => 5, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :landlord_zip, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_date :next_pay_date_1, :on_or_after => Date.today, :if => Proc.new { |c| c.strict_validation? }
  validates_date :next_pay_date_1, :on_or_before => (Date.today + 3.months), :if => Proc.new { |c| c.strict_validation? }
  validates_date :next_pay_date_2, :after => Proc.new { |c| c.next_pay_date_1 }, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :reference_1_name, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_1_name, :maximum => 50, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :reference_1_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_1_phone, :is => 10, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :reference_1_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_1_address, :maximum => 30, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_1_city, :maximum => 30, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_inclusion_of :reference_1_state, :in => Common::US_STATES, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_1_zip, :is => 5, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :reference_1_zip, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :reference_1_relationship, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :reference_2_name, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_2_name, :maximum => 50, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :reference_2_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_2_phone, :is => 10, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :reference_2_phone, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_2_address, :maximum => 30, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_2_city, :maximum => 30, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_inclusion_of :reference_2_state, :in => Common::US_STATES, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_length_of :reference_2_zip, :is => 5, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_numericality_of :reference_2_zip, :allow_blank => true, :if => Proc.new { |c| c.strict_validation? }
  validates_presence_of :reference_2_relationship, :if => Proc.new { |c| c.strict_validation? }
  validate :holidays_and_weekends, :if => Proc.new { |c| c.strict_validation? }
  validate :required_booleans
#  
  # AASM CONFIGURATION
  aasm_initial_state :not_purchased
  aasm_state :not_purchased
  aasm_state :purchased
  aasm_state :manually_entered
  
  aasm_event :mark_as_purchased do
    transitions :to => :purchased, :from => [:not_purchased]
  end
  
  ACCEPTED_RESPONSE_EXAMPLE = <<-EOF
  <?xml version="1.0"?>
  <response>
    <status>ACCEPTED</status> 
    <url>http://www.paydayloantracker.com/accepted/12345678</url>
  </response>
  EOF
  
  REJECTED_RESPONSE_EXAMPLE = <<-EOF
  <?xml version="1.0"?>
  <response>
    <status>REJECTED</status>
  </response>
  EOF
  
  DISABLED_RESPONSE_EXAMPLE = <<-EOF
  <?xml version="1.0"?>
  <response>
    <status>DISABLED</status>
  </response>
  EOF
  
  ERROR_RESPONSE_EXAMPLE = <<-EOF
  <?xml version="1.0"?>
  <response>
    <status>ERROR</status>
    <errors>
      <error>phone must be in xxxxxxxxxx format</error>
      <error>bank_name must be provided</error>
    </errors>
  </response>
  EOF
  
  REJECT_REASONS = ["Pay Frequency", "Monthly Income", "Payroll Type", "Duplicate SSN", "FactorTrust Score", "Min Loan Period", "Unacceptable Bank", "Age"]
  
  SAMPLE_CUSTOMER_PARAMS = {
    :username => "leadprovider",
    :password => "leadprovider",
    :port_key => "CGAOFZJ7HE",
    :force_post => "true",
    :is_test => "true",
    :lead_provider_id => "1",
    :ssn => '555555555',
    :dl_number => '1234567890',
    :portfolio_id => "1",
    :ip_address => "72.26.62.76",
    :lead_source => "raj",
    :tracker_id => "1300",
    :first_name => "Joe",
    :last_name => "Blow",
    :gender => "m",
    :email => "jblow@website.com",
    :birth_date => "1973-03-15",
    :dl_state => "UT",
    :military => "false",
    :home_phone => "8015551111",
    :cell_phone => "8015552222",
    :work_phone => "4794292255",
    :fax => "8015553333",
    :address => "123 Easy St",
    :city => "Herriman",
    :state => "UT",
    :zip => "84096",
    :country_code => "US",
    :monthly_income => "3250",
    :income_source => "EMPLOYMENT",
    :pay_frequency => "TWICEMONTHLY",
    :employer_name => "Wizbang Cogs, Inc",
    :occupation => "Technician",
    :months_employed => "7",
    :employer_address => "8131 Constitution Rd",
    :employer_city => "WestJordan",
    :employer_state => "UT",
    :employer_zip => "84088",
    :employer_phone => "8015554444",
    :employer_phone_ext => "",
    :supervisor_name => "Sally Stanford",
    :supervisor_phone => "8015555555",
    :supervisor_phone_ext => "",
    :residence_type => "RENT",
    :monthly_residence_cost => "1250",
    :months_at_address => "12",
    #:bank_name => "US Bank",
    #:bank_account_type => "CHECKING",
    #bank_aba_number : "012345678"
    #:bank_account_number => "99313",
    #:months_at_bank => "36",
    #:bank_direct_deposit => "y",
    #:bank_address => "1300 S Temple",
    #:bank_city => "Salt Lake City",
    #:bank_state => "UT",
    #:bank_zip => "89331",
    #:bank_phone => "8015556666",
    :next_pay_date_1 => "2009-10-30",
    :next_pay_date_2 => "2009-11-30",
    :reference_1_relationship => "COWORKER",
    :reference_1_name => "Gary Chattersworth",
    :reference_1_phone => "8015557777",
    :reference_1_address => "55 N Epson Ave",
    :reference_1_city => "Las Vegas",
    :reference_1_state => "NV",
    :reference_1_zip => "89147",
    :reference_2_relationship => "SIBLING",
    :reference_2_name => "Lionel Luther",
    :reference_2_phone => "8015558888",
    :reference_2_address => "118 Bloom St",
    :reference_2_city => "Sandy",
    :reference_2_state => "UT",
    :reference_2_zip => "83059",
    #loan_amount : "300"
    :credit_limit => "300"  }
  
  VERIFICATION_STATES = {
    0 => "incomplete",
    1 => "complete",
    2 => "na"
  }

  # Lifecycle callbacks

#  def before_validation
#    if new_record?
#      portfolio = Portfolio.find(self.portfolio_id)
#      self.max_loans_per_year = portfolio.max_loans_per_year
#    end
#  end

  def strict_validation?
    !self.relaxed_validation
  end

  def before_create
    setting = Setting.find(:first)
    self.credit_limit = setting.max_new_customer_credit_limit
  end
#  
  def after_create
#    if self.lead_source == 'internal'
      #Mailer.send_later :deliver_new_customer_welcome_letter, self unless self.is_test?
      unless self.is_test? || self.imported
        puts "SENDING WELCOME LETTER"
        Mailer.send_deliver_new_customer_welcome_letter(self)
      end

      # Create a loan associated with this customer.  The loan record is the loan application until it is approved.
      unless self.suppress_default_loan
        Loan.create!(
          :customer_id => self.id,
          :portfolio_id => self.portfolio_id,
          :requested_loan_amount => self.requested_loan_amount,
          :suppress_messages_after_create => self.suppress_messages_after_create
        )
      end

      # Create a bank account associated with this customer.
      bank_account = BankAccount.new(
        :customer_id => self.id,
        :bank_name => self.bank_name,
        :bank_account_type => self.bank_account_type,
        :bank_aba_number => self.bank_aba_number,
        :bank_account_number => self.bank_account_number,
        :months_at_bank => self.months_at_bank,
        :bank_direct_deposit => self.bank_direct_deposit,
        :bank_address => self.bank_address,
        :bank_city => self.bank_city,
        :bank_state => self.bank_state,
        :bank_zip => self.bank_zip,
        :bank_phone => self.bank_phone,
        :bank_account_balance => self.bank_account_balance,
        :funding_account => true
      )
      if bank_account.valid?
        bank_account.save!
        PaymentAccount.create!( :customer_id => self.id, :account_id => bank_account.id, :account_type => 'BankAccount')
      end
#    end
  end

  def accepted?
    !["not_purchased"].include? self.aasm_state
  end
  
  # login is the email address
  def self.authenticate(login, pass)
    customer = find_by_email(login)
    return customer if customer && customer.matching_password?(pass)
  end

  def matching_password?(pass)
    if self.password_hash
      return self.password_hash == encrypt_password(pass)
    end
    # Password is last 4 digits of SSN
    self.ssn[-4..-1] == pass
  end

  def combine_multi_part_fields
    self.ssn = "#{self.ssn_1}#{self.ssn_2}#{self.ssn_3}"
    self.home_phone = "#{self.home_phone_area_code}#{self.home_phone_prefix}#{self.home_phone_suffix}"
    self.work_phone =  "#{self.work_phone_area_code}#{self.work_phone_prefix}#{self.work_phone_suffix}"
    self.landlord_phone = "#{self.landlord_phone_area_code}#{self.landlord_phone_prefix}#{self.landlord_phone_suffix}"
    self.employer_phone = "#{self.employer_phone_area_code}#{self.employer_phone_prefix}#{self.employer_phone_suffix}"
    self.supervisor_phone = "#{self.supervisor_phone_area_code}#{self.supervisor_phone_prefix}#{self.supervisor_phone_suffix}"
    self.reference_1_phone = "#{self.ref1_phone_area_code}#{self.ref1_phone_prefix}#{self.ref1_phone_suffix}"
    self.reference_2_phone = "#{self.ref2_phone_area_code}#{self.ref2_phone_prefix}#{self.ref2_phone_suffix}"
  end
  
  def add_comment(msg, user)
    self.comments.create(:comment => msg, :user_id => user.id)
    self.logs << Log.new(:message => "#{user.full_name} added a comment.", :user => user)
  end

  def default_funding_bank_account
    self.bank_accounts.funding_accounts.first
  end

  def default_funding_payment_account
    default_funding_bank_account.payment_account
  end

  def default_payment_account
    default_funding_bank_account.payment_account
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def is_test?
    self.is_test == true
  end
  
  
  def age
    ((Date.today - self.birth_date) / 365).to_i
  end
  
  def display_gender
    if self.gender.blank?
      return "Unknown"
    else
      return {"m" => "Male", "f" => "Female"}[self.gender]
    end
  end
  
  def display_pay_frequency
    return {'WEEKLY' => 'Weekly', 'BIWEEKLY' => 'Bi-Weekly', 'TWICEMONTHLY' => 'Twice Monthly', 'MONTHLY' => 'Monthly'}[self.pay_frequency]
  end
  
  def passed_lead_filter_check?
    lead_provider = LeadProvider.find(self.lead_provider_id)
    lead_filter = lead_provider.lead_filter
    return lead_filter.pass? self
  end
  
  def pass_credit_check?
    lead_provider = LeadProvider.find(self.lead_provider_id)
    lead_filter = lead_provider.lead_filter
    ft = self.submit_to_factor_trust
    return (ft.score.to_i >= lead_filter.minimum_factor_trust_score)
  end
    
  def submit_to_factor_trust
    return FactorTrust.submit_to_factor_trust(self)
  end
  
  def submit_for_purchase
    if self.save
      
      self.logs << Log.new(:message => "Initial lead created")
      
      # Perform Lead Filter Check
      filter_errors = self.passed_lead_filter_check?
      if filter_errors.length == 0
        
        self.logs << Log.new(:message => "Passed lead provider filter checks")
        
        # Perform Credit Check (Factor Trust)
        if self.pass_credit_check?
          self.logs << Log.new(:message => "Passed initial credit checks")
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.response {
              xml.status "ACCEPTED"
              xml.url "https://www.paydayloantracker.com/loan_confirmation/#{self.signature_token}"
            }
          end
          mark_as_purchased!
          self.logs << Log.new(:message => "Returned ACCEPTED response to lead provider")
          
        else
          self.logs << Log.new(:message => "Did not pass credit checks")
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.response {
              xml.status "REJECTED"
              xml.errors ""
            }
          end
          self.logs << Log.new(:message => "Returned REJECTED response to lead provider")
        end

      # Did not pass lead filter validation
      else
        self.logs << Log.new(:message => "Did not pass lead filter validation")
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.response {
            xml.status "REJECTED"
            xml.errors {
              filter_errors.each do |e|
                xml.error "#{e}"
              end
            }
          }
        end
        self.logs << Log.new(:message => "Returned REJECTED response to lead provider")
      end
    
    # Unable to save customer - Return errors  
    else
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.response {
          xml.status "ERROR"
          xml.errors {
            self.errors.each do |k, v|
              xml.error "#{k} #{v}"
            end
          }
        }
      end
    end  
    return builder.to_xml
  end
  
  def populate_411_data
    [self.home_phone, self.cell_phone, self.employer_phone,
     self.supervisor_phone, self.landlord_phone, self.bank_phone,
     self.reference_1_phone, self.reference_2_phone].each do |phone|
       if !phone.blank? && phone.length == 10
         listings = FourOneOne.perform(phone)
         listings.each do |listing|
           begin
             self.customer_phone_listings.create!(
               :phone      => phone,
               :owner      => listing.owner,
               :title      => listing.title,
               :company    => listing.company,
               :address    => listing.address,
               :city       => listing.city,
               :state      => listing.state,
               :zip        => listing.zip,
               :line_type  => listing.line_type,
               :provider   => listing.provider
             )
           rescue Exception => e
             RAILS_DEFAULT_LOGGER.info "Caught Exception creating customer phone listing: #{e.message}"
           rescue => e
           end
         end
       end
    end
  end
  
  def full_address
    "#{address}, #{city}, #{state} #{zip}"
  end

  # New Payment Methods

  # xxxx_info_obj is required to have necessary methods used by these functions.  Will probably be ScheduledPayment.

  def add_bank_payment_method(bank_info_obj)
  end

  def add_credit_card_payment_method(card_info_obj)
  end

  # AuthorizeNet

  def cim_profile(gateway = nil, create_if_missing = false)
    gateway = get_authnet_cim_payment_gateway unless gateway
    # Create a customer profile if it doesn't exist
    unless authnet_customer_profile_id || !create_if_missing
      logger.info "about to create authnet customer profile, gateway: #{gateway.inspect}"
      description = RAILS_ENV == 'production' ? self.full_name : "TEST: #{self.full_name}"
      response = gateway.create_customer_profile(:profile => {:merchant_customer_id => self.id, :email => self.email, :description => description})
      logger.info "authnet response: #{response.inspect}"
      logger.info "response.success: #{response.success?}"
      logger.info "messages: #{response.params['messages'].inspect}"
      logger.info "message: #{response.params['messages']['message'].inspect}"
      unless response.success?
        logger.info "Raising AuthorizeNetError exception: #{response.params['messages']['message']['text']}"
        raise AuthorizeNetError.new('Code: '+response.params['messages']['message']['code'] + '<br />Message: ' + response.params['messages']['message']['text'])
      end
      logger.info "Didn't raise exception"
      self.authnet_customer_profile_id = response.params['customer_profile_id']
      save!
    end
    profile = nil
    if authnet_customer_profile_id
      response = gateway.get_customer_profile(:customer_profile_id => authnet_customer_profile_id)
      logger.info "get_customer_profile response: #{response.inspect}"
      profile = response.params['profile']
      logger.info "profile: #{profile.inspect}"
    end
    profile
  end

  # Time Zones

  def local_time
    tz = TZInfo::Timezone.get(self.time_zone)
    local = tz.utc_to_local(Time.now.utc)
    local
  end

  def utc_offset_hours
    tz = TZInfo::Timezone.get(self.time_zone)
    period_and_time = tz.current_period_and_time
    period = period_and_time[1]
    hours = period.utc_total_offset/3600
    hours
  end

  private

    def prepare_password
      unless password.blank?
        self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
        self.password_hash = encrypt_password(password)
      end
    end

    def encrypt_password(pass)
      Digest::SHA1.hexdigest([pass, password_salt].join)
    end
  
    def holidays_and_weekends
      if !self.next_pay_date_1.blank?
        if self.next_pay_date_1.is_holiday?
          errors.add(:next_pay_date_1, "cannot be on a holiday")
        elsif self.next_pay_date_1.is_weekend?
          errors.add(:next_pay_date_1, "cannot be on a weekend")
        end
      end
      if !self.next_pay_date_2.blank?
        if self.next_pay_date_2.is_holiday?
          errors.add(:next_pay_date_2, "cannot be on a holiday")
        elsif self.next_pay_date_2.is_weekend?
          errors.add(:next_pay_date_2, "cannot be on a weekend")
        end
      end
    end
    
    def required_booleans
      if self.military.nil?
        errors.add(:military, "must be provided")
      end
#      if self.bank_direct_deposit.nil?
#        errors.add(:bank_direct_deposit, "must be provided")
#      end
    end
    
    def self.requirements
      [
        [:ip_address, true, "20", "IP Address of Applicant (eg. 172.174.248.103)"],
        [:lead_source, true, "100", "Signup/registration URL of Applicant (e.g. www.domain.com)"],
        [:tracker_id, false, "", "Optional sub id to identify traffic source. Printable ASCII characters only"],
        [:first_name, true, "30", "Applicant's first name"],
        [:last_name, true, "30", "Applicant's last name"],
        [:ssn, true, "9", "Social Security Number. Numeric only"],
        [:gender, false, "1", "Permissable values: 'm', 'f'"],
        [:email, true, "50", "Email Address - Must be valid"],
        [:birth_date, true, "", "mm/dd/yyyy"],
        [:dl_number, true, "15", "Driver's License Number"],
        [:dl_state, true, "2", "Driver's License Issuing State"],
        [:military, true, "", "Permissable values: 'true', 'false'"],
        [:home_phone, true, "10", "10 digits. Numeric only"],
        [:cell_phone, false, "10", "10 digits. Numeric only"],
        [:fax, false, "10", "10 digits. Numeric only"],
        [:address, true, "30", "Applicant's home street address"],
        [:city, true, "30", "Applicant's home city"],
        [:state, true, "2", "Applicant's home state (eg. CO, UT, WI)"],
        [:zip, true, "2", "Applicant's home ZIP code. Numeric only"],
        [:monthly_income, true, "30", "Net Salary per month (after taxes, etc).  Numeric only"],
        [:income_source, true, "", "Permissible values: 'EMPLOYMENT', 'BENEFITS'"],
        [:pay_frequency, true, "", "Permissible values: 'WEEKLY', 'BIWEEKLY', 'TWICEMONTHLY', 'MONTHLY'"],
        [:employer_name, true, "30", "Name of employer"],
        [:occupation, false, "100", "Applicant's occupation"],
        [:months_employed, true, "", "Total months the customer has been employed with the indicated employer. Numeric only"],
        [:employer_phone, true, "10", "Employer's Phone Number. Numeric only"],
        [:employer_phone_ext, false, "5", "Employer's Phone Extension"],
        [:supervisor_name, false, "30", "Name of supervisor"],
        [:supervisor_phone, false, "10", "10 digits. Numeric only"],
        [:supervisor_phone_ext, false, "5", "Supervisor's Phone Extension"],
        [:residence_type, true, "", "Residence type (Permissable values: 'RENT', 'OWN')"],
        [:monthly_residence_cost, true, "", "Amount paid in mortgage or rent on a monthly basis. Numeric only"],
        [:months_at_address, true, "", "Total number of months the customer has resided at this address. Numeric only"],
        [:bank_name, true, "30", "Applicant's bank name"],
        [:bank_account_type, true, "", "Type of account (Permissable values: 'CHECKING', 'SAVINGS')"],
        [:bank_aba_number, true, "9", "Bank ABA Routing Number. Numeric only"],
        [:bank_account_number, true, "15", "Bank Account Number. Numeric only"],
        [:months_at_bank, true, "", "Total months the customer has been a bank member. Numeric only"],
        [:bank_direct_deposit, true, "", "Does the customer have direct deposit on this account (Permissable values: 'y', 'n')"],
        [:bank_phone, false, "10", "10 digits. Numeric only"],
        [:next_pay_date_1, true, "", "Next Payday. mm/dd/yyyy"],
        [:next_pay_date_2, true, "", "Payday after Next Payday. mm/dd/yyyy"],
#        [:loan_amount, true, "", "Requested loan amount, integer only, in whole dollars. (e.g. 300 for $300.00)"],
        [:reference_1_name, true, "50", "Reference #1 name"],
        [:reference_1_phone, true, "10", "Reference #1 phone number. Numeric only."],
        [:reference_1_relationship, true, "", "Permissible values: 'COWORKER', 'FRIEND', 'OTHER', 'PARENT', 'SIBLING'"],
        [:reference_2_name, true, "50", "Reference #2 name"],
        [:reference_2_phone, true, "10", "Reference #2 phone number. Numeric only."],
        [:reference_2_relationship, true, "", "Permissible values: 'COWORKER', 'FRIEND', 'OTHER', 'PARENT', 'SIBLING'"],
        [:is_test, false, "", "Permissable values: 'false', 'true'"]                 
      ]
    end
  
end
