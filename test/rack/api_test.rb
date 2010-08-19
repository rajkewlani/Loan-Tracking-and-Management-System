require File.dirname(__FILE__) + '/../test_helper'

class ApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    ActionController::Dispatcher.new
  end
  
  def load_defaults
    lead_filter = Factory.create(:lead_filter)
    lead_provider = Factory.create(:lead_provider, :lead_filter_id => lead_filter.id)
    @attribs = Customer::SAMPLE_CUSTOMER_PARAMS
    @attribs[:username] = lead_provider.username
    @attribs[:password] = lead_provider.password
    @attribs[:is_test] = "false"
  end

  test "accepted post" do
    load_defaults
    post "/api/post", @attribs
    assert last_response.ok?
    puts "RESPONSE:\n#{last_response.body}\n"
    xml = Nokogiri::XML::Document.parse(last_response.body)
    assert_equal "ACCEPTED", xml.search('response/status').text
    assert xml.search('response/url').text.include? "https://www.paydayloantracker.com/loan_confirmation/"
  end
  
  test "rejected post" do
    load_defaults
    @attribs[:birth_date] = 19.years.ago.strftime("%m/%d/%Y")
    post "/api/post", @attribs
    assert last_response.ok?
    assert_equal 200, last_response.status
    puts "RESPONSE:\n#{last_response.body}\n"
    xml = Nokogiri::XML::Document.parse(last_response.body)
    assert_equal "REJECTED", xml.search('response/status').text
    assert_equal "birth_date is not acceptable - must be 21 years old", xml.search('response/errors/error').text
  end
  
  test "error post" do
    load_defaults
    @attribs[:birth_date] = ""
    post "/api/post", @attribs
    assert last_response.ok?
    assert_equal 200, last_response.status
    puts "RESPONSE:\n#{last_response.body}\n"
    xml = Nokogiri::XML::Document.parse(last_response.body)
    assert_equal "ERROR", xml.search('response/status').text
    assert_equal "birth_date can't be blank", xml.search('response/errors/error').text
  end
  
end