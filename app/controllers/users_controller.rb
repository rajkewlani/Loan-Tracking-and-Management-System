class UsersController < ApplicationController
  before_filter :login_required
  
  def index
    @user = User.new
    if current_user.role == 'administrator'
      @users = User.paginate :page => params[:page], :per_page => 15, :order => 'last_name'
    else
      @users = User.paginate :conditions => ["role = ?",current_user.role], :page => params[:page], :per_page => 15, :order => 'last_name'
    end
    @default_tab = 'tab1'
  end
  
  def new
    @user = User.new(params[:user])
  end

  def create
    @user = User.new(params[:user])
    unless @user.valid?
      @default_tab = 'tab2'
      if current_user.role == 'administrator'
        @users = User.paginate :page => params[:page], :per_page => 15, :order => 'last_name'
      else
        @users = User.paginate :conditions => ["role = ?",current_user.role], :page => params[:page], :per_page => 15, :order => 'last_name'
      end
      render :action => :index
      return
    end
    if @user.save
      flash[:success] = "User account was created successfully"
      redirect_to users_path
    else
      render :action => :new
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    locations = Location.find_all_by_id(params[:location_ids])
    @user.locations = locations
    if @user.update_attributes(params[:user])
      flash[:success] = "User account was updated successfully"
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end
  
  def team_availability
    @team_members = User.find(:all, :conditions => ["role = ? and team_id =? ",current_user.role, current_user.team_id ]).paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'  
  end
  
  def update_available
    @user = User.find(params[:id])
    if(@user.available == true)
      @user.update_attribute("available",false)
        customers = @user.customers.all
        customers.each do |c|
          c.assign_to_next_underwriter
        end
    else
      @user.update_attribute("available",true)
    end
    
    render :update do |page|
#      page.show "main_notification"
#      page.visual_effect :fade, "main_notification" ,:duration=>0.5
    end
  end
  
  def update_all_available
    if (params[:checked] == "false")
      User.update_all("available = 0")
    else
      User.update_all("available = 1")
    end
    
    render :update do |page|
    end
  end
    
  
  def mark_notification_as_read
    notification = UserCommentNotification.find(params[:id])
    if notification
      notification.update_attribute(:mark_as_read, true)
    else
      # Catch this...
    end
    redirect_to :back
  end
  
end
