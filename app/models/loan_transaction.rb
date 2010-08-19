class LoanTransaction < ActiveRecord::Base

  belongs_to :loan
  belongs_to :ach_batch
  belongs_to :payment_account

  # Transaction types
  PRINCIPAL = 'principal'
  INTEREST  = 'interest'
  PAYMENT   = 'payment'
  EXTENSION = 'extension'
  NSF_FEE   = 'NSF fee'
  LATE_FEE  = 'late fee'
  COLLECTION_FEE  = 'collection fee'
  GARNISHMENT_FEE = 'garnishment fee'
  ADJUSTMENT      = 'adjustment'

  CHECKING    = 'checking'
  CREDIT_CARD = 'credit card'
  
  validates_presence_of :loan_id, :tran_type
  validates_inclusion_of :tran_type, :in => [PRINCIPAL,INTEREST,PAYMENT,EXTENSION,NSF_FEE,LATE_FEE,COLLECTION_FEE,GARNISHMENT_FEE,ADJUSTMENT]

  def payment_account
    return nil if self.payment_account_id.nil?
    PaymentAccount.find(self.payment_account_id)
  end
  
   def allocate_payment
    # Apply payment amount first to fees, interest, and then principal
    available_amount = self.total

    # Apply to fees
    if loan.fees_owed > 0
      if available_amount >= self.loan.fees_owed
        self.fees = loan.fees
        available_amount -= self.loan.fees_owed
      else
        self.fees = available_amount
        available_amount = 0
      end
    end

    # Apply to interest
    #calculated_interest_owed = self.loan.interest_on(self.draft_date)
    calculated_interest_owed = self.loan.interest_owed
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
    #calculated_principal_owed = self.loan.principal_owed - self.loan.scheduled_payment_subtotals(self.draft_date)[:principal]
    calculated_principal_owed = self.loan.principal_owed
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
    self.total = self.principal + self.interest + self.fees
  end
end
