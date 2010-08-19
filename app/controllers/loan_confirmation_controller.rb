class LoanConfirmationController < ApplicationController
  layout 'loan_confirmation'

  def index
    @signature_token = params[:signature_token]
    @loan = Loan.find_by_signature_token(@signature_token)
    if @loan
      session[:customer_id_for_signature] = @loan.customer.id
      @loan.update_attribute(:signature_page_arrived_at, Time.now) if @loan.signature_page_arrived_at.blank?
    else
      raise "Customer not found"
    end
  end
  
  def accept_agreement
    if !session[:customer_id_for_signature].blank? || !session[:customer_id].blank?
      @loan = Loan.find_by_signature_token(params[:signature_token])
      if @loan && @loan.customer.id == session[:customer_id_for_signature] || session[:customer_id]
        # SUCCESSFULLY SIGNED
        @loan.sign_agreement(request.remote_ip, params[:accepted_name],params[:send_prerecorded_messages]=='1',params[:send_sms_messages]=='1')
        session[:customer_id_for_signature] = nil
        session[:customer_id] = @loan.customer.id
        redirect_to "/member_area" and return
      end
    end
    session[:customer_id_for_signature] = nil
    raise "Invalid Access"
  end

end
