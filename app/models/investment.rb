class Investment < ActiveRecord::Base
  belongs_to :investor
  belongs_to :portfolio

  validates_presence_of :investor_id, :portfolio_id, :amount
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
end
