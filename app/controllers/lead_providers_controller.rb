class LeadProvidersController < ApplicationController
  before_filter :login_required
  
  def index
    @lead_providers = LeadProvider.paginate :page => params[:page], :order => 'name ASC'
  end
  
  def new
    @lead_provider = LeadProvider.new
  end
  
  def create
    @lead_provider = LeadProvider.new(params[:lead_provider])
    if @lead_provider.save
      flash[:success] = "Created new lead provider account successfully!"
      redirect_to lead_providers_path
    else
      flash.now[:information] = "Please fill out all required fields below"
      render :action => "new"
    end
  end
  
  def edit
    @lead_provider = LeadProvider.find(params[:id])
  end
  
  def update
    @lead_provider = LeadProvider.find(params[:id])
    if @lead_provider.update_attributes(params[:lead_provider])
      flash[:success] = "Updated lead provider account successfully!"
      redirect_to lead_providers_path
    else
      flash.now[:information] = "Please fill out all required fields below"
      render :action => "edit"
    end
  end
  
  def destroy
    @lead_provider = LeadProvider.find(params[:id])
    if @lead_provider.destroyable?
      @lead_provider.destroy
      flash[:success] = "Lead provider '#{@lead_provider.name}' has been deleted successfully"
    else
      flash[:attention] = "You cannot delete this lead provider because there are lead submissions by them. Edit the account to disable it."
    end
    redirect_to lead_providers_path
  end
  
  def show
    @lead_provider = LeadProvider.find(params[:id])
    @customers = @lead_provider.customers.paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'
  end
  
end
