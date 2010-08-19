require 'nokogiri'
require 'net/http'
require 'net/https'

class FactorTrust < ActiveRecord::Base
  
  belongs_to :customer
  
  TEST_URL = "https://dev.factortrust.com/WebServices/LendProtectRequest.aspx"
  LIVE_URL = "https://www.factortrust.com/WebServices/LendProtectRequest.aspx"
  USERNAME, PASSWORD, MERCHANT_ID, STORE_ID = "ABCD1", "lendprotect", "97090", "0001"

  ACCEPTED_XML = <<-EOF
    <?xml version="1.0"?>
    <ApplicationResponse>
      <LoginInfo>
        <ChannelIdentifier></ChannelIdentifier>
        <MerchantIdentifier>97090</MerchantIdentifier>
        <StoreIdentifier>0001</StoreIdentifier>
      </LoginInfo>
      <ApplicationInfo>
        <ClientTransactionId></ClientTransactionId>
        <TransactionDate></TransactionDate>
        <ApplicationID></ApplicationID>
        <TransactionStatus>A</TransactionStatus>
        <ApprovedAmount>300.00</ApprovedAmount>
        <LendProtectScore>717</LendProtectScore>
      </ApplicationInfo>
    </ApplicationResponse>
  EOF
  
  def application_response
    @application_response ||= Hash.from_xml(self.response_xml)
  end
  
  def score
    begin
      self.application_response['ApplicationResponse']['ApplicationInfo']['LendProtectScore']
    rescue
      return "-1"
    end
  end
  
  def approved_amount
    begin
      self.application_response['ApplicationResponse']['ApplicationInfo']['ApprovedAmount']
    rescue; end
  end
  
  def approved?
    self.application_response['ApplicationResponse']['ApplicationInfo']['TransactionStatus'] == "A"
  end
  
  def dda_plus_response
    begin
      self.application_response['ApplicationResponse']['ApplicationInfo']['DDAPlus']['DDAPlusResponse']
    rescue; end
  end
  
  def dda_score
    begin
      self.application_response['ApplicationResponse']['ApplicationInfo']['DDA']['DDAResponseCode']
    rescue; end
  end
  
  def self.submit_to_factor_trust(customer)
    if RAILS_ENV == "production" && !customer.is_test?
      uri = URI.parse(LIVE_URL)
    else
      uri = URI.parse(TEST_URL)
    end
    xml = self.to_xml(customer)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.port == 443
    http.set_debug_output $stderr if RAILS_ENV == 'development'
    headers = {
      'User-Agent' => 'PaydayLoanTracker Ruby Script',
      'Content-Type' => 'text/xml',
      'Content-length' => "#{xml.length}",
      'Host' => uri.host
    }
    # Post the request
    resp, data = http.post(uri.path, xml.to_s, headers)
    ft = FactorTrust.create(
      :customer_id => customer.id,
      :response_xml => data
    )
    return ft
  end
  
  def self.to_xml(customer)
    
    pay_frequency_hash = {
      "WEEKLY"       => "W",
      "BIWEEKLY"     => "B",
      "TWICEMONTHLY" => "S",
      "MONTHLY"      => "M"
    }
    
    effective_date = (Time.now + 1.day).strftime("%m/%d/%Y")
    due_date = (Time.now + 8.days).strftime("%m/%d/%Y")
    
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.Application do
        xml.LoginInfo do
          xml.Username                USERNAME
          xml.Password                PASSWORD
          xml.ChannelIdentifier       ""
          xml.MerchantIdentifier      MERCHANT_ID
          xml.StoreIdentifier         STORE_ID
        end
        xml.ApplicationInfo do
          xml.ApplicationID           customer.id
          xml.MobileNumber            customer.cell_phone
          xml.CreditCardNumber        nil
          xml.FirstName               customer.first_name
          xml.LastName                customer.last_name
          xml.EmailAddress            customer.email
          xml.IPAddress               customer.ip_address
          xml.DLNumber                customer.dl_number
          xml.DLNumberIssueState      customer.dl_state
          xml.DateOfBirth             customer.birth_date.strftime("%m/%d/%Y")
          xml.Address1                customer.address
          xml.Address2                nil
          xml.City                    customer.city
          xml.State                   customer.state
          xml.Zip                     customer.zip
          xml.Country                 "US"
          xml.MonthsAtAddress         customer.months_at_address
          xml.AlternateZip            nil
          xml.HomePhone               customer.home_phone
          xml.SSN                     customer.ssn
          xml.SSNIssueState           customer.state # We don't know this.
          xml.AccountABA              customer.bank_aba_number
          xml.AccountDDA              customer.bank_account_number
          xml.AccountType(            (customer.bank_account_type == "CHECKING") ? "C" : "S")
          xml.EmployerName            customer.employer_name
          xml.MonthlyIncome           customer.monthly_income
          xml.PayrollType(            (customer.bank_direct_deposit == true) ? "D" : "P")
          xml.PayrollFrequency        pay_frequency_hash[customer.pay_frequency]
          xml.PayrollGarnishment      "Y"
          xml.HasBankruptcy           "N"
          xml.RequestedLoanAmount     customer.requested_loan_amount
          xml.RequestedEffectiveDate  effective_date
          xml.RequestedDueDate        due_date
        end
      end
    end
    return builder.to_xml
  end

end
