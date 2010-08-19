namespace :loans do

  desc 'Update interest owed for active loans.  Move overdue active loans to collections.'
  task :update_active_loans => :environment do
    loans = Loan.find(:all, :conditions => ["aasm_state in ('active','collections','garnishments') and funded_on >= ?",12.weeks.ago])
    defaults = 0
    loans.each do |loan|
      loan.interest_owed = loan.interest_on(Date.today) unless loan.aasm_state == 'payment_plan'
      loan.amounts_owed_updated_on = Date.today
      loan.save
      if loan.due_date < Date.today
#        loan.assign_to_next_collections_agent
        loan.mark_as_collections
        defaults += 1
      end
    end
    puts "#{loans.size} loans updated."
    puts "#{defaults} loans defaulted and moved to collections."
  end

  desc 'Record daily snapshot of each loan'
  task :daily_loan_snapshots => :environment do
    loans = Loan.find(:all)
    n = 0
    loans.each do |loan|
      begin
        LoanSnapshot.create!(
          :loan => loan,
          :principal_owed => loan.principal_owed,
          :interest_owed => loan.interest_owed,
          :fees_owed => loan.fees_owed,
          :aasm_state => loan.aasm_state
        )
        n += 1
      rescue Exception => e
        puts "Caught exception: #{e.message}"
      rescue => e
        puts "Caught exception: #{e}"
      end
    end
    puts "#{n} loan snapshots recorded."
  end
end