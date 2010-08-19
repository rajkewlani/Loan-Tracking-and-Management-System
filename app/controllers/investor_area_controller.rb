class InvestorAreaController < ApplicationController
  include InvestorAuthentication
  before_filter :investor_login_required
  def index
    
  end
end
