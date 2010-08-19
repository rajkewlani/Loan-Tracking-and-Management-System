# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = false
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

# Use sendmail in development environment
config.action_mailer.delivery_method = :sendmail

# wsdl: https://dev.factortrust.com/webservices/lendprotectrequest.asmx?WSDL
LEND_PROTECT_REQUEST_SERVICE_ENDPOINT = {
  :uri => 'https://dev.factortrust.com/webservices/lendprotectrequest.asmx',
  :version => 2
}