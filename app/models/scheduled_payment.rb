class ScheduledPayment < ActiveRecord::Base
  include AASM
  include ActionView::Helpers::NumberHelper

  belongs_to  :customer
  belongs_to  :loan
  belongs_to  :payment_account

  acts_as_loggable
  
  attr_accessor :bank_name, :bank_account_number, :bank_aba_number, :bank_account_type
  attr_accessor :bank_direct_deposit, :months_at_bank
  attr_accessor :card_number, :expires, :expires_month, :expires_year, :cvv, :name_on_card, :first_name, :last_name, :card_billing_address, :card_billing_zip
  attr_accessor :bank_account_id, :credit_card_id
  attr_accessor :check_number

  validates_presence_of :customer_id, :loan_id, :payment_account_id, :amount, :draft_date
  validates_numericality_of :amount
  validates_uniqueness_of :draft_date, :scope => 'loan_id', :message => ' has already been taken.  Only one scheduled payment per day is allowed.'

  named_scope :today_and_future, :conditions => ["draft_date >= ?",Date.today]
  named_scope :ach_submitted, :conditions => ["aasm_state = 'ach_submitted'"]

# AASM CONFIGURATION
  aasm_initial_state :scheduled
  aasm_state :scheduled
  aasm_state :ach_submitted
  
  aasm_event :mark_as_ach_submitted do
    transitions :to => :ach_submitted, :from => [:scheduled]
  end

  def initialize(params = nil)
    super params
    self.draft_date = Date.today unless self.draft_date
  end

  def before_validation
    self.amount = self.principal + self.interest + self.fees
  end

  def validate
    amounts = loan.amounts_owed_on_date_assuming_scheduled_payments(self.draft_date)
    if amount > amounts[:total]
      errors.add_to_base('Total payment exceeds total owed')
    end
    if self.principal > amounts[:principal]
      errors.add_to_base('Principal amount exceeds principal owed on payment date')
    end
    if amount != principal + interest + fees
      errors.add_to_base('Total payment amount does not match allocation among principal, interest, and fees.')
    end
    if payment_account.account.class == BankAccount
      high_risk_bank_branch = HighRiskBankBranch.find_by_aba_routing_number(payment_account.account.bank_aba_number)
      if high_risk_bank_branch
        errors.add_to_base('There was a problem with your bank account.  Please call us at (866) 569-3321 or select another payment account')
      end
    end
  end

#  def payment_account
#    PaymentAccount.find(self.payment_account_id)
#  end

  def recalculate_interest_and_total
    self.interest = self.loan.amounts_owed_on_date_assuming_scheduled_payments(draft_date)[:interest]
    self.amount = principal + interest + fees
    puts "draft_date: #{draft_date.to_s(:sm_d_y)}  interest: #{interest}"
    save
  end

  def allocate_payment
    # Apply payment amount first to fees, interest, and then principal
    available_amount = self.amount

    # Apply to fees
    if loan.fees_owed > 0
      if available_amount >= self.loan.fees_owed
        self.fees = loan.fees_owed
        available_amount -= self.loan.fees_owed
      else
        self.fees = available_amount
        available_amount = 0
      end
    end

    # Apply to interest
    calculated_interest_owed = self.loan.interest_on(self.draft_date)
    if calculated_interest_owed > 0
      if available_amount >= calculated_interest_owed
        self.interest = calculated_interest_owed
        available_amount -= calculated_interest_owed
      else
        self.interest = available_amount
        available_amount = 0
      end
    end

    # Apply to principal
    calculated_principal_owed = self.loan.principal_owed - self.loan.scheduled_payment_subtotals(self.draft_date)[:principal]
    if calculated_principal_owed > 0
      if available_amount > calculated_principal_owed
        self.principal = calculated_principal_owed
        available_amount -= self.loan.principal_owed
      else
        self.principal = available_amount
        available_amount = 0
      end
    end

    # Adjust payment amount down if any available amount left over.
    # Excess shouldn't be possible given the validation but let's just be careful anyway.
    self.amount = self.principal + self.interest + self.fees
  end

  def formatted_amount
    number_to_currency(amount)
  end

  def formatted_amount=(str)
    self.amount = str.gsub(/[^0-9.]/,'').to_f
  end
  
end
