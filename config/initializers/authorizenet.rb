AUTHORIZENET_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/authorizenet.yml")[RAILS_ENV].symbolize_keys

module ActiveMerchant

  module Utils

    def get_authnet_cim_payment_gateway
      RAILS_DEFAULT_LOGGER.info "Authnet Config: #{AUTHORIZENET_CONFIG.inspect}"
      gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
        :login => AUTHORIZENET_CONFIG[:login_id],
        :password => AUTHORIZENET_CONFIG[:transaction_key],
        :test => RAILS_ENV != 'production'
      )
      RAILS_DEFAULT_LOGGER.info "cim gateway: #{gateway.inspect}"
      unless gateway
        raise AuthenticationFailed, 'Authentication with CIM Gateway failed'
      end
      gateway
    end

    def get_authnet_gateway
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
        :login => AUTHORIZENET_CONFIG[:login_id],
        :password => AUTHORIZENET_CONFIG[:transaction_key],
        :test => RAILS_ENV != 'production'
      )
      unless gateway
        raise AuthenticationFailed, 'Authentication with CIM Gateway failed'
      end
      gateway
    end

  end
end