class LeadFiltersController < ApplicationController
  before_filter :login_required
  
  def index
    @lead_filters = LeadFilter.paginate :page => params[:page], :order => 'name ASC'
  end
  
  def new
    @lead_filter = LeadFilter.new
  end
  
  def create
    @lead_filter = LeadFilter.new(params[:lead_filter])
    if @lead_filter.save
      flash[:success] = "Created new lead submission filter successfully!"
      redirect_to lead_filters_path
    else
      flash.now[:information] = "Please fill out all required fields below"
      render :action => "new"
    end
  end
  
  def edit
    @lead_filter = LeadFilter.find(params[:id])
  end
  
  def update
    @lead_filter = LeadFilter.find(params[:id])
    if @lead_filter.update_attributes(params[:lead_filter])
      flash[:success] = "Updated lead submission filter successfully!"
      redirect_to lead_filters_path
    else
      flash.now[:information] = "Please fill out all required fields below"
      render :action => "edit"
    end
  end
  
  def destroy
    @lead_filter = LeadFilter.find(params[:id])
    if @lead_filter.destroyable?
      @lead_filter.destroy
      flash[:success] = "Lead filter '#{@lead_filter.name}' has been deleted successfully"
    else
      flash[:attention] = "You cannot delete this filter because there is one or more lead providers assigned to it"
    end
    redirect_to lead_filters_path
  end
  
end
