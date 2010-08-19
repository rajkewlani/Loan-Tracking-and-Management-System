namespace :db do
  desc "Create demo data for admin dashboard"
  task :loan_funded => :environment do
    loan_funded_on = Date.today.to_date - 1
    for id in 1..100
      loan = Loan.find_by_id(id)
      
      if loan_funded_on.strftime("%w") == "0" || loan_funded_on.strftime("%w") == "6"
        loan.funded_on = loan_funded_on - 2
      else
        loan.funded_on = loan_funded_on 
      end
      loan.funded_on = loan_funded_on
      loan.reloan = rand(2)
      loan.save
      loan_funded_on = loan_funded_on - 1
    end
  end
end