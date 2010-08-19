namespace :email do

  desc 'Test email'
  task :send_test_email => :environment do
    Mailer.deliver_test(TEST_EMAIL)
    puts "mail sent"
  end
end