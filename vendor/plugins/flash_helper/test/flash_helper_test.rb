require 'test_helper'
require File.join(File.dirname(__FILE__), "..", "lib", "flash_helper")

class FlashHelperTest < ActiveSupport::TestCase
  
  include FlashHelper
  
  test "display flash tag" do
    flash = Hash.new
    flash[:notice] = "This is a test"
    assert_equal '<div id="flash_notice">This is a test</div>', display_flash(flash)
  end
  
end
