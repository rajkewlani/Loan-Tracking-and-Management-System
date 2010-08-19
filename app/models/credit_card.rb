class CreditCard < ActiveRecord::Base
  has_one :payment_account, :as => :account

  attr_encrypted :last_4_digits, :key => ENCRYPTION_KEY
  attr_accessor :card_number, :expires, :expires_month, :expires_year, :cvv, :name_on_card, :first_name, :last_name, :billing_address, :billing_zip

  validates_presence_of :card_number, :expires_month, :expires_year, :cvv, :first_name, :last_name, :billing_address, :billing_zip, :if => Proc.new { |cc| cc.new_record? }

  VISA          = 'Visa'
  MASTERCARD    = 'Mastercard'
  AMEX          = 'American Express'
  DISCOVER      = 'Discover'

  validates_inclusion_of :card_type, :in => [VISA, MASTERCARD, AMEX, DISCOVER]

  def description
    "#{self.card_type} ************#{self.last_4_digits}"
  end
end
