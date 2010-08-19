require File.dirname(__FILE__) + '/../test_helper'

class FactorTrustTest < Test::Unit::TestCase
  
  def setup
    @app = FactorTrust::Application.new
    @app.username                 = 'ABCD1'
    @app.password                 = "lendprotect"
    @app.merchant_identifier      = 97090
    @app.store_identifier         = "0001"
    @app.application_id           = 1300
    @app.first_name               = "Joe"
    @app.last_name                = "Blow"
    @app.date_of_birth            = "04/02/1973"
    @app.address_1                = "123 Easy St"
    @app.city                     = "Herriman"
    @app.state                    = "UT"
    @app.zip                      = "84096"
    @app.country                  = "US"
    @app.months_at_address        = 32
    @app.ssn                      = "313131313"
    @app.ssn_issue_state          = "UT"
    @app.account_aba              = "123456789"
    @app.account_dda              = "380138"
    @app.account_type             = "C"
    @app.employer_name            = "Home Depot"
    @app.monthly_income           = 3500.00
    @app.payroll_type             = "D"
    @app.payroll_frequency        = "S"
    @app.payroll_garnishment      = "N"
    @app.requested_loan_amount    = 300.00
    @app.requested_effective_date = (Date.today + 1).strftime("%m/%d/%Y")
    @app.requested_due_date       = (Date.today + 8).strftime("%m/%d/%Y")
  end

  def test_blank_application_is_invalid
    @app = FactorTrust::Application.new
    @app.username = ''
    assert @app.username.blank?
    assert_equal(false, @app.valid?)
  end
  
  def test_completed_application_is_valid
    assert_equal(true, @app.valid?)
  end
  
  def test_submission_to_factor_trust
    FactorTrust::Application.any_instance.stubs(:submit_to_factor_trust).returns(FactorTrust::APPROVED_XML)
    puts @app.submit_to_factor_trust
  end
  
end
