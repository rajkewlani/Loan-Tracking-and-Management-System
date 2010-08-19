module InvestorAuthentication
  def self.included(controller)
    controller.send :helper_method, :current_investor, :investor_logged_in?, :redirect_to_investor_target_or_default
    controller.filter_parameter_logging :password
  end
  
  def current_investor
    @current_investor ||= Investor.find(session[:investor_id]) if session[:investor_id]
  end

  def investor_logged_in?
    current_investor
  end

  def logged_in_true_or_false?
    current_investor ? true : false
  end

  def investor_login_required
    unless investor_logged_in?

      authorization_token = cookies[:investor_authorization_token]
      if authorization_token
        @current_investor = Investor.find_by_authorization_token(authorization_token)
        if @current_investor
          session[:investor_id] = @current_investor.id
          return
        end
      end

      flash[:error] = "You must first log in or sign up before accessing this page."
      store_investor_target_location
      redirect_to investor_login_url
    end
  end

  def redirect_to_investor_target_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  private

  def store_investor_target_location
    session[:return_to] = request.request_uri
  end
end
