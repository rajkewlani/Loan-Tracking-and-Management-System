class FactorTrustController < ApplicationController
  
  def show
    @factor_trust = FactorTrust.find(params[:id])
    respond_to do |format|
      format.html { render :text => "Not available", :layout => false }
      format.xml { render :xml => @factor_trust.response_xml }
    end
  end
  
end
