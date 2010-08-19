module CustomerAuthentication
  def self.included(controller)
    controller.send :helper_method, :current_customer, :customer_logged_in?, :redirect_to_customer_target_or_default
    controller.filter_parameter_logging :password
  end

  def current_customer
    @current_customer ||= Customer.find(session[:customer_id]) if session[:customer_id]
  end

  def customer_logged_in?
    current_customer
  end

  def customer_logged_in_true_or_false?
    current_customer ? true : false
  end

  def customer_login_required
    unless customer_logged_in?
      authorization_token = cookies[:customer_authorization_token]
      if authorization_token
        @current_user = Customer.find_by_authorization_token(authorization_token)
        if @current_user
          session[:customer_id] = @current_customer.id
          return
        end
      end

      flash[:error] = "You must first log in or sign up before accessing this page."
      store_customer_target_location
      redirect_to customer_login_url
    end
  end

  def redirect_to_customer_target_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  private

  def store_customer_target_location
    session[:return_to] = request.request_uri
  end
end
