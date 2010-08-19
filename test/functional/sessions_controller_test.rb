require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  context "new action" do
    should "render new template" do
      get :new
      assert_template 'new'
    end
  end
  
  context "create action" do
    should "render new template when authentication is invalid" do
      User.stubs(:authenticate).returns(nil)
      post :create
      assert_template 'new'
      assert_nil session['user_id']
    end
    
    should "redirect when authentication is valid" do
      User.stubs(:authenticate).returns(User.first)
      post :create
      assert_redirected_to root_url
      assert_equal User.first.id, session['user_id']
    end
  end
end
