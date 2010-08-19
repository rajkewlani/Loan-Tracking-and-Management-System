class SearchController < ApplicationController
  before_filter :login_required
  
  def results
    @q = params[:q]
    if @q.match(/^(\d{3}-\d{2}-\d{4})|(\d{3}\d{2}\d{4})$/)
      logger.info 'SSN match'
      cust = Customer.new(:ssn => @q.gsub(/-/,''))
      logger.info "cust.ssn: #{cust.ssn} cust.encrypted_ssn: #{cust.encrypted_ssn}"
      customers = Customer.find_all_by_encrypted_ssn(cust.encrypted_ssn)
      @customers = customers.paginate(:page => params[:page], :per_page => 15, :include => :loan)
      return
    end
    @customers = Customer.search @q, :star => true, :match_mode => :any, :page => params[:page], :per_page => 15, :include => :loans
  end
  
end
