class AchBatch < ActiveRecord::Base
  belongs_to :ach_provider

  validates_presence_of :ach_provider_id

#  has_many :ach_transactions
  has_many :loan_transactions

  def initialize(params)
    super params
    self.batch_date = Date.today
    self.credits = 0
    self.credit_amount = 0
    self.debits = 0
    self.debit_amount = 0
  end

  def create_tmp_file
    File.open("#{RAILS_ROOT}/db/advantage_ach/tranfile/#{self.file_name}", 'w') {|f| f.write(self.csv) }
  end

#  def summary
#    credits = 0
#    debits = 0
#    credit_amount = 0
#    debit_amount = 0
#    ach_transactions.each do |ach_transaction|
#      if [27,37].include? ach_transaction.transaction_code
#        debits += 1
#        debit_amount += ach_transaction.amount.to_f
#      end
#      if [22,33].include? ach_transaction.transaction_code
#        credits += 1
#        credit_amount += ach_transaction.amount.to_f
#      end
#    end
#    { :credits => credits, :credit_amount => credit_amount, :debits => debits, :debit_amount => debit_amount}
#  end
end
