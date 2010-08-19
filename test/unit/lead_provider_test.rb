require File.dirname(__FILE__) + '/../test_helper'

class LeadProviderTest < Test::Unit::TestCase
  
  should_validate_presence_of :name
  should_validate_presence_of :username
  should_validate_presence_of :password
  should_validate_presence_of :lead_filter_id
  should_validate_presence_of :status
  should_allow_values_for :status, 0, 1, 2
  should_not_allow_values_for :status, 3, 4, 5, nil
  
end
