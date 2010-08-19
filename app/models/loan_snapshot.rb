class LoanSnapshot < ActiveRecord::Base
  belongs_to :loan

  validates_presence_of :loan_id, :principal_owed, :interest_owed, :fees_owed, :aasm_state
  validates_numericality_of :principal_owed, :interest_owed, :fees_owed
end
