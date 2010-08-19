class HighRiskBankBranchesController < ApplicationController
  before_filter :login_required

  def index
    @branches = HighRiskBankBranch.paginate :page => params[:page], :per_page => 15, :order => 'name'
    @default_tab = 'tab1'
  end

  def new
    @high_risk_bank_branch = HighRiskBankBranch.new(params[:high_risk_bank_branch])
  end

  def create
    @high_risk_bank_branch = HighRiskBankBranch.new(params[:high_risk_bank_branch])
    unless @high_risk_bank_branch.valid?
      @default_tab = 'tab2'
      @branches = HighRiskBankBranch.paginate :page => params[:page], :per_page => 15, :order => 'name'
      render :action => :index
      return
    end
    if @high_risk_bank_branch.save
      flash[:success] = "High Risk Bank Branch was created successfully"
      redirect_to high_risk_bank_branches_path
    else
      render :action => :new
    end
  end

  def edit
    @high_risk_bank_branch = HighRiskBankBranch.find(params[:id])
  end

  def update
    @high_risk_bank_branch = HighRiskBankBranch.find(params[:id])
    if @high_risk_bank_branch.update_attributes(params[:high_risk_bank_branch])
      flash[:success] = "High Risk Bank Branch was updated successfully"
      redirect_to high_risk_bank_branches_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    HighRiskBankBranch.destroy(params[:id])
    flash[:success] = "High Risk Bank Branch was deleted successfully"
    redirect_to high_risk_bank_branches_path
  end

end
