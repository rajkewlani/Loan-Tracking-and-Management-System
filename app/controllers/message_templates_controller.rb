class MessageTemplatesController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
  before_filter :login_required
  # GET /message_templates
  # GET /message_templates.xml

  def new
    @message_template = MessageTemplate.new(params[:message_template])
  end

  def index
    @message_template = MessageTemplate.new(params[:message_template])
    @message_templates = MessageTemplate.all
    @message_templates = MessageTemplate.paginate :page => params[:page], :per_page => 15, :order => 'name'
    @default_tab = 'tab1'
  end

  def edit
    @message_template = MessageTemplate.find(params[:id])
    if @message_template.send_hour <= 12
      @message_template.hour_12 = @message_template.send_hour
      @message_template.am_pm = 'AM'
    else
      logger.info "send_hour > 12"
      @message_template.hour_12 = @message_template.send_hour - 12
      @message_template.am_pm = 'PM'
      logger.info "hour_12: #{@message_template.hour_12}"
    end
  end

  # POST /message_templates
  # POST /message_templates.xml
  def create
    
    respond_to do |format|
      @message_template = MessageTemplate.new(params[:message_template])
     if params[:message_template][:send_schedule_flag] == MessageTemplate::POINT_IN_TIME
     end
      if @message_template.save
        flash[:notice] = 'MessageTemplate was successfully created.'
        format.html { redirect_to(message_templates_path) }
        format.xml  { render :xml => @message_template, :status => :created, :location => @message_template }
      else
        format.html {
          @default_tab = 'tab2'
          @message_templates = MessageTemplate.all
          @message_templates = MessageTemplate.paginate :page => params[:page], :per_page => 15, :order => 'name'
          render :action => :index
        }
        format.xml  { render :xml => @message_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /message_templates/1
  # PUT /message_templates/1.xml
  def update
    @message_template = MessageTemplate.find(params[:id])

      if @message_template.update_attributes(params[:message_template])
        flash[:notice] = 'MessageTemplate was successfully updated.'
        redirect_to(message_templates_path)
      else
        render :action => "edit"
      end
    end

  # DELETE /message_templates/1
  # DELETE /message_templates/1.xml
  def destroy
    @message_template = MessageTemplate.find(params[:id])
    @message_template.destroy

    respond_to do |format|
      format.html { redirect_to(message_templates_url) }
      format.xml  { head :ok }
    end
  end

  # Custom REST methods

  # Responds to AJAX request to generate preview of message template for a particular loan/customer.
  def preview
    message_template = MessageTemplate.find(params[:id])
    loan = Loan.find(params[:loan_id])
    customer = loan.customer
    after_subs = message_template.perform_placeholder_substitutions(loan,customer)
    @sms_message = after_subs[:sms_body]
    @email_subject = after_subs[:email_subject]
    @email_body = after_subs[:email_body]

    render :layout => false
  end

  def send_to_customer
    message_template = MessageTemplate.find(params[:message_template][:id])
    loan = Loan.find(params[:message_template][:loan_id])
    message_template.deliver(loan)
    render :text => 'Message Sent Successfully'
  end
end
