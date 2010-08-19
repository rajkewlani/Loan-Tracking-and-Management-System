# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

#ENV['PATH'] += ":/usr/local/sphinx/bin:"
ENV['PATH'] += "c:/sphinx/bin"
# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), 'initializers/constantlist')
require 'pdfkit'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"

  config.middleware.use PDFKit::Middleware

  config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'spreadsheet', :lib =>'spreadsheet/excel' ,:version=>'0.6.4.1'
  config.gem 'pdf-writer', :lib=> 'pdf/writer',:version=>'1.1.8'
#  config.gem 'collectiveidea-delayed_job',
#      :lib => 'delayed_job',
#      :source => 'http://gems.github.com'

  config.gem 'tzinfo'
  config.gem 'activemerchant', :lib => 'active_merchant'
  config.gem 'nokogiri'
  #config.gem 'curb'
  config.gem 'validates_timeliness'
  config.gem 'faker'
  config.gem 'populator'
  config.gem 'httpclient'
  config.gem "rubyist-aasm", 
      :lib => "aasm"
  config.gem 'mislav-will_paginate', 
      :version => '~> 2.3.11', 
      :lib     => 'will_paginate', 
      :source  => 'http://gems.github.com'

  config.gem 'thinking-sphinx',
      :lib     => 'thinking_sphinx',
      :version => '1.2.12'

  # System must have ts-delayed-delta v 1.0.2 but don't config it here.  It's required in the Rakefile.

  config.gem 'delayed_job',
    :version => '2.0.2'
  config.gem 'jackdempsey-acts_as_commentable', 
      :lib => 'acts_as_commentable', 
      :source => "http://gems.github.com"
  config.gem 'troelskn-handsoap', 
      :lib => 'handsoap', 
      :source => "http://gems.github.com"
  config.gem 'liquid'
  config.gem 'factory_girl',
      :source => 'http://gemcutter.org'
  config.gem 'attr_encrypted'
  config.gem 'mechanize',
    :version => '1.0.0'
  config.gem  'fastercsv'
 #config.action_mailer.delivery_method = :smtp
# config.action_mailer.smtp_settings = {
#   :address => "174.143.205.24",
#   :port => "25",
#   :domain => "paydayloantracker",
#   :user_name => "deploy",
#   :password => "NorthPoint99",
#   :authentication => :login
#}
# config.action_mailer.smtp_settings = {
#   :address => "174.143.205.24",
#   :port => "7785",
#   :domain => "paydayloantracker.com",
#   :user_name => "deploy",
#   :password => "NorthPoint99"
# }
# config.after_initialize do
#   ExceptionNotifier.exception_recipients = %w(dharin@vervesys.com)
#   ExceptionNotifier.sender_address = %("Application Error" <app.error@PLT.com>)
#   ExceptionNotifier.email_prefix = "[APPLICATION ERROR] "
# end
  #config.gem 'spreadsheet'
  #config.gem 'spreadsheet-excel'


#  config.gem 'aws-s3'
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  config.active_record.observers = :comment_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  #config.time_zone = 'Mountain Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  # 
  # Disable wrapping form fields with error divs
  config.action_view.field_error_proc = Proc.new do |html_tag, instance|
                                          %{#{html_tag}}
                                        end

  config.plugins = [ :exception_notification, :all ]
  #config.after_initialize do
  
 #end
end

my_date_formats = {
  :day_date => "%a %B %d, %Y",
  :sm_d_y => "%b %d, %Y",
  :m_d_y => "%B %d, %Y",
  :day_date_time => "%a %B %d, %Y %I:%M%p",
  :mmddyy => "%m/%d/%y",
  :yymmdd => "%y%m%d",
  :mmddyyyy => "%m/%d/%Y",
  :hhmm => "%I:%M",
  :hhmmp => "%I:%M %p"
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_date_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_date_formats)

ActiveMerchant::Billing::Base.gateway_mode = RAILS_ENV == 'production' ? :production : :test

ExceptionNotifier.exception_recipients = %w(dharin@vervesys.com bob@np-adv.com)
ExceptionNotifier.sender_address = %("Application Error" <error@paydayloantracker.com>)
ExceptionNotifier.email_prefix = "[APPLICATION ERROR] "


class WebServer
  @@domain = ''
  @@beta = false
  @@secure_protocol = ''
  @@production = false

  def WebServer.domain=(d)
    @@domain = d
  end

  def WebServer.domain
    @@domain
  end

  def WebServer.beta=(b)
    @@beta = b
  end

  def WebServer.beta?
    @@beta
  end

  def WebServer.secure_protocol=(p)
    @@secure_protocol = p
  end

  def WebServer.secure_protocol
    @@secure_protocol
  end

  def WebServer.production=(p)
    @@production = p
  end

  def WebServer.production?
    @@production
  end

end

if RAILS_ENV == 'production'
  WebServer.domain = 'www.paydayloantracker.com'
  WebServer.secure_protocol = 'https'
  WebServer.production = true
end

if RAILS_ENV == 'test'
  WebServer.secure_protocol = 'http'
end

if RAILS_ENV == 'development'
  WebServer.domain = 'localhost:3000'
  WebServer.secure_protocol = 'http'
end
