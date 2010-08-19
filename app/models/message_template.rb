class MessageTemplate < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :message_category
  
  attr_accessor :hour_12
  attr_accessor :am_pm
  #attr_accessor :emailbody
  
  # Scheduling Methods
  TRIGGER_EVENT = 'trigger_event'
  POINT_IN_TIME = 'point_in_time'
  MANUAL        = 'manual'
  
  validates_presence_of :name, :send_schedule_flag
  validates_presence_of :before_after, :if => Proc.new { |mt| mt.send_schedule_flag == POINT_IN_TIME}
  validates_presence_of :base_date, :if => Proc.new { |mt| mt.send_schedule_flag == POINT_IN_TIME}
  validates_presence_of :days, :if => Proc.new { |mt| mt.send_schedule_flag == POINT_IN_TIME}
  #validates_exclusion_of :days, :in => 1..70
  validates_numericality_of :send_hour, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 23

  TEXT_HTML   = 'text/html'
  TEXT_PLAIN  = 'text/plain'
  CONTENT_TYPES = [TEXT_HTML, TEXT_PLAIN]


  # Placeholders
  FIRST_NAME            = '[first_name]'
  LAST_NAME             = '[last_name]'
  EMPLOYER_NAME         = '[employer_name]'
  LOAN_AMOUNT           = '[loan_amount]'
  DUE_DATE              = '[due_date]'
  PAYOFF_AMOUNT         = '[payoff_amount]'
  PRINCIPAL_DUE         = '[principal_due]'
  INTEREST_DUE          = '[interest_due]'
  FEES_DUE              = '[fees_due]'
  REJECT_REASON         = '[reject_reason]'
  INTEREST_AT_DUE_DATE  = '[total_interest_at_due_date]'
  FUNDED_ON             = '[funded_on]'
  CUSTOMER_ID           = '[customer_id]'

  PLACEHOLDER_HASH = {
    FIRST_NAME            => '#{customer.first_name}',
    LAST_NAME             => '#{customer.last_name}',
    EMPLOYER_NAME         => '#{customer.employer_name}',
    LOAN_AMOUNT           => '#{number_to_currency(loan.signature_page_loan_amount)}',
    DUE_DATE              => '#{loan.due_date.to_s(:m_d_y)}',
    PAYOFF_AMOUNT         => '#{number_to_currency(loan.payoff_amount)}',
    PRINCIPAL_DUE         => '#{number_to_currency(loan.principal_due)}',
    INTEREST_DUE          => '#{number_to_currency(loan.interest_due)}',
    FEES_DUE              => '#{number_to_currency(loan.fees_due)}',
    REJECT_REASON         => '#{loan.reject_reason}',
    INTEREST_AT_DUE_DATE  => '#{number_to_currency(loan.interest_on(loan.due_date))}',
    FUNDED_ON             => '#{loan.funded_on.to_s(:m_d_y)}',
    CUSTOMER_ID           => '#{customer.id}'
  }

  PLACEHOLDER_ARRAY = [
    FIRST_NAME,
    LAST_NAME,
    EMPLOYER_NAME,
    LOAN_AMOUNT,
    DUE_DATE,
    PAYOFF_AMOUNT,
    PRINCIPAL_DUE,
    INTEREST_DUE,
    FEES_DUE,
    REJECT_REASON,
    INTEREST_AT_DUE_DATE,
    FUNDED_ON,
    CUSTOMER_ID
  ]

  def initialize(params)
    super(params)
    self.days = 0
    self.send_hour = 0
    self.send_schedule_flag = MANUAL unless self.send_schedule_flag
  end

  def before_validation
    if hour_12 && hour_12
      RAILS_DEFAULT_LOGGER.info "Setting send_hour"
      self.send_hour = am_pm.downcase == 'am' ? self.hour_12.to_i : self.hour_12.to_i + 12
      RAILS_DEFAULT_LOGGER.info "send_hour: #{send_hour}"
      self.send_hour = 0 if self.send_hour >= 24
      RAILS_DEFAULT_LOGGER.info "send_hour: #{send_hour}"
    end
  end

  def self.deliver_messages_for_event(loan, event)
    message_templates = MessageTemplate.find_all_by_msg_event(event)
    RAILS_DEFAULT_LOGGER.info "#{message_templates.size} templates for #{event}"
      message_templates.each do |message_template|
        message_template.deliver(loan)
      end
  end

  # The rescue blocks are necessary because the body/subject strings might contain erroneous placeholders that would cause an exception.
  # We should gracefully recover and alert the operator or the sys admin of the problem.
  def deliver(loan)
    customer = loan.customer
    puts "customer.first_name: #{customer.first_name}"
    after_subs = perform_placeholder_substitutions(loan,customer)
    if customer.send_sms_messages && customer.cell_phone && sms_body
      begin
        phone_number = customer.cell_phone
        if RAILS_ENV == 'production'
          phone_number = "1#{phone_number}" unless phone_number.start_with?('1') # Actual customer cell phone
        else
          phone_number = '18018301794' # Bob's cell phone
        end
        TxtWire.send_message(phone_number,after_subs[:sms_body])
      rescue Exception => e
        RAILS_DEFAULT_LOGGER.info "Caught exception: #{e.class.to_s}: #{e.message}"
        Mailer.deliver_notify_invalid_placeholder(e.message)
      rescue => e
        RAILS_DEFAULT_LOGGER.info "Caught exception: #{e}"
        Mailer.deliver_notify_invalid_placeholder(e.message)
      end
      
    end

    if after_subs[:email_subject] && after_subs[:email_body]
      customer.email = TEST_EMAIL if RAILS_ENV == 'development'
      Mailer.deliver_customer_alert(customer,after_subs[:email_subject],after_subs[:email_body],self.content_type)
    end

    loan.logs << Log.new(:message => "Message template '#{self.name}' sent", :user => User.first)
  end

  def perform_placeholder_substitutions(loan,customer)
    puts "in perform_placeholder_substitutions, customer.first_name: #{customer.first_name}"
    temp_sms_body = self.sms_body.nil? ? nil : self.sms_body.dup
    temp_email_subject = self.subject.nil? ? nil : self.subject.dup
    puts "before sub, temp_email_subject = #{temp_email_subject}"
    footer_separator = self.content_type == TEXT_HTML ? "<br /><br />" : "\n\n"
    temp_email_body = self.email_body.nil? ? nil : self.email_body + footer_separator + self.message_category.footer
    PLACEHOLDER_HASH.each_pair do |k,v|
      # Does the placeholder actually appear in any of the template strings?
      if (temp_sms_body && temp_sms_body.index(k)) ||
          (temp_email_subject && temp_email_subject.index(k)) ||
          (temp_email_body && temp_email_body.index(k))
        str_to_eval = "\"" + v + "\""
        actual_value = eval(str_to_eval)
        if k == '[first_name]'
          puts "k,v: #{k}, #{v}"
          puts "str_to_eval: #{str_to_eval}"
        end
        temp_sms_body.gsub!(k,actual_value) unless temp_sms_body.blank?
        puts "before gsub!, self.subject: #{self.subject}"
        temp_email_subject.gsub!(k,actual_value) unless temp_email_subject.blank?
        puts "after gsub!, self.subject: #{self.subject}"
        puts "after sub, temp_email_subject: #{temp_email_subject}"
        temp_email_body.gsub!(k,actual_value) unless temp_email_body.blank?
      end
    end
    hsh = {}
    hsh[:sms_body] = temp_sms_body
    hsh[:email_subject] = temp_email_subject
    hsh[:email_body] = temp_email_body
    hsh
  end
end
