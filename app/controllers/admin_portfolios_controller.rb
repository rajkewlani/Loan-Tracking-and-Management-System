class AdminPortfoliosController < ApplicationController
  before_filter :login_required
   
  def index
    @portfolio = Portfolio.new
    if current_user.role == 'administrator'
      @portfolios = Portfolio.paginate :page => params[:page], :per_page => 15, :order => 'name'
      @default_tab = 'tab1'
    end
  end
  
  def new
    @portfolio = Portfolio.new(params[:portfolio])
  end

  def create

    @portfolio = Portfolio.new(params[:portfolio])
    unless @portfolio.valid?
      @default_tab = 'tab2'
      @portfolios = Portfolio.paginate :page => params[:page], :per_page => 15, :order => 'name'
      render :action => :index
      return
    end
    
    if @portfolio.save
      flash[:success] = "Portfolio was created successfully"
      redirect_to admin_portfolios_path
    else
      render :action => :new
    end
    
  end

  def edit
     @admin_portfolio = Portfolio.find(params[:id])
  end
  
  def update
    @admin_portfolio = Portfolio.find(params[:id])
    if @admin_portfolio.update_attributes(params[:portfolio])
      flash[:success] = "Portfolio was updated successfully"
      redirect_to admin_portfolios_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    Portfolio.destroy(params[:id])
    flash[:success] = 'Portfolio deleted sucessfully.'
    redirect_to :action => :index
  end
end
