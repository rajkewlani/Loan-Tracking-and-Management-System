class Mailer < ActionMailer::Base
  
  CUSTOMER_SUPPORT = "support@paydayloantracker.com"
  INFO = "info@paydayloantracker.com"
  WELCOME_BODY = <<-EOF
Dear {{customer.first_name}},

We have received your loan application, thank you. You will be contacted shortly by
one of our experienced Customer Service Representatives to confirm the information on
your application and complete the approval process. We are a direct lender so in most cases,
once your loan is approved, funds are deposited in your account by the next business day.

If you have any questions, we are available Mon-Fri from 7:30 am to 6:30 pm MST at (866) 569-3321, or use the contact form on our website at flobridge.com.

Our member area is located at:  http://www.paydayloantracker.com/customer_login

Your login ID is your email address and your password is the last 4 digits of your Social Security Number.

From the member area, you can view your credit limit, veiw past and present loans, view the Truth In Lending Agreement, make payments, apply for a new loan, etc.

Thank You,

FloBridge Customer Service
contact@flobridge.com

Toll-Free: (866) 569-3321
EOF

  def contact_flobridge(email, message, sent_at = Time.now)
    subject    'You have received an email message via Payday Loan Tracker - Member Area'
    recipients ['contact@flobridge.com']
    from       ['noreply@flobridge.com']
    sent_on    sent_at
    body       :email => email, :message => message
  end

  def new_customer_welcome_letter(customer, sent_at = Time.now)
    mail_template = MailTemplate.find_by_name("new_customer_welcome_letter")
    subject    mail_template.subject
    recipients customer.email
    body       Liquid::Template.parse(mail_template.body).render 'customer' => customer
    from       INFO
    sent_on    sent_at
    content_type mail_template.content_type
  end

  # Delivers mail to Advantage ACH if in production environment or to TEST_EMAIL otherwise.
  def notify_advantage_ach_of_upload(ach_batch, sent_at = Time.now)
    puts "Mailer::notify_advantage_ach_of_upload"
    subject    "FloBridge (#{ADVANTAGE_ACH_CONFIG[:login_id]}), #{Date.today.to_s(:advantage_ach)}, (File  Confirmation)"
    recipients RAILS_ENV == 'production' ? ['processing@advantageach.com','support@advantageach.com'] : [TEST_EMAIL]
    from       ['noreply@flobridge.com']
    sent_on    sent_at
    body       :ach_batch => ach_batch
  end

  # Mail to employer with PDF attachment when loan converts to gernishment
  def notify_employer_about_loan_garnishment(loan,pdfFile, tila_pdf)
    subject     "FloBridge Loan Garnishment Notification for your employee"
    recipients  ["#{loan.customer.employer_fax}@metrofax.com","kami@flobridge.com"]
#    recipients  ['bob@np-adv.com']
    from        ['FloBridge Group LLC <service1@flobridge.com>']
    sent_on     Time.now
    attachment :content_disposition => 'attachment', :body => pdfFile, :content_type => 'application/pdf', :filename => 'loan_garnishment_details.pdf'
    attachment :content_disposition => 'attachment', :body => File.read("#{RAILS_ROOT}/public/documents/worksheet.pdf"), :content_type => 'application/pdf', :filename => 'worksheet.pdf'
    attachment :content_disposition => 'attachment', :body => tila_pdf, :content_type => 'application/pdf', :filename => 'truth_in_lending_agreement.pdf'
  end

  def notify_invalid_placeholder(error_message)
    
    subject     "Your Template Has Invalid Placeholder"
    recipients  ['bob@np-adv.com']
    from        ['contact@flobridge.com']
    sent_on     Time.now
    body        :error_message => error_message
  end

  # The generic mailer function for sending a message template
  def customer_alert(customer,subject,body,content_type, sent_at = Time.now)
    subject       subject
    recipients    customer.email
    from          'contact@flobridge.com'
    body          body
    sent_on       sent_at
    content_type  content_type
  end


  def test(to_email, sent_at = Time.now)
    subject       'Payday Loan Tracker Test Message'
    recipients    to_email
    from          'contact@flobridge.com'
    sent_on       sent_at
    body          "<h3>This is only a test</h3><p>Had this been an <strong>actual emergency</strong> you would have been toast!</p>"
    content_type  "text/html"
  end
end
