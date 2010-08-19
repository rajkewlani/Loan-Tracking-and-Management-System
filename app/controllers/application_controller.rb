# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include Exceptions
  include SslRequirement
  include Authentication
  
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :ssn, :dl_number, :bank_aba_number, :bank_account_number
  #local_addresses.clear
  auto_session_timeout 1.hour
  
  def redirect_and_drop_SSL destination
    destination[:protocol], destination[:only_path] = 'http', false if request.ssl?
    redirect_to(destination)
  end
  
#  def rescue_action(exception)
#    logger.info "controller_path: #{controller_path}"
#    logger.info "exception: #{exception.class.to_s}"
#    layout = controller_path == 'member_area' ? 'flobridge' : 'application'
#    @exception = exception
#    flash.clear
#    case exception
#    when ::ActiveRecord::RecordNotFound
#      render :template => 'shared/record_not_found', :status => 404, :layout => layout
#    when ::ActionController::UnknownAction
#      render :template => 'shared/page_not_found', :status => 404, :layout => layout
#    when AuthorizeNetError
#      render :template => 'shared/authorizenet_error', :status => 500, :layout => layout
#    end
#  end
end
