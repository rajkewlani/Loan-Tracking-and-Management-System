class LogsController < ApplicationController
  before_filter :login_required
  
  def create
    @log = Log.new(params[:log])
    puts @log.inspect
    render :text => "OK"
  end
  
end
