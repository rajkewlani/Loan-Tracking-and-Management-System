require File.dirname(__FILE__) + '/../test_helper'
require 'api_controller'

class ApiControllerTest < ActionController::TestCase
  fixtures :all

  def setup

    @controller = ApiController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end


     
  def test_cust_data
    params = Customer::SAMPLE_CUSTOMER_PARAMS
    post :post,params
    assert_response :success
  end
      
  #assert_redirected_to
  #assert_equal 'Post was successfully created.'
  #end
  #
  #should_respond_with :success
  #
  #   should "return a success response" do
  #     xml = Nokogiri::XML::Document.parse(@response.body)
  #     puts xml.to_xml
  #     assert_equal "ACCEPTED", xml.search('response/status').text
  #     assert_equal "http://www.google.com", xml.search('response/url').text
  #   end
  # end
  #
  # context "on POST to :api which is rejected" do
  #   setup do
  #     params = Customer::SAMPLE_CUSTOMER_PARAMS
  #     params[:username] = @lead_provider.username
  #     params[:password] = @lead_provider.password
  #     params[:is_test]  = "false"
  #     params[:birth_date] = "1993-03-15"
  #     post :post, params
  #   end
  #   should_respond_with :success
  #   should "return a rejected response" do
  #     xml = Nokogiri::XML::Document.parse(@response.body)
  #     puts xml.to_xml
  #     assert_equal "REJECTED", xml.search('response/status').text
  #     assert_equal "birth_date must be at least 21 years old", xml.search('response/errors/error').text
  #   end
  # end
  #
  # context "on POST to :api which has missing data" do
  #   setup do
  #     params = Customer::SAMPLE_CUSTOMER_PARAMS
  #     params[:username] = @lead_provider.username
  #     params[:password] = @lead_provider.password
  #     params[:is_test]  = "false"
  #     params[:birth_date] = ""
  #     post :post, params
  #   end
  #   should_respond_with :success
  #   should "return a error response" do
  #     xml = Nokogiri::XML::Document.parse(@response.body)
  #     puts xml.to_xml
  #     assert_equal "ERROR", xml.search('response/status').text
  #     assert_equal "birth_date can't be blank", xml.search('response/errors/error').text
  #   end
  #end
      
end
