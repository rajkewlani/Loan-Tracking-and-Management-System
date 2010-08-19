require 'common'
require 'digest/sha1'

class BankAccount < ActiveRecord::Base
  acts_as_loggable
  
  belongs_to :customer
  has_one :payment_account, :as => :account
  
  attr_encrypted :bank_account_number, :key => ENCRYPTION_KEY
  attr_encrypted :bank_aba_number, :key => ENCRYPTION_KEY

  named_scope :funding_accounts, :conditions => "funding_account = 1"

  validates_presence_of :bank_name
  validates_length_of :bank_name, :maximum => 30
  validates_presence_of :bank_account_type
  validates_inclusion_of :bank_account_type, :in => %w( CHECKING SAVINGS )
  validates_presence_of :bank_aba_number
  validates_length_of :bank_aba_number, :in => 8..9
  validates_numericality_of :bank_aba_number
  validates_presence_of :bank_account_number
  validates_presence_of :months_at_bank
  validates_length_of :bank_address, :maximum => 30, :allow_blank => true
  validates_length_of :bank_city, :maximum => 30, :allow_blank => true
  validates_inclusion_of :bank_state, :in => Common::US_STATES, :allow_blank => true
  validates_length_of :bank_zip, :is => 5, :allow_blank => true
  validates_numericality_of :bank_zip, :allow_blank => true
  validates_length_of :bank_phone, :is => 10, :allow_blank => true
  validates_numericality_of :bank_phone, :allow_blank => true
  validates_uniqueness_of :encrypted_bank_account_number, :scope => 'customer_id'

  def description
    "#{self.bank_account_type} #{self.bank_account_number}"
  end
end
