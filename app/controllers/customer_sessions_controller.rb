class CustomerSessionsController < ApplicationController
  layout 'flobridge'


  if RAILS_ENV == 'production'
    ssl_required :new, :create
  end
  
  def new
    @hide_pre_form = true
    reset_session
  end

  def create
    @hide_pre_form = true
    customer = Customer.authenticate(params[:login].strip, params[:password].strip)
    if customer
      if customer.login_suspended
        flash.now[:error] = 'Login privileges suspended.'
        render :action => 'new'
        return
      end
      session[:customer_id] = customer.id
      if params[:remember_me] == '1'
        cookies[:remember_me] = { :value => '1', :expires => 10.years.from_now }
        # Guarantee unique auth token
        begin
          customer.authorization_token = String.generate_ascii_hex(40)
        end until customer.valid?
        customer.save!
        cookies[:customer_authorization_token] = { :value => customer.authorization_token, :expires => 10.years.from_now }
      else
        cookies.delete(:remember_me)
        cookies.delete(:customer_authorization_token)
      end
      redirect_to(session[:return_to] || member_area_root_url)
    else
      flash.now[:error] = "Invalid login or password."
      render :action => 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:customer_authorization_token)
    flash[:information] = "You have been logged out."
    redirect_to customer_login_url
  end

end
