class LocationsController < ApplicationController
  before_filter :login_required
  
  def index
    @locations = Location.paginate :page => params[:page], :per_page => 15, :order => 'name'
    @default_tab = 'tab1'
  end

  def create
    @location = Location.new(params[:location])
    unless @location.valid?
      @default_tab = 'tab2'
      @locations = Location.paginate :page => params[:page], :per_page => 15, :order => 'name'
      render :action => :index
      return
    end
    if @location.save
      flash[:success] = "Location was created successfully"
      redirect_to locations_path
    else
      render :action => :new
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:success] = "Location was updated successfully"
      redirect_to locations_path
    else
      render :action => :edit
    end
  end

  def destroy
    Location.destroy(params[:id])
    flash[:success] = "Location was deleted successfully"
    redirect_to locations_path
  end

end
