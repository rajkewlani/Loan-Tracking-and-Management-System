class InvestorSessionsController < ApplicationController
  layout 'login'
    auto_session_timeout_actions
  def active_investor
   #render_session_status
    response.headers["Etag"] = ""  # clear etags to prevent caching
    render :text => logged_in_true_or_false?, :status => 200
  end

  def timeout_investor
    flash[:notice] = "Your session has timed out."
    redirect_to "/investor_login"
    #render_session_timeout
  end

  def new
    reset_session
  end

  def create
    investor = Investor.authenticate(params[:login], params[:password])
    if investor
      session[:investor_id] = investor.id
      investor.update_attribute(:last_login_at, Time.now)
      investor.update_attribute(:last_login_ip, request.remote_ip)
      investor.update_attribute(:logged_in,true)
      if params[:remember_me] == '1'
        cookies[:remember_me] = { :value => '1', :expires => 10.years.from_now }
        # Guarantee unique auth token
        begin
          investor.authorization_token = String.generate_ascii_hex(40)
        end until investor.valid?
        investor.save!
        cookies[:investor_authorization_token] = { :value => investor.authorization_token, :expires => 10.years.from_now }
      else
        cookies.delete(:remember_me)
        cookies.delete(:investor_authorization_token)
      end
      redirect_to(session[:return_to] || investor_area_root_url)
    else
      flash.now[:error] = "Invalid login or password."
      render :action => 'new'
    end
  end

  def destroy
    session[:investor_id] = nil
    cookies.delete(:investor_authorization_token)
    flash[:information] = "You have been logged out."
    redirect_to investor_login_url
  end
end
