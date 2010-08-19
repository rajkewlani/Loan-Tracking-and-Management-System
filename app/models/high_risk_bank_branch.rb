class HighRiskBankBranch < ActiveRecord::Base

  validates_presence_of :aba_routing_number, :name
  validates_uniqueness_of :aba_routing_number
  validates_numericality_of :aba_routing_number
  validates_length_of :aba_routing_number, :is => 9
end
