namespace :db do


  desc "Set some demo loan states"
  task :set_demo_loan_states => :environment do
    underwriter = User.find_by_username('underwriter')
    loans = Loan.find(:all, :conditions => ["aasm_state =?","underwriting"])
    #u_loan = loans.count
    loans.each do |loan|
      if loan.id > 50 and loan.id <= 100
        loan.update_attributes(
          :aasm_state => "approved",
          :approved_loan_amount => loan.signature_page_loan_amount ,
          :approved_at => Time.now,
          :funded_on => Date.today.to_date,
          :verified_personal => true,
          :verified_financial => true,
          :verified_employment_with_employer => true,
          :verified_employment_with_customer => true,
          :verified_tila => true
        )
      elsif loan.id > 100 and loan.id <= 150
        loan.update_attributes(:aasm_state => "denied", :portfolio_id => 2)
      elsif loan.id > 150 and loan.id <= 200
        loan.force_to_active
        loan.mark_as_collections(false)
      elsif loan.id > 200 and loan.id <= 250
        loan.force_to_active
        loan.garnishments_on = Date.today
        loan.mark_as_collections(false)
        loan.garnishment_sub_status = 'packet_sent'
        loan.mark_as_garnishments(underwriter,false)
      end
    end
  end
end