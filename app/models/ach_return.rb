class AchReturn < ActiveRecord::Base

  belongs_to :loan
  validates_presence_of :ach_provider_id, :routing_number, :account_number, :amount, :loan_id
  validates_uniqueness_of :loan_transaction_id
end
