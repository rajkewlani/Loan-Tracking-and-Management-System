require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def new_user(attributes = {})
    attributes[:username] ||= 'foo'
    attributes[:email] ||= 'foo@example.com'
    attributes[:password] ||= 'abc123'
    attributes[:password_confirmation] ||= attributes[:password]
    user = User.new(attributes)
    user.valid? # run validations
    user
  end
  
  def setup
    User.delete_all
  end
  
  should "be valid" do
    assert new_user.valid?
  end
  
  should "require username" do
    assert new_user(:username => '').errors.on(:username)
  end
  
  should "require password" do
    assert new_user(:password => '').errors.on(:password)
  end
  
  should "require well formed email" do
    assert new_user(:email => 'foo@bar@example.com').errors.on(:email)
  end
  
  should "validate uniqueness of email" do
    new_user(:email => 'bar@example.com').save!
    assert new_user(:email => 'bar@example.com').errors.on(:email)
  end
  
  should "validate uniqueness of username" do
    new_user(:username => 'uniquename').save!
    assert new_user(:username => 'uniquename').errors.on(:username)
  end
  
  should "not allow odd characters in username" do
    assert new_user(:username => 'odd ^&(@)').errors.on(:username)
  end
  
  should "validate password is longer than 3 characters" do
    assert new_user(:password => 'bad').errors.on(:password)
  end
  
  should "require matching password confirmation" do
    assert new_user(:password_confirmation => 'nonmatching').errors.on(:password)
  end
  
  should "generate password hash and salt on create" do
    user = new_user
    user.save!
    assert user.password_hash
    assert user.password_salt
  end
  
  should "authenticate by username" do
    user = new_user(:username => 'foobar', :password => 'secret')
    user.save!
    assert_equal user, User.authenticate('foobar', 'secret')
  end
  
  should "authenticate by email" do
    user = new_user(:email => 'foo@bar.com', :password => 'secret')
    user.save!
    assert_equal user, User.authenticate('foo@bar.com', 'secret')
  end
  
  should "not authenticate bad username" do
    assert_nil User.authenticate('nonexisting', 'secret')
  end
  
  should "not authenticate bad password" do
    new_user(:username => 'foobar', :password => 'secret').save!
    assert_nil User.authenticate('foobar', 'badpassword')
  end
end
