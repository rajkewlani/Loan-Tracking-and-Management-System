class SessionsController < ApplicationController
  layout 'login'
  
  if RAILS_ENV == 'production'
    ssl_required :new, :create
  end

#  auto_session_timeout_actions
  def active
   #render_session_status
    response.headers["Etag"] = ""  # clear etags to prevent caching
    render :text => logged_in_true_or_false?, :status => 200
  end

  def timeout
    render_session_timeout
  end

  def new
    reset_session
  end
  
  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      # Enforce IP address restrictions
      if user.role != 'administrator'
        if user.login_suspended
          flash.now[:error] = "Login Privileges Suspended"
          render :action => 'new'
          return
        end
        ip_ok = false
        user.locations.each do |location|
          if location.ip_address == request.remote_ip
            ip_ok = true
            break
          end
        end
        unless ip_ok
          flash.now[:error] = "Your IP address is not allowed."
          render :action => 'new'
          return
        end
      end
      
      session[:user_id] = user.id
      previous_login = user.last_login_at
      user.update_attribute(:last_login_at, Time.now)
      user.update_attribute(:last_login_ip, request.remote_ip)
      user.update_attribute(:logged_in,true)
      if params[:remember_me] == '1'
        cookies[:remember_me] = { :value => '1', :expires => 10.years.from_now }
        # Guarantee unique auth token
        begin
          user.authorization_token = String.generate_ascii_hex(40)
        end until user.valid?
        user.save!
        cookies[:authorization_token] = { :value => user.authorization_token, :expires => 10.years.from_now }
      else
        cookies.delete(:remember_me)
        cookies.delete(:authorization_token)
      end
      if user.role == 'administrator'
#        redirect_and_drop_SSL(root_url)
        redirect_to_target_or_default(root_url)
      else
#        redirect_and_drop_SSL(my_loans_url)
        reminders_today = user.reminders_today.size
        reminders_since_last_login = previous_login.nil? ? 0 : user.reminders_since(previous_login.to_date).size
        reminder_msg = ''
        if reminders_today > 0
          reminder_msg += "You have #{reminders_today} reminder(s) today."
        end
        if reminders_since_last_login > 0
          reminder_msg += "  You have #{reminders_since_last_login} reminder(s) since your last login."
        end
        flash[:attention] = reminder_msg if reminder_msg.length > 0
        redirect_to_target_or_default(my_loans_url)
      end
    else
      flash.now[:error] = "Invalid login or password."
      render :action => 'new'
    end
  end
  
  def destroy
    session[:user_id] = nil
    cookies.delete(:authorization_token)
    flash[:information] = "You have been logged out."
    redirect_to login_url
  end
end
