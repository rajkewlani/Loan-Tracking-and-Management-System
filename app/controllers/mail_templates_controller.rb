class MailTemplatesController < ApplicationController
  before_filter :login_required
  
  def index
    @mail_templates = MailTemplate.all
  end
  
  def edit
    @mail_template = MailTemplate.find(params[:id])
  end
  
end
