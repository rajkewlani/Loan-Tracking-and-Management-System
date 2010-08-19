class Loan < ActiveRecord::Base
  include AASM
  include ActionView::Helpers::NumberHelper
  include AWS::S3
  require "pdf/writer"
  require "pdf/simpletable"
  require 'aws/s3'
  acts_as_loggable
  acts_as_commentable

  belongs_to :customer
  has_many :loan_transactions, :order => 'created_at'
  has_many :scheduled_payments, :order => 'draft_date'
  has_many :documents, :as => :docs
  has_many :ach_returns
  belongs_to :portfolio
  belongs_to :recission_bank_account, :class_name => 'BankAccount', :foreign_key => 'recission_bank_account_id'
  has_many :reminders

  validates_presence_of :customer_id, :portfolio_id, :requested_loan_amount, :signature_page_loan_amount, :signature_token
  validates_uniqueness_of :signature_token
  validates_inclusion_of :garnishment_telephone_status, :in => %w( no_answer left_message ), :allow_blank => true

  attr_accessor :suppress_messages_after_create

  named_scope :pending_signature, :conditions => "aasm_state = 'pending_signature'"
  named_scope :accepted, :conditions => "aasm_state in ('underwriting', 'no_reply', 'approved', 'denied')"
  named_scope :approved, :conditions => "aasm_state = 'approved'"
  named_scope :active, :conditions => "aasm_state = 'active'"
  named_scope :in_collections, :conditions => "aasm_state = 'collections'"
  named_scope :in_garnishments, :conditions => "aasm_state = 'garnishments'"
  named_scope :garnishment_sub_status, lambda { |*args|{:conditions => ["`loans`.aasm_state = 'garnishments' and garnishment_sub_status = ? and garnishments_agent_id=?",args[0],args[1].to_s],:include => :customer,:order =>'customers.last_name'}}
  named_scope :no_garnishment_sub_status, lambda { |*args|{:conditions => ["`loans`.aasm_state = 'garnishments' and garnishment_sub_status is null and garnishments_agent_id=? ",args[0].to_s],:include => :customer,:order =>'customers.last_name'}}
  named_scope :packet_confirmed, lambda { |*args|{ :conditions => ["`loans`.aasm_state = 'garnishments' and garnishment_fax_confirmed_at is not null and garnishments_agent_id=?",args[0].to_s],:include => :customer}}
  
  named_scope :loan_aasm_state, lambda { |*args|{:conditions => ["aasm_state in (?) and underwriter_id=? and funded_on is null",args[0],args[1].to_s],:include => :customer}}
  named_scope :loan_verification, lambda{|*args| {:conditions => ["verified_personal = ? and verified_financial = ? and verified_tila = ? and verified_employment_with_customer = ? and verified_employment_with_employer = ? and underwriter_id = ?",args[0].to_s,args[1].to_s,args[2].to_s,args[3].to_s,args[4].to_s,args[5].to_s],:include => :customer,:order=>'updated_at'}}
  

  # AASM CONFIGURATION
  aasm_initial_state :pending_signature
  aasm_state :pending_signature
  aasm_state :underwriting
  aasm_state :no_reply
  aasm_state :denied
  aasm_state :suspended
  aasm_state :approved
  aasm_state :active
  aasm_state :paid_in_full
  aasm_state :collections
  aasm_state :payment_plan
  aasm_state :garnishments
  aasm_state :pending_write_off
  aasm_state :written_off
  aasm_state :recission_requested
  aasm_state :recission_draft_submitted
  aasm_state :rescinded

  MSG_EVENT_OPTIONS = [['',''],
    ['Event1','Event1'],
    ['Event2','Event2'],
    ['Event3','Event3']
  ]

  REMARKS_OPTIONS = [
    ['',''],
    ['Ready to Finalize','Ready to Finalize'],
    ['Ready to Finalize/ Need E-Sign','Ready to Finalize/ Need E-Sign'],
    ['Need Bank Statement','Need Bank Statement'],
    ['Need Land Line Work Number','Need Land Line Work Number'],
    ['Sent Emp. Verification','Sent Emp. Verification']
  ]

  TRIGGER_EVENT = 'trigger_event'
  POINT_IN_TIME = 'point_in_time'

  # Fixed Points in Time
  CREATED_ON      = 'created_on'
  FUNDED_ON       = 'funded_on'
  DUE_DATE        = 'due_date'
  PAID_IN_FULL_ON = 'paid_in_full_on'
  COLLECTIONS_ON  = 'collections_on'
  GARNISHMENTS_ON = 'garnishments_on'

  # Events that can trigger message template sending
  PENDING_SIGNATURE           = 'pending_signature'
  UNDERWRITING                = 'underwriting'
  DENIED                      = 'denied'
  SUSPENDED                   = 'suspended'
  NO_REPLY                    = 'no_reply'
  APPROVED                    = 'approved'
  ACTIVE                      = 'active'
  PAID_IN_FULL                = 'paid_in_full'
  COLLECTIONS                 = 'collections'
  PAYMENT_PLAN                = 'payment_plan'
  GARNISHMENTS                = 'garnishments'
  WRITTEN_OFF                 = 'written_off'
  RECISSION_REQUESTED         = 'recission_requested'
  RECISSION_DRAFT_SUBMITTED   = 'recission_draft_submitted'
  RESCINDED                   = 'rescinded'
  PAYMENT_NSF                 = 'payment_nsf'
  PENDING_WRITE_OFF           = 'pending_write_off'
  FRAUD_ALERT                 = 'fraud_alert'
  NEED_EMPLOYMENT_INFO        = 'need_employment_info'
  PAYOFF_DRAFT_SUBMITTED      = 'payoff_draft_submitted'
  SCHEDULED_PAYMENT_SUBMITTED = 'scheduled_payment_submitted'
  PAYMENT_PLAN_CANCELLED      = 'payment_plan_cancelled'

  MESSAGE_TRIGGER_EVENTS = [
    ['',''],
    ['Pending signature',PENDING_SIGNATURE],
    ['Underwriting',UNDERWRITING],
    ['Denied',DENIED],
    ['Suspended',SUSPENDED],
    ['No reply',NO_REPLY],
    ['Approved',APPROVED],
    ['Active',ACTIVE],
    ['Paid in full',PAID_IN_FULL],
    ['Collections',COLLECTIONS],
    ['Payment Plan',PAYMENT_PLAN],
    ['Garnishments',GARNISHMENTS],
    ['Written off',WRITTEN_OFF],
    ['Recission requested',RECISSION_REQUESTED],
    ['Recission draft submitted',RECISSION_DRAFT_SUBMITTED],
    ['Rescinded',RESCINDED],
    ['Payment NSF',PAYMENT_NSF],
    ['Fraud Alert',FRAUD_ALERT],
    ['Need More Employment Info',NEED_EMPLOYMENT_INFO],
    ['Payoff Draft Submitted', PAYOFF_DRAFT_SUBMITTED],
    ['Payment Plan Cancelled', PAYMENT_PLAN_CANCELLED],
    ['Scheduled Payment Submitted', SCHEDULED_PAYMENT_SUBMITTED]
  ]

  LOAN_DISPOSITIONS = [
    ['please select',''],
    ['Send to garnishment',GARNISHMENTS],
    ['Payment plan',PAYMENT_PLAN],
    ['Paid in full',PAID_IN_FULL],
    ['Pending write off',PENDING_WRITE_OFF]

  ]

 

  aasm_event :mark_as_pending_signature do
    transitions :to => :pending_signature, :from => [:underwriting]
  end
  aasm_event :mark_as_underwriting do
    transitions :to => :underwriting, :from => [:pending_signature]
  end
  aasm_event :mark_as_no_reply do
    transitions :to => :no_reply, :from => [:underwriting]
  end
  aasm_event :mark_as_denied do
    transitions :to => :denied, :from => [:pending_signature,:underwriting]
  end
  aasm_event :mark_as_approved do
    transitions :to => :approved, :from => [:underwriting]
  end
  aasm_event :mark_as_suspended do
    transitions :to => :suspended, :from => [:pending_signature,:underwriting]
  end
  aasm_event :mark_as_active do
    transitions :to => :active, :from => [:approved, :recission_requested, :recission_draft_submitted]
  end
  aasm_event :mark_as_paid_in_full do
    transitions :to => :paid_in_full, :from => [:active, :collections, :payment_plan, :garnishments]
  end
  aasm_event :mark_as_collections do
    transitions :to => :collections, :from => [:active, :payment_plan]
  end
  aasm_event :mark_as_payment_plan do
    transitions :to => :payment_plan, :from => [:collections, :garnishments]
  end
  aasm_event :mark_as_pending_write_off do
    transitions :to => :pending_write_off, :from => [:collections, :garnishments]
  end
  aasm_event :mark_as_garnishments do
    transitions :to => :garnishments, :from => [:collections]
  end
  aasm_event :mark_as_written_off do
    transitions :to => :written_off, :from => [:garnishments, :collections]
  end

  aasm_event :mark_as_recission_requested do
    transitions :to => :recission_requested, :from => :active
  end
  aasm_event :mark_as_recission_draft_submitted do
    transitions :to => :recission_draft_submitted, :from => :recission_requested
  end
  aasm_event :mark_as_rescinded do
    transitions :to => :rescinded, :from => :recission_draft_submitted
  end

  def before_validation
    if new_record?
      unless self.imported
        # Start with limits from portfolio
        portfolio = Portfolio.find(self.portfolio_id)
        self.apr = portfolio.apr
        self.max_loan_amount = portfolio.max_loan_amount
        self.min_loan_days = portfolio.min_loan_days
        self.max_loan_days = portfolio.max_loan_days
        self.max_extensions = portfolio.max_extensions

        # National limits
        country = Country.find_by_code(customer.country_code)
        if country
          self.apr = country.max_apr if country.max_apr && country.max_apr < self.apr
          self.max_loan_amount = country.max_loan_amount if country.max_loan_amount && country.max_loan_amount < self.max_loan_amount
          self.min_loan_days = country.min_loan_days if country.min_loan_days && country.min_loan_days > self.min_loan_days
          self.max_loan_days = country.max_loan_days if country.max_loan_days && country.max_loan_days < self.max_loan_days
          self.max_extensions = country.max_extensions if country.max_extensions && country.max_extensions < self.max_extensions
        end

        # State limits
        state = State.find(:first, :conditions => ["code = ? and country_id = ?", customer.state,country.id])
        if state
          self.apr = state.max_apr if state.max_apr && state.max_apr < self.apr
          self.max_loan_amount = state.max_loan_amount if state.max_loan_amount && state.max_loan_amount < self.max_loan_amount
          self.min_loan_days = state.min_loan_days if state.min_loan_days && state.min_loan_days > self.min_loan_days
          self.max_loan_days = state.max_loan_days if state.max_loan_days && state.max_loan_days < self.max_loan_days
          self.max_extensions = state.max_extensions if state.max_extensions && state.max_extensions < self.max_extensions
        end

        self.signature_page_loan_amount = self.requested_loan_amount
        if self.signature_page_loan_amount > self.max_loan_amount
          self.signature_page_loan_amount = self.max_loan_amount
        end
        if self.customer.underwriter_id
          self.underwriter_id = self.customer.underwriter_id
          self.underwriter_type = 'User'
        end
      end
      generate_signature_token
    end
  end

  def after_create
    unless self.imported
      self.due_date = initial_due_date
      self.signature_page_finance_charge = projected_interest_on_due_date_for_proposed_loan
      self.principal_owed = 0
      self.interest_owed = 0
      self.fees_owed = 0
      self.save!
    end
    assign_to_next_underwriter unless self.underwriter_id unless imported
    unless suppress_messages_after_create
      puts "Sending Messages ..."
      @email_body = MessageTemplate.find_by_name("Application Received [AUTO]")
      temp_body = @email_body.body
      final_temp_body = temp_body.prep_for_eval
      customer = self.customer
      body = eval(final_temp_body)
      subject = @email_body.subject
      content_type = @email_body.content_type
      Mailer.deliver_loan_application_received(customer,subject,body,content_type)
    end
  end

  def garnishment_sub_status_display
    words = self.garnishment_sub_status.split('_')
    display = ''
    words.each do |word|
      display += ' ' unless display.blank?
      display += word.capitalize
    end
    display
  end
  
  def add_comment(msg, user)
    self.comments.create(:comment => msg, :user_id => user.id)
    self.logs << Log.new(:message => "#{user.full_name} added a comment.", :user => user) unless self.imported
  end

  def initial_due_date
    d = self.created_at + 7.days
    if self.created_at.wday == 6
      d = self.created_at + 6.days
    elsif self.created_at.wday == 0
      d = self.created_at + 5.days
    end
    if self.customer.next_pay_date_1 < d.to_date
      return self.customer.next_pay_date_2
    else
      return self.customer.next_pay_date_1
    end
  end
    
  def next_due_date
    # Next payday after current due date
    if(self.customer.pay_frequency == 'MONTHLY')
      due_date = self.due_date>>1
    elsif(self.customer.pay_frequency == 'WEEKLY')
      due_date = self.due_date + 1.week
    elsif(self.customer.pay_frequency == 'BI_WEEKLY')
      due_date = self.due_date + 2.weeks
    elsif(self.customer.pay_frequency == 'TWICE_MONTHLY')
      puts 'TWICE_MONTHLY'
      due_day = self.due_date.day
      due_month = self.due_date.month
      due_year = self.due_date.year
      
      pay_day_1 = self.customer.next_pay_date_1.day
      pay_day_2 = self.customer.next_pay_date_2.day

      pay_days = [pay_day_1,pay_day_2].sort

#      puts "pay_days: #{pay_days.inspect}"

      month = due_month
      year = due_year
#      puts "BEFORE: month: #{month} year: #{year}"
      if due_day >= pay_days[1]
#        puts "using first pay day (next month)"
        day = pay_days[0]
        month += 1
      else
#        puts "using next pay day (this month)"
        if due_day < pay_days[0]
          day = pay_days[0]
        else
          day = pay_days[1]
        end
        #day = pay_days[1]
      end
      if month > 12
        month = 1
        year += 1
      end

#      puts "AFTER: month: #{month} year: #{year}"
      due_date = Date.new(year,month,day)
    end
    due_date
  end
  
  def daily_interest_rate
    (self.apr/100.0)/365.0
  end

  def initial_total_of_payments
    self.signature_page_loan_amount + self.signature_page_finance_charge
  end

  def total_owed
    self.principal_owed + self.interest_owed + self.fees_owed
  end

  def proposed_loan_payoff_amount
    self.signature_page_loan_amount + projected_interest_on_due_date_for_proposed_loan
  end

  def payoff_amount
    self.principal_owed + interest_on(Date.today) + self.fees_owed
  end

  def payoff_amount_on(date)
    self.principal_owed + interest_on(date) + self.fees_owed
  end

  def next_payment
    next_payment_date = nil
    next_payment_amount = nil
    unless self.scheduled_payments.today_and_future.empty?
      next_payment_date = self.scheduled_payments.today_and_future.first.draft_date
      next_payment_amount = self.scheduled_payments.today_and_future.first.amount
    end
    if next_payment_date.nil?
      next_payment_date = self.due_date
      next_payment_amount = self.payoff_amount_on(due_date)
    end
    { :date => next_payment_date, :amount => next_payment_amount }
  end

  def calculated_interest_owed
    self.interest_owed
  end

  def is_funded?
    self.funded_on && self.approved_loan_amount && self.approved_loan_amount > 0
  end

  def projected_interest_on_due_date_for_proposed_loan
    raise Exception.new() unless ['pending_signature','underwriting','approved','collections','garnishments'].include? aasm_state
    days = self.due_date - Date.today
    (daily_interest_rate * signature_page_loan_amount.to_f * days.to_f).to_money
  end

  def projected_interest_on_date_for_proposed_loan(date)
    raise Exception.new() unless ['pending_signature','underwriting'].include? aasm_state
    days = date - Date.today
    (daily_interest_rate * signature_page_loan_amount.to_f * days.to_f).to_money
  end

  def projected_final_payment_on_date_for_proposed_loan(date)
    signature_page_loan_amount + projected_interest_on_date_for_proposed_loan(date)
  end

  def interest_on(interest_on_date)
    raise Exception.new('Loan must be funded in order to calculate interest') unless is_funded?
    raise Exception.new('Date for interest calculation must be on or after the funding date.') if interest_on_date < self.funded_on
    principal_last_changed_on = self.funded_on
    principal = 0
    total_interest = 0
    interest_payments = 0
    #    puts "Initial  principal #{principal} on #{self.funded_on}"
    #    puts "Daily interest rate: #{daily_interest_rate}"
    self.loan_transactions.each do |loan_transaction|
      break if loan_transaction.created_at.to_date > interest_on_date
      interest_payments += loan_transaction.interest
      if loan_transaction.principal != 0
        # Calculate interest since last change in principal
        days = loan_transaction.created_at.to_date - principal_last_changed_on
        interest_for_span = daily_interest_rate * principal * days
        total_interest += interest_for_span
        #        puts "  Principal changed #{loan_transaction.principal} on #{loan_transaction.created_at.to_date}"
        #        puts "  Interest on #{principal} for #{days} days = #{interest_for_span}"
        principal += loan_transaction.principal
        principal_last_changed_on = loan_transaction.created_at.to_date
      end
    end
    
    # Calculate interest since last date principal changed until target date
    days = interest_on_date - principal_last_changed_on
    #    puts "#{days} days from date of last change in principal to target date"
    #    puts "Multiplying: #{daily_interest_rate} * #{principal.to_f} * #{days.to_f}"
    interest_for_span = daily_interest_rate * principal.to_f * days.to_f
    #    puts "Interest since last change in principal: #{interest_for_span}"
    total_interest += interest_for_span

    #    puts "Total interest: #{total_interest}  Interest payments: #{interest_payments}"
    interest_owed = (total_interest + interest_payments).to_money
    #    puts "Interest owed on #{interest_on_date}: #{interest_owed}"
    interest_owed
  end


  # Calculate interest owed on a future date taking into account scheduled payments.
  def amounts_owed_on_date_assuming_scheduled_payments(date)
    raise Exception.new('Loan must be funded to calculate future interest owed assuming scheduled payments') unless ['active','collections','garnishments'].include? aasm_state and funded_on
    raise Exception.new('Cannot calculate anticipated interest for a date in the past') if date < Date.today
    raise Exception.new('Date for interest calculation must be on or after the funding date.') if date < self.funded_on
    if amounts_owed_updated_on < Date.today
      update_amounts_owed
    end

    # Iterate over scheduled payments from date balance last updated through the desired date
    hypothetical_principal = principal_owed
    hypothetical_principal_last_changed_on = amounts_owed_updated_on
    total_interest = 0
    interest_payments = 0
    hypothetical_fees_owed = fees_owed
    fee_payments = 0
    puts "Initial  principal #{hypothetical_principal} on #{hypothetical_principal_last_changed_on}"
    puts "Daily interest rate: #{daily_interest_rate}"
    scheduled_payments.each do |scheduled_payment|
      break if scheduled_payment.draft_date >= date
      interest_payments += scheduled_payment.interest
      fee_payments += scheduled_payment.fees
      if scheduled_payment.principal != 0
        days = scheduled_payment.draft_date - hypothetical_principal_last_changed_on
        interest_for_span = (daily_interest_rate * hypothetical_principal * days.to_f).to_money
        total_interest += interest_for_span
        puts "  Principal reduced by #{scheduled_payment.principal} on #{scheduled_payment.draft_date}"
        puts "  Interest on #{hypothetical_principal} for #{days} days = #{interest_for_span}"
        hypothetical_principal -= scheduled_payment.principal # All amounts on scheduled payments are >= 0
        hypothetical_principal_last_changed_on = scheduled_payment.draft_date
      end
    end

    # Calculate interest since last date hypothetical principal changed until target date
    days = date - hypothetical_principal_last_changed_on
    puts "#{days} days from date of last change in hypothetical principal to target date"
    puts "Multiplying: #{daily_interest_rate} * #{hypothetical_principal.to_f} * #{days.to_f}"
    interest_for_span = (daily_interest_rate * hypothetical_principal.to_f * days.to_f).to_money
    puts "Interest since last change in hypothetical principal: #{interest_for_span}"
    total_interest += interest_for_span

    interest_owed = (total_interest - interest_payments).to_money
    puts "Interest expected to be owing on #{date}: #{interest_owed}"
    hypothetical_fees_owed -= fee_payments
    { :total => hypothetical_principal+interest_owed+hypothetical_fees_owed, :principal => hypothetical_principal, :interest => interest_owed, :fees => hypothetical_fees_owed}
  end


  def amounts_owed_on_loan_payments(date)
    raise Exception.new('Cannot calculate anticipated interest for a date in the past') if date < Date.today
    raise Exception.new('Date for interest calculation must be on or after the funding date.') if date < self.funded_on
    if amounts_owed_updated_on < Date.today
      update_amounts_owed
    end

    # Iterate over scheduled payments from date balance last updated through the desired date
    hypothetical_principal = principal_owed
    hypothetical_principal_last_changed_on = amounts_owed_updated_on
    total_interest = 0
    interest_payments = 0
    hypothetical_fees_owed = fees_owed
    fee_payments = 0
    puts "Initial  principal #{hypothetical_principal} on #{hypothetical_principal_last_changed_on}"
    puts "Daily interest rate: #{daily_interest_rate}"

    # Calculate interest since last date hypothetical principal changed until target date
    days = date - hypothetical_principal_last_changed_on
    puts "#{days} days from date of last change in hypothetical principal to target date"
    puts "Multiplying: #{daily_interest_rate} * #{hypothetical_principal.to_f} * #{days.to_f}"
    interest_for_span = (daily_interest_rate * hypothetical_principal.to_f * days.to_f).to_money
    puts "Interest since last change in hypothetical principal: #{interest_for_span}"
    total_interest += interest_for_span

    interest_owed = (total_interest - interest_payments).to_money
    puts "Interest expected to be owing on #{date}: #{interest_owed}"
    hypothetical_fees_owed -= fee_payments
    { :total => hypothetical_principal+interest_owed+hypothetical_fees_owed, :principal => hypothetical_principal, :interest => interest_owed, :fees => hypothetical_fees_owed}
  end
  
  def update_amounts_owed
    subtotals = loan_transaction_subtotals
    RAILS_DEFAULT_LOGGER.info "SUBTOTALS - principal: #{number_to_currency(subtotals[:principal])} interest: #{number_to_currency(subtotals[:interest])} fees: #{number_to_currency(subtotals[:fees])}"
    self.principal_owed = subtotals[:principal]
    self.interest_owed = interest_on(Date.today)
    self.fees_owed = subtotals[:fees]
    self.amounts_owed_updated_on = Date.today
    save!
  end

  def loan_transaction_subtotals
    principal = 0
    interest = 0
    fees = 0
    loan_transactions.each do |loan_transaction|
      principal += loan_transaction.principal
      interest += loan_transaction.interest
      fees += loan_transaction.fees
    end
    { :principal => principal, :interest => interest, :fees => fees}
  end

  def scheduled_payment_subtotals(before_date = nil)
    principal = interest = fees = 0
    self.scheduled_payments.each do |scheduled_payment|
      break if before_date && scheduled_payment.draft_date >= before_date
      principal += scheduled_payment.principal
      interest  += scheduled_payment.interest
      fees      += scheduled_payment.fees
    end
    { :principal => principal, :interest => interest, :fees => fees }
  end

  def allocate_hypothetical_payment(amount,date)
    raise Exception.new('Date must not be in the past') if date < Date.today
    available_amount = amount

    total = 0
    allocated_to_principal = 0
    allocated_to_interest = 0
    allocated_to_fees = 0

    # Apply to fees
    if fees_owed > 0
      if available_amount >= fees_owed
        #allocated_to_fees = loan.fees
        allocated_to_fees = fees_owed
        available_amount -= fees_owed
      else
        allocated_to_fees = available_amount
        available_amount = 0
      end
    end

    # Apply to interest
    calculated_interest_owed = amounts_owed_on_date_assuming_scheduled_payments(date)[:interest]
    if calculated_interest_owed > 0
      if available_amount >= calculated_interest_owed
        allocated_to_interest = calculated_interest_owed
        available_amount -= calculated_interest_owed
      else
        allocated_to_interest = available_amount
        available_amount = 0
      end
    end

    # Apply to principal
    calculated_principal_owed = principal_owed - scheduled_payment_subtotals(date)[:principal]
    if calculated_principal_owed > 0
      if available_amount > calculated_principal_owed
        allocated_to_principal = calculated_principal_owed
        available_amount -= allocated_to_principal
      else
        allocated_to_principal = available_amount
        available_amount = 0
      end
    end

    # Adjust payment amount down if any available amount left over.
    # Excess shouldn't be possible given the validation but let's just be careful anyway.
    total = allocated_to_principal + allocated_to_interest + allocated_to_fees
    { :total => total, :principal => allocated_to_principal, :interest => allocated_to_interest, :fees => allocated_to_fees}
  end

  # For Loan Transaction

  def allocate_hypothetical_loan_payment(amount,date)
    raise Exception.new('Date must not be in the past') if date < Date.today
    available_amount = amount

    total = 0
    allocated_to_principal = 0
    allocated_to_interest = 0
    allocated_to_fees = 0

    # Apply to fees
    if fees_owed > 0
      if available_amount >= fees_owed
        #allocated_to_fees = loan.fees
        allocated_to_fees = fees_owed
        available_amount -= fees_owed
      else
        allocated_to_fees = available_amount
        available_amount = 0
      end
    end

    # Apply to interest
    calculated_interest_owed = amounts_owed_on_loan_payments(date)[:interest]
    if calculated_interest_owed > 0
      if available_amount >= calculated_interest_owed
        allocated_to_interest = calculated_interest_owed
        available_amount -= calculated_interest_owed
      else
        allocated_to_interest = available_amount
        available_amount = 0
      end
    end

    # Apply to principal
    calculated_principal_owed = principal_owed 
    if calculated_principal_owed > 0
      if available_amount > calculated_principal_owed
        allocated_to_principal = calculated_principal_owed
        available_amount -= allocated_to_principal
      else
        allocated_to_principal = available_amount
        available_amount = 0
      end
    end

    # Adjust payment amount down if any available amount left over.
    # Excess shouldn't be possible given the validation but let's just be careful anyway.
    total = allocated_to_principal + allocated_to_interest + allocated_to_fees
    { :total => total, :principal => allocated_to_principal, :interest => allocated_to_interest, :fees => allocated_to_fees}
  end


  def recalculate_scheduled_payments
    hypothetical_principal = principal_owed
    scheduled_payments.each do |scheduled_payment|
      RAILS_DEFAULT_LOGGER.info "hyp: #{hypothetical_principal} prin: #{scheduled_payment.principal}"
      if scheduled_payment.principal > hypothetical_principal
        scheduled_payment.principal = hypothetical_principal
        scheduled_payment.save
      end
      scheduled_payment.recalculate_interest_and_total
      hypothetical_principal -= scheduled_payment.principal
    end
  end

  def set_new_loan_amount_and_require_new_signature(approved_loan_amount)
    self.signature_page_loan_amount = self.principal_owed = approved_loan_amount
    self.signature_page_finance_charge = self.projected_interest_on_due_date_for_proposed_loan
    self.interest_owed = 0
    self.signature_page_accepted_at = nil
    self.signature_page_ip_address = nil
    self.signature_page_accepted_name = nil
    self.verified_tila = false
    self.disclosed_finance_charge_amount_at = nil
    self.disclosed_due_date_at = nil
    self.disclosed_apr_at = nil
    self.disclosed_extend_12_weeks_max_at = nil
    self.disclosed_partial_payments_at = nil
    self.disclosed_recission_at = nil
    self.disclosed_must_request_extensions_at = nil
    self.disclosed_member_area_at = nil
    mark_as_pending_signature!
  end

  def extend_to_next_payday!
    sp = ScheduledPayment.new
    sp.loan_id = self.id
    sp.customer_id = self.customer_id
    sp.payment_account_id = self.customer.default_payment_account.id
    sp.draft_date = self.due_date
    sp.principal = 0
    sp.interest = amounts_owed_on_date_assuming_scheduled_payments(due_date)[:interest]
    sp.fees = self.fees_owed
    sp.due_date_before_extension = self.due_date

    self.due_date = self.next_due_date
    Loan.transaction do
      sp.save!
      save!
    end
  end

  def assign_to_next_underwriter
    if next_underwriter = User.next_underwriter
      self.update_attribute(:underwriter_id, next_underwriter.id)
      self.logs << Log.new(:message => "Assigned to #{next_underwriter.full_name} (underwriter).")
      robot = User.find_by_username('robot')
      Comment.create(
        :comment => "Loan #{self.id} has been assigned to #{next_underwriter.full_name}",
        :commentable_id => self.id,
        :commentable_type => "Loan",
        :user_id => robot.id
      )
    end
  end

  def assign_to_next_collections_agent
    if next_collections_agent = User.next_collections_agent
      self.update_attribute(:collections_agent_id, next_collections_agent.id)
      self.logs << Log.new(:message => "Assigned to #{next_collections_agent.full_name} (collections agent).")
      robot = User.find_by_username('robot')
      Comment.create(
        :comment => "Loan #{self.id} has been assigned to #{next_collections_agent.full_name} (collections agent)",
        :commentable_id => self.id,
        :commentable_type => "Loan",
        :user_id => robot.id
      )
    else
      puts "No collections agent!"
    end
  end

  def assign_to_next_garnishments_agent
    if next_garnishments_agent = User.next_garnishment_agent
      self.update_attribute(:garnishments_agent_id, next_garnishments_agent.id)
      self.logs << Log.new(:message => "Assigned to #{next_garnishments_agent.full_name} (garnishments agent).")
      robot = User.find_by_username('robot')
      Comment.create(
        :comment => "Loan #{self.id} has been assigned to #{next_garnishments_agent.full_name} (garnishments agent)",
        :commentable_id => self.id,
        :commentable_type => "Loan",
        :user_id => robot.id
      )
    end
  end

  def sign_agreement(ip_address, signature_name,send_prerecorded_messages,send_sms_messages)
    Loan.transaction do
      self.signature_page_accepted_at = Time.now
      self.signature_page_ip_address = ip_address
      self.signature_page_accepted_name = signature_name
      self.save!
      mark_as_underwriting!
      self.customer.populate_411_data
      self.customer.send_prerecorded_messages = send_prerecorded_messages
      self.customer.send_sms_messages = send_sms_messages
      self.customer.save!
      assign_to_next_underwriter
    end
  end
  
  def pending_approval?
    ['underwriting', 'no_reply'].include? self.aasm_state
  end

  def all_tila_disclosures_made?
    if  (self.disclosed_finance_charge_amount_at &&
          self.disclosed_due_date_at &&
          self.disclosed_apr_at &&
          self.disclosed_extend_12_weeks_max_at &&
          self.disclosed_partial_payments_at &&
          self.disclosed_recission_at &&
          self.disclosed_must_request_extensions_at &&
          self.disclosed_member_area_at)
      return true
    end
    false
  end

  def underwriter
    if self.underwriter_id
      @underwriter ||= User.find(self.underwriter_id)
    else
      nil
    end
  end

  def collections_agent
    if self.collections_agent_id
      @collections_agent ||= User.find(self.collections_agent_id)
    else
      nil
    end
  end

  def garnishments_agent
    if self.garnishments_agent_id
      @garnishments_agent ||= User.find(self.garnishments_agent_id)
    else
      nil
    end
  end

  def accepted?
    !["not_purchased"].include? self.aasm_state
  end

  def verified_employment?
    self.verified_employment_with_customer && self.verified_employment_with_employer ? true : false
  end

  def verification_complete?
    return (self.verified_personal &&
        self.verified_financial &&
        self.verified_employment_with_customer &&
        self.verified_employment_with_employer &&
        self.verified_tila)
  end

  def ready_for_approval_or_rejection?
    return (self.verification_complete? == true && (['underwriting', 'no_reply'].include? self.aasm_state))
  end
  
  def mark_as_approved(current_user, send_messages = true)
    self.approved_loan_amount = signature_page_loan_amount
    self.principal_owed = 0
    self.interest_owed = 0
    self.fees_owed = 0
    self.approved_by = current_user.id
    self.approved_at = Date.today
    self.mark_as_approved!
    self.logs << Log.new(:message => "#{current_user.full_name} approved this loan for $#{approved_loan_amount}.00.", :user => current_user)
    if send_messages
      MessageTemplate.deliver_messages_for_event(self,APPROVED)
    end
  end

  def mark_as_denied(reject_reason, current_user, send_messages = true)
    self.update_attribute(:reject_reason, reject_reason)
    self.mark_as_denied!
    self.logs << Log.new(:message => "#{current_user.full_name} denied this loan due to #{reject_reason}.", :user => current_user)
    if send_messages
      MessageTemplate.deliver_messages_for_event(self,DENIED)
    end
  end

  def mark_as_collections(send_messages = true)
    self.collections_on = Date.today
    self.mark_as_collections!
    assign_to_next_collections_agent
    self.logs << Log.new(:message => "Defaulted and referred to collections.")
    if send_messages
      MessageTemplate.deliver_messages_for_event(self,COLLECTIONS)
    end
  end

  def mark_as_payment_plan(send_messages = true)
    self.mark_as_payment_plan!
    self.logs << Log.new(:message => "Payment plan initiated")
    if send_messages
      MessageTemplate.deliver_messages_for_event(self,PAYMENT_PLAN)
    end
  end

  def mark_as_pending_write_off(current_user, send_messages = true)
    self.mark_as_pending_write_off!
    self.logs << Log.new(:message => "Pending Write Off", :user => current_user)
    if send_messages
      MessageTemplate.deliver_messages_for_event(self,PENDING_WRITE_OFF)
    end
  end

  def mark_as_paid_in_full(send_messages = true)
    self.paid_in_full_on = Date.today
    self.mark_as_paid_in_full!
    self.logs << Log.new(:message => "#{self.full_name} has paid the loan in full")
    if send_messages
      MessageTemplate.deliver_messages_for_event(self,PAID_IN_FULL)
    end
  end

  def mark_as_garnishments(current_user, send_messages = true)
    self.garnishments_on = Date.today
    self.mark_as_garnishments!
    assign_to_next_garnishments_agent
    self.logs << Log.new(:message => "#{current_user.full_name} referred this loan to garnishments.", :user => current_user)
    if send_messages
      send_garnishment_packet(current_user) if garnishment_allowed?
      MessageTemplate.deliver_messages_for_event(self,GARNISHMENTS)
    end
  end

  def garnishment_allowed?
    country = Country.find(:first, :conditions => ["code = ?",customer.country_code])
    puts "country: #{country}"
    customer_state = State.find(:first, :conditions => ["code = ? and country_id = ?",customer.state,country.id])
    puts "customer_state: #{customer_state}"
    if customer_state
      return false unless customer_state.garnishment_allowed
    end
    employer_state = State.find(:first, :conditions => ["code = ? and country_id = ?",customer.employer_state,country.id])
    puts "employer_state: #{employer_state}"
    if employer_state
      return false unless employer_state.garnishment_allowed
    end
    employer = Employer.find(:first, :conditions => ["name_normalized = ? and state_code = ?",customer.employer_name.downcase,customer.employer_state])
    puts "employer: #{employer}"
    if employer
      return false unless employer.will_garnish
    end
    true
  end

    
  def send_garnishment_packet(current_user)
    if customer.employer_fax.blank?
      self.logs << Log.new(:message => "Attempted to send garnishment fax but no employer fax is given", :user => current_user)
      return
    end
    pdf = garnishment_pdf

    #Upload Pdf to Amazon and Save Pdf Data to Document Table
    pdf_document = Document.create!(
      :loan_id => self.id,
      :customer_id => self.customer.id,
      :owner_type => "Loan",
      :description => "Garnishhment pdf for loan",
      :content_type => "application/pdf",
      :size => pdf.size,
      :filename => "garnishment_loan.pdf"
    )
    upload_pdf_to_amazon(pdf,pdf_document.id)

    tila_pdf_document = tila_pdf('127.0.0.1',current_user)
    my_mail = Mailer.create_notify_employer_about_loan_garnishment(self,pdf.render,tila_pdf_document)
    Mailer.deliver(my_mail)
    self.garnishment_packet_sent_at = Time.now
    self.garnishment_sub_status = "packet_sent"
    self.garnishment_fax_attempts += 1
    save
    self.logs << Log.new(:message => "Garnishment packet sent to #{self.customer.employer_fax.using('###-###-####')} at #{Time.now.to_s(:day_date_time)}", :user => current_user)
  end

  def upload_pdf_to_amazon(pdf,doc_id)
    bucket = "#{AMAZON_S3_CONFIG[:bucket_name]}/documents/#{doc_id}"
    mime_type = "application/pdf"
    AWS::S3::Base.establish_connection!(
      :access_key_id     => AMAZON_S3_CONFIG[:access_key_id],
      :secret_access_key => AMAZON_S3_CONFIG[:secret_access_key]
    )

    AWS::S3::S3Object.store(
      "garnishment_loan.pdf",
      pdf.to_s,
      bucket,
      :content_type => mime_type,
      :access => :public_read
    )

  end

  def self.tg
    loan = Loan.find(:first, :conditions => ["aasm_state = 'garnishments'"])
    puts "Loan id: #{loan.id}"
    loan.save_garnishment_pdf
  end
  
  def save_garnishment_pdf
    pdf = garnishment_pdf
    pdf.save_as "#{RAILS_ROOT}/tmp/garnishment.pdf"
  end

  def garnishment_pdf
    fax_pdf = PDF::Writer.new(:paper =>"A4")
    fax_pdf.font_height(12)
    fax_pdf = information_page(fax_pdf)
    return fax_pdf
  end

  def information_page(fax_pdf)
    fax_pdf.select_font "Times-Roman"


    fax_pdf.image("#{RAILS_ROOT}/public/images/flobridge_logo.png",:resize=>0.5, :justification => :center)


    fax_pdf.text "Fax",:font_size=>50,:justification=>:left
    fax_pdf.move_pointer(40)

    fax_pdf.text "Fax Number:"   + customer.employer_fax.using('###-###-####'),:font_size=>12
    fax_pdf.move_pointer(15)
    fax_pdf.text "Date:"         +       Date.today.to_s(:sm_d_y)
    fax_pdf.move_pointer(15)
    fax_pdf.text "Pages:"        + "10"
    fax_pdf.move_pointer(15)
    fax_pdf.text customer.supervisor_name unless customer.supervisor_name.blank?
    fax_pdf.text customer.employer_name unless customer.employer_name.blank?
    fax_pdf.text customer.employer_address unless customer.employer_address.blank?
    city_state_zip = ''
    unless customer.employer_city.blank?
      city_state_zip += "#{customer.employer_city}, "
    end
    city_state_zip += "#{customer.employer_state}  #{customer.employer_zip}"
    fax_pdf.text city_state_zip
    fax_pdf.move_pointer(15)
    fax_pdf.text "Re: Employee Garnishment"
    fax_pdf.move_pointer(30)
    fax_pdf.text "Attached you will find the garnishment documentation regarding an employee currently in default (for privacy reasons, details are given on subsequent pages). Please help us to bring your employee back into good standing.  In order to assist you, we have included the following:"
    fax_pdf.move_pointer(15)
    fax_pdf.text "1.  Important notice to employers", :left => 20
    fax_pdf.text "2.  Wage garnishment notice", :left => 20
    fax_pdf.text "3.  Wage garnishment worksheet", :left => 20
    fax_pdf.text "4.  Employer certification", :left => 20
    fax_pdf.text "5.  Relevant contracts and/or agreements", :left => 20
    fax_pdf.move_pointer(20)
    fax_pdf.text "Thank you for your help in this matter."
    fax_pdf.move_pointer(20)
    fax_pdf.text "Sincerely,"
    fax_pdf.text "<b>Garnishment Department</b>"
    fax_pdf.move_pointer(20)
    fax_pdf.text "FloBridge Group"
    fax_pdf.text "Email: service@flobridge.com"
    fax_pdf.text "Toll Free: 866-569-3321"
    fax_pdf.text "Fax: 801-852-1365"
    fax_pdf.move_pointer(20)
    fax_pdf.text "691 West 1200 North Ste 100"
    fax_pdf.text "Springville, Utah 84663"
    fax_pdf.move_pointer(50)
    fax_pdf.text "Phone:  1-866-569-3321 | Fax: 801.852.1365 | 691 West 1200 North Suite 100 Springville, Utah 84463 | www.flobridge.com", :font_size => 9, :justification => :center

    fax_pdf.start_new_page

    fax_pdf.move_pointer(15)
    fax_pdf.text "<c:uline><b>IMPORTANT NOTICE TO EMPLOYER</b><c:uline>", :font_size => 12, :justification => :center
    fax_pdf.move_pointer(50)
    fax_pdf.text "#{customer.full_name} indicated that he/she is employed with your company, and now owes a delinquent debt to FloBridge Group. State Statutes permit agencies to garnish the pay of individuals who owe such debt without first obtaining a court order."
    fax_pdf.move_pointer(20)
    fax_pdf.text "Enclosed is a Wage Assignment Garnishment agreement as well as instructions directing you to withhold a portion of the employee's pay each pay period and to forward those amounts to FloBridge Group. Per our contractual agreement, this employee has agreed to the wage assignment and we have previously notified the employee that this action was going to take place.  We have provided the employee with the opportunity to dispute the debt."
    fax_pdf.move_pointer(20)
    fax_pdf.text "A Wage Garnishment Worksheet is enclosed to assist you in determining the proper amount to withhold."
    fax_pdf.move_pointer(20)
    fax_pdf.text "Please read the enclosed documents carefully. They contain important information concerning your responsibilities to comply with this Wage Garnishment. If you have any questions, please call the account specialist listed below."
    fax_pdf.move_pointer(30)
    fax_pdf.text "Thank you for your cooperation."
    fax_pdf.move_pointer(20)
    fax_pdf.text "<b>Garnishment Department</b>"
    fax_pdf.text "FloBridge Group"
    fax_pdf.move_pointer(30)

    summary_table = PDF::SimpleTable.new
    summary_table.font_size = 12
    summary_table.title = '<b>GARNISHMENT ASSIGNMENT</b>'
    summary_table.column_order.push(*%w(col1 col2))
    summary_data = [
      {'col1' => "Date: #{Date.today.to_s(:sm_d_y)}", 'col2' => "Loan Number: #{self.id}"},
      {'col1' => "Employee: #{customer.full_name}", 'col2' => "Acct. Specialist: #{garnishments_agent.full_name}"},
      {'col1' => "Employee SSN: #{customer.ssn.using('###-##-####')}", 'col2' => "Email: service@flobridge.com"},
      {'col1' => "Total Owed: #{number_to_currency(total_owed)}", 'col2' => "Toll Free: (866) 569-3321"},
      {'col1' => ' ', 'col2' => "Fax: (801) 852-1365"},
      {'col1' => "Employer: #{customer.employer_name}", 'col2' => " "},
      {'col1' => "Fax: #{customer.employer_fax.using('###-###-####')}", 'col2' => "FloBridge Group"},
      {'col1' => "Address: #{customer.employer_address}", 'col2' => "691 W. 1200 N., Ste. 100"},
      {'col1' => "Address: #{customer.employer_city}, #{customer.employer_state}  #{customer.employer_zip}", 'col2' => "Springville, UT  84663"},
      {'col1' => ' ', 'col2' => ' '},
      {'col1' => "*Note: The amount due may increase as a\nresult of additional interest penalties and\nother costs assessed over time.", 'col2' => ''}
    ]

    summary_table.data.replace summary_data
    summary_table.show_lines = :outer
    summary_table.shade_rows = :none
    summary_table.show_headings = false
    summary_table.render_on(fax_pdf)

    fax_pdf = wage_garnishment(fax_pdf)

    return fax_pdf
  end

  def wage_garnishment(fax_pdf)

    fax_pdf.select_font "Times-Roman"

    fax_pdf.start_new_page

    fax_pdf.text "<c:uline><b>Section 1:</b><c:uline> YOU, the Employer, are hereby assigned to deduct from all disposable pay paid by you to the Employee the Wage Garnishment Amount described above in Amount Due of this Garnishment. You are to begin deductions on the first pay day after you receive this Wage Garnishment. If the first pay day is within 10 days after you receive this, you may begin deductions on the second pay day after you receive this. You are to continue deductions until amount noted above is paid in full.\n\n <c:uline><b>Please, mail checks to:</b><c:uline>",:justification=>:full
    fax_pdf.move_pointer(30)
    fax_pdf.text "<b>FloBridge Group</b>, 691 West 1200 North, Ste 100, Springville,UT 84663",:justification=>:center, :font_size => 15
    fax_pdf.move_pointer(30)
    fax_pdf.text "<b>Section 2: Wage Garnishment Amount.</b>", :font_size => 12
    fax_pdf.move_pointer(15)

    fax_pdf.text "A. The Wage Garnishment Amount is $___________per pay period in accordance with an agreement between FloBridge Group and the employee."
    fax_pdf.move_pointer(20)
    fax_pdf.text "<b>OR (if blank)</b>",:justification=>:center
    fax_pdf.move_pointer(20)
    fax_pdf.text "B.	  The Wage Garnishment Amount for each pay period is the lesser of:"
    fax_pdf.move_pointer(10)
    fax_pdf.text "(a)	  15% of the Employee's disposable pay (not to exceed 15%) \n\n",:left=>20
    fax_pdf.text "(b)	  25% of the Employee's disposable pay less the amounts withheld under the withholding with priority.\n\n",:left=>20
    fax_pdf.move_pointer(10)
    fax_pdf.text "<i>Note:</i> A Wage Garnishment Worksheet has been provided for employers on the following page", :justification => :center
    fax_pdf.move_pointer(20)
    fax_pdf.text "<b>Section 3. Definitions.</b>"
    fax_pdf.move_pointer(20)
    fax_pdf.text "<b>Disposable Pay.</b> For purposes of the Wage Garnishment, \"disposable pay\" means the employee's compensation (including, but not limited to, salary, overtime, bonuses, commissions, sick leave and vacation pay) from an employer after the deduction of health insurance premiums and any amounts required by law to be withheld. Proper deductions include Federal, State, and local taxes, State unemployment and disability taxes, social security taxes, and involuntary pension contributions, but do not include voluntary pension, retirement plan contributions, or union dues. A Wage Garnishment Worksheet is included to assist employers in calculating disposable pay and the wage garnishment amount.\n\n",:justification=>:full
    fax_pdf.text "<b>Multiple Withholding.</b> If in addition to this Wage Garnishment, an employer is served with other withholding orders pertaining to the same employee, then sufficient amounts may be withheld to satisfy the multiple withholdings simultaneously up to the maximum noted in Section 2. Wage Garnishments should be paid in the order they are received EXCEPT that family support garnishments should always be paid first.\n\n",:justification=>:full
    fax_pdf.text "<b>Pay cycles.</b> An employer is not required to vary its normal pay and disbursement cycles to comply with the Wage Garnishment.",:justification=>:full

    certification = employer_certification(fax_pdf)
#    garnishment_worksheet = wage_garnishment_worksheet(fax_pdf)

#    fax_pdf = wage_garnishment_amount(fax_pdf)

    return fax_pdf
  end

  def wage_garnishment_worksheet(fax_pdf)

    fax_pdf.start_new_page
    fax_pdf.select_font('Helvetica')
    fax_pdf.text "<c:uline><b>WAGE GARNISHMENT WORKSHEET</b><c:uline>\n", :font_size => 18
#    fax_pdf.move_pointer(20)
    fax_pdf.text "<b>Notice to Employers:</b>The Employer may use a copy of this Worksheet each pay period to calculate the Wage Garnishment Amount to be deducted from the debtor's disposable pay. Disposable pay includes, but is not limited to, salary, overtime, bonuses, commissions, sick leave and vacation pay. <b>If an amount was specified in section 2-A above, employers do not need to complete this Worksheet.</b>", :font_size => 8, :left => 5
    fax_pdf.move_pointer(10)

    fax_pdf.move_pointer(10)
    fax_pdf.text "<b>Step 1. Disposable Pay Computation</b>", :font_size => 14
    fax_pdf.select_font 'Times-Roman'

    disposable_pay_table = PDF::SimpleTable.new
    disposable_pay_table.font_size = 12
    disposable_pay_table.column_order.push(*%w(col1 col2 col3))

    disposable_pay_table.width = 450
    disposable_pay_table.position = 45
    disposable_pay_table.orientation = :right
    disposable_pay_table.shade_rows     = :none
    disposable_pay_table.show_headings = false



    disposable_pay_table.show_lines     = :all


    data = [
      {"col1" => "1","col2"=>"Gross amount paid to employee per pay period","col3"=>"$                    " },
      {"col1" => "2","col2"=>"Amounts Withheld","col3"=>"" },
      {"col1" => "","col2"=>"a. Federal income tax","col3"=>"" },
      {"col1" => "","col2"=>"b. FICA (Social Security)","col3"=>"" },
      {"col1" => "","col2"=>"c. Medicare","col3"=>"" },
      {"col1" => "","col2"=>"d. State taxes (income tax, unemployment, disability)","col3"=>"" },
      {"col1" => "","col2"=>"e. City/Local taxes","col3"=>"" },
      {"col1" => "","col2"=>"f. Health insurance premiums","col3"=>"" },
      {"col1" => "","col2"=>"g. Involuntary retirement or pension plan payments","col3"=>"" },
      {"col1" => "3","col2"=>"Total allowable deductions (ADD lines <b>a</b> through <b>g</b>)","col3"=>"$" },
      {"col1" => "4","col2"=>"<b>DISPOSABLE PAY</b> (SUBTRACT line 3 from line 1)","col3"=>"$" }
    ]

    disposable_pay_table.data.replace data
    disposable_pay_table.render_on(fax_pdf)

    fax_pdf.move_pointer(10)
    fax_pdf.select_font('Helvetica')
    fax_pdf.text "<b>Step 2. Wage Garnishment Amount</b>", :font_size => 14
    fax_pdf.move_pointer(5)
    fax_pdf.text "If the Employee's wages are not subject to any withholding with priority, skip to line 8.",:font_size=>8
    fax_pdf.select_font 'Times-Roman'
    fax_pdf.move_pointer(10)

    wage_garnishment_amount_calculation = PDF::SimpleTable.new
    wage_garnishment_amount_calculation.font_size = 12
    wage_garnishment_amount_calculation.column_order.push(*%w(col1 col2 col3))

    wage_garnishment_amount_calculation.shade_rows     = :none

    wage_garnishment_amount_calculation.width = 450
    wage_garnishment_amount_calculation.position = 45
    wage_garnishment_amount_calculation.orientation = :right
    wage_garnishment_amount_calculation.show_headings = false



    wage_garnishment_amount_calculation.show_lines     = :all


    data = [
      {"col1" => "5","col2"=>"25% of Disposable Pay (MULTIPLY line 4 by 0.25)","col3"=>"$                    " },
      {"col1" => "6","col2"=>"Total amounts withheld under other wage \n withholding. (see section 2-B)","col3"=>"" },
      {"col1" => "7","col2"=>"SUBTRACT line 6 from line 5 (enter zero if negative)","col3"=>"" },
      {"col1" => "8","col2"=>"MULTIPLY line 4 by 0.15","col3"=>"" },
      {"col1" => "9","col2"=>"30 times the Federal Minimum Wage of $7.25","col3"=>"" },
      {"col1" => "","col2"=>"a. paid weekly or less, use $217.50","col3"=>"" },
      {"col1" => "","col2"=>"b. paid every other week, use $435.00","col3"=>"" },
      {"col1" => "","col2"=>"c. paid twice a month, use $471.25","col3"=>"" },
      {"col1" => "","col2"=>"d. paid monthly, use $942.50","col3"=>"" },
      {"col1" => "10","col2"=>"SUBTRACT line 9 from line 4 (enter zero if negative)","col3"=>"$" },
      {"col1" => "11","col2"=>"<b>WAGE GARNISHMENT AMOUNT</b> \n Enter the smalles of lines 7, 8, or 10","col3"=>"$" }
    ]

    wage_garnishment_amount_calculation.data.replace data
    wage_garnishment_amount_calculation.render_on(fax_pdf)

    certification = employer_certification(fax_pdf)
    return fax_pdf
  end

  def employer_certification(fax_pdf)

    fax_pdf.select_font "Times-Roman"

    fax_pdf.start_new_page
    fax_pdf.move_pointer(10)
    fax_pdf.text "<b>EMPLOYER CERTIFICATION</b>",:justification => :center,:font_size => 14
    fax_pdf.move_pointer(10)
    fax_pdf.text "<b>EMPLOYERS ARE REQUIRED TO COMPLETE AND RETURN THIS CERTIFICATION TO FLOBRIDGE WITHIN 10 DAYS OF RECEIPT</b>",:font_size => 11
    fax_pdf.move_pointer(10)

#    date_table = PDF::SimpleTable.new
#    date_table.column_order.push(*%w(date))
#    data = [
#      {'date' => "Date:\n#{Date.today.to_s(:sm_d_y)}"}
#    ]
#    date_table.position = 45
#    date_table.orientation = :right
#    date_table.data.replace data
#    date_table.render_on(fax_pdf)
    fax_pdf.text "Date: #{Date.today.to_s(:sm_d_y)}"
    fax_pdf.move_pointer(5)
    employee_table = PDF::SimpleTable.new
    employee_table.column_order.push(*%w(col1 col2))
    employee_table.show_headings = false
#    employee_table.title = "Date:\n#{Date.today.to_s(:sm_d_y)}"
    employee_table.shade_rows = :none

    data = [
      {'col1' => "Employee:\n\n#{customer.full_name}", 'col2' => "Employee SSN:\n\n#{customer.ssn.using('###-##-####')}"}
    ]

    employee_table.width = 500
    employee_table.position = 40
    employee_table.orientation = :right
    employee_table.data.replace data
    employee_table.render_on(fax_pdf)

    fax_pdf.move_pointer(10)
    fax_pdf.text "<i>To be completed by employer:</i>",:font_size => 10
    fax_pdf.move_pointer(10)

    reminder_of_certification_table = PDF::SimpleTable.new
    reminder_of_certification_table.font_size = 12
    reminder_of_certification_table.column_order.push(*%w(col1 col2))


    data = [
      {"col1" => "Date Received:\n\n ", "col2" => nil},
      {"col1" => "Employer:\n\n ", "col2" => "Employer EIN/TIN:\n\n " },
    ]

    reminder_of_certification_table.width = 500
    reminder_of_certification_table.position = 40
    reminder_of_certification_table.orientation = :right
    reminder_of_certification_table.shade_rows     = :none
    reminder_of_certification_table.show_headings = false

    reminder_of_certification_table.data.replace data

    reminder_of_certification_table.show_lines     = :all
    reminder_of_certification_table.render_on(fax_pdf)
    fax_pdf.move_pointer(20)

    fax_pdf.text "Check one:"
    fax_pdf.move_pointer(20)
    fax_pdf.text "____ The above named employee is <b>currently employed</b> with this employer"
    fax_pdf.move_pointer(10)
    fax_pdf.text "<b>OR</b>", :left => 150
    fax_pdf.move_pointer(10)
    fax_pdf.text "____ The above named employee is <b>no longer employed</b> with this employer"
    fax_pdf.move_pointer(20)
    fax_pdf.text "<b><i>If the employee is no longer employed with this Employer, please complete the following:</i></b>"
    fax_pdf.move_pointer(5)

    certification_table = PDF::SimpleTable.new
    certification_table.font_size = 12
    certification_table.column_order.push(*%w(col1 col2))


    data = [
      {"col1" => "Employment Termination Date:\n\n ", "col2" => "Employee's current employer (if known)\n\n "},
      {"col1" => "Employee's last known address and telephone:\n\n\n\n\n\n ", "col2" => "" }
    ]

    certification_table.width = 500
    certification_table.position = 40
    certification_table.orientation = :right
    certification_table.shade_rows     = :none
    certification_table.show_headings = false

    certification_table.data.replace data

    certification_table.show_lines     = :all
    certification_table.render_on(fax_pdf)

    fax_pdf.move_pointer(50)
    signature_table = PDF::SimpleTable.new
    signature_table.column_order.push(*%w(col1 col2))
    data = [
      {'col1' => "______________________________________________", 'col2' => "_______________________"},
      {'col1' => "<b>HR/Payroll Signature</b>", 'col2' => "<b>Date</b>"}
    ]

    signature_table.data.replace data

    signature_table.width = 500
    signature_table.position = 40
    signature_table.orientation = :right
    signature_table.show_headings = false
    signature_table.show_lines = :none
    signature_table.shade_rows = :none
    signature_table.render_on(fax_pdf)

#    information_table = info_table(fax_pdf)

    fax_pdf.move_pointer(30)
    fax_pdf.text "<b>Send completed certification to FloBridge by fax or mail.</b>"
    fax_pdf.text "<b>Fax: (801) 852-1365</b>", :left => 20
    fax_pdf.text "<b>Mail: 691 W. 1200 N., Ste. 100, Springville, UT 84663</b>", :left => 20
    return fax_pdf
  end

  def info_table(fax_pdf)

    fax_pdf.start_new_page
    info_table = PDF::SimpleTable.new
    info_table.font_size = 12
    info_table.column_order.push(*%w(CreditorHereinafterTheCompany Customer(s)))


    data = [
      {"CreditorHereinafterTheCompany" => "FloBridge Group LLC \n  691 West 1200 North, Suite 100 \n Springville, UT 84663 \n Phone:866-569-3321 \n Fax: 801-692-6690 \n www.flobridge.com", "Customer(s)" =>customer.full_name + "\n" + customer.address + "\n" + customer.home_phone + "\n" + customer.email  },
      {"CreditorHereinafterTheCompany" => "Contract Date: #{signature_page_accepted_at.to_s(:mmddyy)}", "Customer(s)" => "Security Check:" }
    ]

    #info_table.position = 200
    info_table.shade_rows     = :none
    info_table.show_headings = true

    info_table.data.replace data

    info_table.show_lines     = :all
    info_table.render_on(fax_pdf)

    fax_pdf.move_pointer(20)

    fax_pdf.text "DISCLOSURES UNDER FEDERAL RESERVE REGULATION Z",:justification=>:center

    fr_disclosure_table = PDF::SimpleTable.new
    #fr_disclosure_table.font_size = 12
    fr_disclosure_table.column_order.push(*%w(col1 col2 col3 col4))


    data = [
      {"col1" => "Annual Percentage Rate \n The cost of your credit as a yearly \n rate." + number_to_percentage(apr, :precision => 2), "col2" =>"Finance Charge \n The dollar amount the credit \n will cost you \n ." + number_to_currency(signature_page_finance_charge), "col3" => "Amount Financed \n The amount of credit provided \n to you or on your behalf \n $" + number_to_currency(signature_page_loan_amount),"col4"=> "Total Of Payments \n The amount you will have paid \n after you have made all payments \n as scheduled \n ." + number_to_currency(signature_page_loan_amount + signature_page_finance_charge) },
    ]

    fr_disclosure_table.shade_rows     = :none
    fr_disclosure_table.show_headings = false

    fr_disclosure_table.data.replace data

    fr_disclosure_table.show_lines     = :all
    fr_disclosure_table.render_on(fax_pdf)

    fax_pdf.move_pointer(15)
    fax_pdf.text "Payment schedule:"

    fax_pdf.move_pointer(15)
    payment_schedule_table = PDF::SimpleTable.new
    payment_schedule_table.font_size = 12
    payment_schedule_table.column_order.push(*%w(NumberofPayments AmountofPayments WhenPaymentsAreDue))


    data = [
      {"NumberofPayments" => "1", "AmountofPayments" =>self.initial_total_of_payments,"WhenPaymentsAreDue" => self.initial_due_date.strftime("%m/%d/%Y") },
    ]

    payment_schedule_table.shade_rows     = :none
    payment_schedule_table.show_headings = true

    payment_schedule_table.data.replace data

    payment_schedule_table.show_lines     = :all
    payment_schedule_table.render_on(fax_pdf)

    fax_pdf.move_pointer(15)

    fax_pdf.text "Late Charge: (if any) \n Prepayment: If you pay off this loan early you will not have to pay a prepayment penalty.\n
See the contract (below) for any additional information about nonpayment, default, and any required repayment in full before the
scheduled date, and prepayment refunds."

    fax_pdf.move_pointer(15)
    additional_information_contract_table = PDF::SimpleTable.new
    additional_information_contract_table.font_size = 12
    additional_information_contract_table.column_order.push(*%w(col1 col2 col3))


    data = [
      {"col1" => "Itemization of amount financed:", "col2" =>"Amount paid directly to you: Amount \n paid to other on your behalf:","col3" => self.approved_loan_amount },
      {"col1" => "", "col2" =>"Amount rolled over from previous loan:","col3" => "$0.00" },
      {"col1" => "", "col2" =>"Total amount financed:","col3" => self.approved_loan_amount },
    ]

    additional_information_contract_table.shade_rows     = :none
    additional_information_contract_table.show_headings = false

    additional_information_contract_table.data.replace data

    additional_information_contract_table.show_lines     = :all
    additional_information_contract_table.render_on(fax_pdf)

    fax_pdf.move_pointer(20)
    fax_pdf.text "This is a Deferred Deposit Agreement, herein referred to as Agreement, between the Company and the Customer identified above, entering into this transaction in accordance with the Utah Check Cashing and Deferred Deposit Lending Registration Act, Utah Code Title 07 Chapter 23 Sections 101, 102, 103.1, and 104.1 and Sections 201 through 504, and in accordance with the Truth in Lending Act, U.S.C. Section 1601. Both parties agree that this note and all matters regarding this account shall be governed by all applicable federal laws and all laws of the jurisdiction in which the lender is located, regardless of which state you may reside, and by your electronic signature, you consent to the exclusive exercise of regulatory and adjudicatory authority by the jurisdiction on which the lender is located."
    fax_pdf.move_pointer(20)
    fax_pdf.text "Pursuant to this agreement, the Company has agreed to defer deposit of the personal check identified above until the Deferred Deposit Date set forth above, and Customer AUTHORIZES Company to deposit the check or electronic debit on such date. In consideration of the foregoing, Customer agrees to pay Finance Charge as described above, which is set forth expressed both in U.S. currency and as annual percentage rate. Customer agrees not to CLOSE THE ACCOUNT THAT THE CHECK, DRAFT OR ELECTRONIC DEBIT IS DRAWN ON, or take any other action to forestall the payment of the check, draft or electronic debit. Customer further agrees and acknowledges that this transaction is taking place at the above listed address of the Company."
    fax_pdf.move_pointer(20)
    fax_pdf.text "We do not disclose nonpublic personal information about our customers or former customers to 3rd parties, other than certain disclosures
as permitted by law, therefore, no opt-out form is needed.
We may collect nonpublic personal information about you from your application, your transaction history, and our affiliates (if any), your
employer (if applicable) and consumer reporting agencies (if applicable).
We protect the confidentiality and security of your non public personal information by restricting access to your information to our
employees who need to know in order to provide service to you. We maintain physical, electronic, and procedural safeguards to protect
your personal information. The company may share or sell your information with any other related company with whom the company
does business. To limit sharing of information with affiliated companies and non- affiliated third parties, contact us in writing at"

    payment_option =  my_payment_option(fax_pdf)

    return fax_pdf

  end

  def my_payment_option(fax_pdf)
    fax_pdf.start_new_page
    fax_pdf.text "<b>What Are My Payment Options?</b>",:justification=>:center
    fax_pdf.move_pointer(20)

    fax_pdf.text "<b>1.Pay Finance Charge Only</b> - We will only debit the finance charge due on your up-coming payday. In order to extend your loan you must contact us via email or phone at least Three (3) full business days prior to your loan coming due. You may use this option up to three times. On the forth time you must make a minimum payment equal to 1/3 of the principle balance plus your finance charge.
<b>2.Pay Finance Charge And A Payment Towards Your Loan Amount</b>- We will only debit the finance charge due plus a payment towards the principle amount on your up-coming payday. You must contact us via email or phone at least Three (3) full business days prior to your loan coming due.
<b>3.Pay Your Loan in Full</b> - we will debit the full amount of the loan (including principle and interest) due on your up-coming payday. You must contact us via email or phone at least Three (3) full business days prior to your loan coming due."
    fax_pdf.move_pointer(20)
    fax_pdf.text "<b>Electronic Payment</b> - You authorize FloBridge Group LLC, to initiate one or more Ach debit entries (for example, to our option, one debit entry may to initiated for the principle of the loan and for the finance charge) to the checking account you supplied on your application. This authorization becomes effective at the time we make the loan to you and will remain in effect until such loan is paid in full. If you timely revoke the authorization to effect the ACH entries before the loan is paid in full, you authorize FloBridge Group LLC to prepare and submit one or more checks drawn on your account on or after the due date of your loan. This authorization to prepare and submit checks on your behalf may not be revoked until the loan is paid in full. Additionally, if the account you have provided to us for your ACH debit has been closed or funds are not available at the time of the scheduled debit, you authorize us to debit any account that you hold that we have information on."
    fax_pdf.move_pointer(15)
    fax_pdf.text "Rescission - A person receiving a deferred deposit loan may rescind the deferred deposit loan on or before 5 p.m. of the next business day without incurring any charges."
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Rollovers</b> - The deferred deposit loan may not be rolled over without the person receiving the deferred deposit loan requesting the rollover."
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Rollover Limitation</b> - The deferred loan may not be rolled over if the rollover requires the person to pay the amount owed in whole or in part more than 12 weeks after the day on which the deferred deposit loan is executed."
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Arbitration Disclosure</b> - Your signature on this Agreement means that you agree that any parties involved may choose to have any dispute, controversy, or claim (herein after referred to collectively as Claim) of any kind that arises out this Agreement or your application thereto or any instrument relating thereto resolved by binding arbitration as set forth below. You further agree that the American Arbitration Association herein after referred to as the AAA' will conduct the arbitration according to the AAA's Commercial Arbitration Rules herein after referred to as the Arbitration Rules'. If arbitration is chosen by any party with respect to a Claim, no party to this Agreement will have the right to litigate that Claim in court or have ajury trial on that Claim, or engage in pre-arbitration discovery except as provided in the Arbitration Rules. Further, you will not have the right to participate as a member or representative of any class of claimants pertaining to any Claim subject to arbitration. The decision of the arbitrator is normally final and binding. There shall be no authority for arbitration of any claims on a class action basis. Arbitration can only decide your or our Claim and may not join or consolidate the claims of other people regardless of similarity of the claim or claims."
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Authorization To Verify Information</b> - By signing this Agreement, you hereby authorize our agents or us to verify the information contained in this Agreement or contained in your Customer Application through any source, including but not limited to Factor Trust, CL Verify and Teletrack."
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Customer Representations And Warranties</b> - By signing this Agreement, you acknowledge Company's reliance upon the information contained in your Customer Application and you represent and warrant that all information in this Agreement and in your Customer Application is true and correct. You further represent and warrant that you are not a debtor facing insolvency, or reorganization, or under any proceeding in bankruptcy and that you have no intention to file a petition for relief under the United States Bankruptcy Code on or before the Payment Due Date"
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Prepayment</b> - You may pay the Total of Payments in whole or in part on or before the Payment Due Date, if you pay in whole the Total Of Payments due you may be entitled to a refund of the unused portion of the Finance Charge."
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Dishonored Check Fee</b> - If, for any reason, your bank does not honor your check and returns it to us unpaid, you agree to pay us a dishonored check fee in the amount of $20.00.1 hereby authorize The Company to electronically debit my bank account for the full amount of the payments due as shown above. I further authorize The Company to electronically debit my bank account for any returned item fees. I acknowledge that I have read this agreement completely before signing below, and have received a copy of this agreement."
    fax_pdf.move_pointer(15)
    fax_pdf.text "<b>Designated Agent</b> - The name and address in this state of a designated agent upon whom service process may be made: FloBridge Group LLC 691 West 1200 North, Suite 100, Springville UT, 84663."
    fax_pdf.move_pointer(15)
    fax_pdf.text "I understand that this is a short term advance loan. I further acknowledge that I have Ml ability to meet the financial obligations of this loan.",:left=>50
    fax_pdf.text "I understand that if any instrument of payment is returned unpaid for any reason, I am governed by the following conditions:",:left=>50

    fax_pdf.start_new_page
    fax_pdf.text "1.I will pay a $20 service fee on all returned or incomplete instruments of payment.
2.If this account is assigned to collections, I agree to pay all costs incurred in the collection of the obligation including but not limited to attorney's fees, court costs, service fees, collection costs, and the 40% fee charged by third party collection companies. I further agree to pay interest on outstanding collection cost and fees at the rate of 3% per month (36% per year) and believe that this practice conforms with the requirements of the law. I herby authorize said assignee to release all information necessary to secure payment.
3.I agree to have my wages garnished to pay any delinquent amount on this loan."
    fax_pdf.move_pointer(15)
    fax_pdf.text "AUTHORIZATION FOR PAYROLL DEDUCTIONS Wherein your employer provides a variety of benefits, programs, and services to employees, for those items requiring cost sharing by employees and for expenses incurred by employees, we must receive written authorization to deduct the necessary payments from your paycheck. I hereby authorize your Employer, to deduct from my wages and/or from my final paycheck amounts to pay for the following, if applicable:"
    fax_pdf.move_pointer(15)
    fax_pdf.text "1.Repayment for payroll advances and/or Payday Loans.
2.Payments, contributions, to a loan, trust or other financial institution, Again, I understand that any or all of these deductions may be terminated by giving written notice to the Company.",:left=>50
    fax_pdf.move_pointer(15)

    fax_pdf.text "#{signature_page_accepted_name} (IP: #{signature_page_ip_address})                                                            #{signature_page_accepted_at.to_s(:mmddyy)}"

    return fax_pdf
  end


  def mark_as_written_off(current_user)
    self.written_off_on = Date.today
    self.written_off_by = current_user.id
    self.mark_as_written_off!
    self.logs << Log.new(:message => "#{current_user.full_name} wrote off this loan.", :user => current_user)
  end

  def mark_as_recission_requested
    self.recission_requested_on = Date.today
    mark_as_recission_requested!
  end

  def mark_as_recission_draft_submitted(ach_batch_id, draft_effective_date, bank_account)
    self.recission_draft_on = draft_effective_date
    self.recission_draft_ach_batch_id = ach_batch_id
    mark_as_recission_draft_submitted!
  end

  def mark_as_rescinded(payment_account = nil)
    loan_transaction = LoanTransaction.create!(
      :loan => self,
      :tran_type => LoanTransaction::PAYMENT,
      :total => self.principal_owed * -1,
      :principal => self.principal_owed * -1,
      :interest => 0,
      :fees => 0,
      :payment_account => payment_account
    )
    self.principal_owed = 0
    self.interest_owed = 0
    self.fees_owed = 0

    #Payment template
    mark_as_rescinded!
  end

  def aasm_state_to_text
    self.aasm_state.split('_').join(' ').titleize
  end

  def fund
    raise Exception.new('Loan must be in approved state in order to fund') unless self.aasm_state == 'approved'
    raise Exception.new('Loan must have approved_loan_amount in order to fund') unless self.approved_loan_amount && self.approved_loan_amount > 0
    raise Exception.new('Loan must be signed in order to fund') unless self.signature_page_accepted_at && self.signature_page_ip_address && self.signature_page_accepted_name
    raise Exception.new('Signature page loan amount must match approved loan amount in order to fund') unless self.signature_page_loan_amount == self.approved_loan_amount
    raise Exception.new('Underwriter verifications must be completed in order to fund') unless self.verified_personal &&
      self.verified_financial &&
      self.verified_employment_with_employer &&
      self.verified_employment_with_customer &&
      self.verified_tila
    Loan.transaction do
      # Transfer the money
      # Update the loan record
      LoanTransaction.create!(
        :loan_id => self.id,
        :tran_type => LoanTransaction::PRINCIPAL,
        :total => self.approved_loan_amount,
        :principal => self.approved_loan_amount,
        :interest => 0,
        :fees => 0,
        :new_due_date => self.customer.next_pay_date_1,
        :payment_account_id => self.customer.bank_accounts.funding_accounts.first.id
      )
      self.principal_owed = self.approved_loan_amount;
      self.interest_owed = 0;
      self.fees_owed = 0;
      self.funded_on = Date.today
      #      self.balances_owed_updated_on = Date.today
      self.amounts_owed_updated_on = Date.today

      # Grant the extension requested at time of TILA disclosures (underwriting), if any.
      if auto_extend_to_upon_funding
        
      end
      mark_as_active!
      #set message template for loan active
    end
  end

  def total_principal_of_scheduled_payments
    total_principal = 0
    self.scheduled_payments.each do |scheduled_payment|
      total_principal += scheduled_payment.principal
    end
    total_principal
  end
  
  def force_to_active
    # TODO - uncomment exception before official launch
    #    raise Exception.new('force_to_active only available in development environment') unless RAILS_ENV == 'development'
    LoanTransaction.destroy_all(["loan_id = ?",self.id])
    self.aasm_state = 'active'
    self.approved_at = Time.now
    self.funded_on = Date.today
    if self.approved_loan_amount
      self.signature_page_loan_amount = self.approved_loan_amount
    else
      self.approved_loan_amount = self.signature_page_loan_amount = self.requested_loan_amount
    end
    self.principal_owed = self.approved_loan_amount
    self.interest_owed = 0
    self.fees_owed = 0
    self.amounts_owed_updated_on = Date.today
    self.signature_page_accepted_at = Time.now
    self.signature_page_ip_address = '127.0.0.1'
    self.signature_page_accepted_name = customer.full_name
    self.verified_personal = true
    self.verified_financial = true
    self.verified_employment_with_employer = true
    self.verified_employment_with_customer = true
    self.verified_tila = true

    self.disclosed_finance_charge_amount_at   = Time.now
    self.disclosed_due_date_at                = Time.now
    self.disclosed_apr_at                     = Time.now
    self.disclosed_extend_12_weeks_max_at     = Time.now
    self.disclosed_partial_payments_at        = Time.now
    self.disclosed_recission_at               = Time.now
    self.disclosed_must_request_extensions_at = Time.now
    self.disclosed_member_area_at             = Time.now

    Loan.transaction do
      save!
      LoanTransaction.create!(
        :loan_id => self.id,
        :tran_type => LoanTransaction::PRINCIPAL,
        :total => self.principal_owed,
        :principal => self.principal_owed,
        :payment_account_id => self.customer.default_funding_payment_account.id
      )
    end
  end

  def handle_ach_return(ach_return = nil)
    self.logs << Log.new(:message => "ACH transaction returned.")
    # Send message(s) to customer
    case self.aasm_state
    when 'active'
      mark_as_collections
    when 'recission_draft_submitted'
      mark_as_active!
    when 'collections'
    when 'garnishments'
    end
  end

  # Virtual Attribute: garnishment_approved
  def garnishment_approved
    !self.garnishment_approved_on.nil?
  end

  def garnishment_approved=(is_approved)
    if is_approved
      self.garnishment_approved_on = Date.today unless self.garnishment_approved_on
    else
      self.garnishment_approved_on = nil
    end
  end

  # Virtual Attribute: court_order
  def court_order
    self.garnishment_sub_status == 'court_order'
  end

  def court_order=(is_court_order)
    self.garnishment_sub_status = is_court_order ? 'court_order' : nil
  end

  def tila_kit(ip_address,current_user)
    view = ActionView::Base.new(ActionController::Base.view_paths, {})

    class << view
      include ApplicationHelper, LoansHelper
    end

    html = view.render(:file => "#{RAILS_ROOT}/app/views/includes/_truth_in_lending_agreement.html.erb", :locals => { :loan => self, :customer => self.customer, :ip_address => ip_address, :current_user => current_user, :pdf => true }, :layout => "#{RAILS_ROOT}/app/views/layouts/loan_confirmation.html.erb")
    kit = PDFKit.new(html, :page_size => 'Letter')
    kit
  end
  
  def tila_pdf(ip_address,current_user)
    kit = tila_kit(ip_address,current_user)
    kit.to_pdf
  end

  def self.test_tila_pdf
    loan = Loan.find(:first, :conditions => ["aasm_state = 'garnishments'"])
    puts "loan id: #{loan.id}"
    loan.test_pdf
  end

  def test_pdf
    view = ActionView::Base.new(ActionController::Base.view_paths, {})

    class << view
      include ApplicationHelper, LoansHelper
    end

    html = view.render(:file => "#{RAILS_ROOT}/app/views/includes/_truth_in_lending_agreement.html.erb", :locals => { :loan => self, :customer => self.customer, :ip_address => '127.0.0.1', :current_user => User.find_by_username('underwriter'), :pdf => true }, :layout => false)
    kit = PDFKit.new(html, :page_size => 'Letter')
    kit.to_file("#{RAILS_ROOT}/tmp/tila.pdf")
  end

  private


  def generate_signature_token
    if self.signature_token.blank?
      self.signature_token = String.generate_pin(40)
      while Loan.find_by_signature_token(self.signature_token)
        # Odds of a collision approx. 1 in 1.79 x 10^^62
        self.signature_token = String.generate_pin(40)
      end
    end
  end


end
