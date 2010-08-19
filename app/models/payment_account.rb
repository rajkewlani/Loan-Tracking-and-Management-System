class PaymentAccount < ActiveRecord::Base

  include ActiveMerchant::Utils
  
  belongs_to  :customer
  belongs_to :account, :polymorphic => true

  attr_accessor :create_authnet_customer_profile
  attr_accessor :create_authnet_payment_profile
  attr_accessor :credit_card # New records

  named_scope :bank_accounts, :conditions => "account_type = 'BankAccount'"
  named_scope :credit_cards, :conditions => "account_type = 'CreditCard'"

  validates_presence_of :customer_id, :account_id, :account_type

  def before_create
    cim_gateway = get_authnet_cim_payment_gateway
    # Ensure customer has an AuthorizeNet CIM profile
    logger.info "create_authnet_customer_profile: #{create_authnet_customer_profile}"
    cim_customer_profile = customer.cim_profile(cim_gateway, create_authnet_customer_profile)
    logger.info "cim_customer_profile: #{cim_customer_profile}"
    if create_authnet_payment_profile
      # Create a CIM customer payment profile for this payment account
      response = cim_gateway.create_customer_payment_profile(
        :customer_profile_id => cim_customer_profile['customer_profile_id'],
        :payment_profile => {
          :payment => {
            :credit_card =>  ActiveMerchant::Billing::CreditCard.new(
              :first_name => self.credit_card.first_name,
              :last_name => self.credit_card.last_name,
              :month => self.credit_card.expires_month,
              :year => self.credit_card.expires_year,
              :type => 'visa',
              :number => self.credit_card.card_number
            )
          }
        }
      )
      logger.info "create customer payment profile response: #{response.inspect}"
      if response.success?
        self.authnet_payment_profile_id = response.params['customer_payment_profile_id']
      end
    end
  end
end
