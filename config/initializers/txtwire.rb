TXTWIRE_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/txtwire.yml")[RAILS_ENV].symbolize_keys

require 'xmlrpc/client'

class TxtWire

  def self.send_message(phone_number,message)
    server = XMLRPC::Client.new2("http://www.txtwire.com/webservices?version=1.1.1")
    begin
      result = server.call(
        "message.sendMessageSpecifyNumbers",
        {
          :username => TXTWIRE_CONFIG[:username],
          :password => TXTWIRE_CONFIG[:password],
          :api_key => TXTWIRE_CONFIG[:api_key],
          :keyword => TXTWIRE_CONFIG[:group_id],
          :shortcode => TXTWIRE_CONFIG[:shortcode]
        },
        [
          {
            :sendTo => phone_number,
            :type => '1'
          }
        ],
        message
      )
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.info "Caught Exception: #{e.class.to_s}: #{e.message}"
    rescue => e
      RAILS_DEFAULT_LOGGER.info "Caught Exception: #{e}"
    end
    result
  end

end