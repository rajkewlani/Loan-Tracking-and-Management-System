class TeamsController < ApplicationController
  before_filter :login_required
   
  def index
    @team = Team.new
    if current_user.role == 'administrator'
      @teams = Team.paginate :page => params[:page], :per_page => 15, :order => 'name'
      @default_tab = 'tab1'
    end
  end
  
  def new
    @team = Team.new(params[:team])
  end

  def create
    @team = Team.new(params[:team])
    
    unless @team.valid?
      @default_tab = 'tab2'
      @teams = Team.paginate :page => params[:page], :per_page => 15, :order => 'name'
      render :action => :index
      return
    end
    if @team.save
     
      temp = params[:userids]
      users=temp.split(",")
      users.each do |u|
        user = User.find_by_id(u)
        user.update_attribute("team_id",@team.id)
      end
      flash[:success] = "Team was created successfully"
      redirect_to teams_path
    else
      render :action => :new
    end
  end


  def edit
    @team = Team.find(params[:id])
  end
  
  def update
    @team = Team.find(params[:id])
    if @team.update_attributes(params[:team])
      @team.users.each do |u|
        user = User.find_by_id(u)
        user.update_attribute("team_id", nil)
      end
      #users = params[:user_ids]
      temp = params[:userids]
      users=temp.split(",")
      
      users.each do |u|
        user = User.find_by_id(u)
        user.update_attribute("team_id",@team.id)
      end
      flash[:success] = "Team was updated successfully"
      redirect_to teams_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    @team = Team.find(params[:id])
    @team.users.each do |u|
        user = User.find_by_id(u)
        user.update_attribute("team_id", nil)
      end
    Team.destroy(params[:id])
    flash[:success] = 'Team deleted sucessfully.'
    redirect_to :action => :index
  end
  
  def getusers
  # @role=Team.find_by_role(params[:role])
   @user=User.find(:all, :conditions => ["role = ?",params[:role]],:order => "last_name")
   render :partial => "new_available_users", :locals => { :user => @user}
  end

end
