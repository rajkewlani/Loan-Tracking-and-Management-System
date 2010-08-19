class DocumentsController < ApplicationController
 
  def new
    @document = Document.new
  end
  
  def create
    
    @document = Document.new(params[:document])
    @loan = Loan.find_by_id(params[:document][:loan_id])
    @document.customer_id =  @loan.customer_id
    if @document.save
      redirect_to :action=>"show",:controller=>"loans",:id=>@loan.id, :tab => 'documents'
    else
      redirect_to :action=>"show",:controller=>"loans",:id=>@loan.id, :tab => 'documents'
   end
   
  end
  def destroy
    @document=Document.find(params[:id])
    @document.destroy
    @loan = Loan.find_by_id(params[:loan_id])
    redirect_to :action=>"show",:controller=>"loans",:id=>@loan.id, :tab => 'documents'
  end
end
