require 'test_helper'

class MailerTest < ActionMailer::TestCase
  test "new_customer_welcome_letter" do
    @expected.subject = 'Mailer#new_customer_welcome_letter'
    @expected.body    = read_fixture('new_customer_welcome_letter')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Mailer.create_new_customer_welcome_letter(@expected.date).encoded
  end

end
