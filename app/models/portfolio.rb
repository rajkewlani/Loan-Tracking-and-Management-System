class Portfolio < ActiveRecord::Base
  has_many :investments
  has_many :loans
  validates_presence_of :name,
    :apr, :max_loan_amount, :min_loan_days, :max_loan_days,
    :max_extensions, :max_loans_per_year
    :port_key

  def before_validation
    self.port_key = String.generate_pin(10)
  end
end
