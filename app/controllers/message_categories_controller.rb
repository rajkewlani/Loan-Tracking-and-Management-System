class MessageCategoriesController < ApplicationController
  before_filter :login_required
  # GET /message_categories
  # GET /message_categories.xml
  def index

    @message_category = MessageCategory.new
    if current_user.role == 'administrator'
      @message_categories = MessageCategory.paginate :page => params[:page], :per_page => 15, :order => 'name'
      @default_tab = 'tab1'
    end
  end

  # GET /message_categories/1
  # GET /message_categories/1.xml

   def new
    @message_category = MessageCategory.new(params[:message_category])
  end

   def create
    @message_category = MessageCategory.new(params[:message_category])

    unless @message_category.valid?
      @default_tab = 'tab2'
      @message_category = MessageCategory.paginate :page => params[:page], :per_page => 15, :order => 'name'
      render :action => :index
      return
    end

    if @message_category.save
      flash[:success] = "Message Category was created successfully"
      redirect_to message_categories_path
    else
      render :action => :new
    end

  end

  def show
    @message_category = MessageCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message_category }
    end
  end

  # GET /message_categories/new
  # GET /message_categories/new.xml
 
  # GET /message_categories/1/edit
  def edit
    @message_category = MessageCategory.find(params[:id])
  end

  # POST /message_categories
  # POST /message_categories.xml

  def update
    @message_category = MessageCategory.find(params[:id])
    
    if @message_category.update_attributes(params[:message_category])
      flash[:success] = "Message Category was updated successfully"
      redirect_to message_categories_path
    else
      render :action => :edit
    end
  end


  def destroy
    MessageCategory.destroy(params[:id])
    flash[:success] = 'Message Category deleted sucessfully.'
    redirect_to :action => :index
  end

  # DELETE /message_categories/1
  # DELETE /message_categories/1.xml
end
