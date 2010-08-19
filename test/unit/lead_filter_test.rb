require File.dirname(__FILE__) + '/../test_helper'

class LeadFilterTest < Test::Unit::TestCase
  
  should_validate_presence_of :name
  #should_validate_uniqueness_of :name
  
end
