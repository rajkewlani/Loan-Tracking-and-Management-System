require 'net/sftp'

namespace :ach do

  desc 'Process scheduled payments whose draft date has been reached'
  task :process_scheduled_credit_card_payments => :environment do
    include ActiveMerchant::Utils
    include ActionView::Helpers::NumberHelper

    scheduled_payments = ScheduledPayment.find(:all, :conditions => ["draft_date = ?",Date.today])
    puts "#{scheduled_payments.size} scheduled payments for today(including ACH and CC)."
    cc_payments = 0
    scheduled_payments.each do |scheduled_payment|
      if scheduled_payment.payment_account.account.class == CreditCard
        cc_payments += 1
        cim_gateway = get_authnet_cim_payment_gateway
        transaction_hash = {
            :type => :auth_capture,
            :amount => number_with_precision(scheduled_payment.amount, :precision => 2),
            :customer_profile_id => scheduled_payment.customer.authnet_customer_profile_id,
            :customer_payment_profile_id => scheduled_payment.payment_account.authnet_payment_profile_id
          }
        response = nil
        error_message = nil

        LoanTransaction.transaction do
          begin
            response = cim_gateway.create_customer_profile_transaction(
              :transaction => transaction_hash
            )
            puts "response to create_customer_profile_transaction: #{response.inspect}"
            if response.success?
              loan_transaction = LoanTransaction.create!(
                :loan => scheduled_payment.loan,
                :tran_type => LoanTransaction::PAYMENT,
                :total => scheduled_payment.amount * -1,
                :principal => scheduled_payment.principal * -1,
                :interest => scheduled_payment.interest * -1,
                :fees => scheduled_payment.fees * -1,
                :payment_account => scheduled_payment.payment_account
              )
              scheduled_payment.loan.update_amounts_owed
              scheduled_payment.loan.save!

              scheduled_payment.destroy
            end
          rescue Exception => e
            error_message = e.message
          rescue => e
            error_message = e
          end
        end # transaction
      end # Credit Card
    end #loop
    puts "#{cc_payments} credit card payments processed."
  end

  desc 'Upload pending ACH transactions and scheduled payments to Advantage ACH'
  task :upload_to_advantage_ach => :environment do
    include ActionView::Helpers::NumberHelper

    advantage_ach = AchProvider.find_by_name('Advantage ACH')
    raise Exception.new('Advantage ACH not found') unless advantage_ach
    puts "advantage_ach => #{advantage_ach.inspect}"
    n = AchBatch.count(:conditions => ["batch_date = ?",Date.today]) + 1
    ach_batch = AchBatch.new(:ach_provider_id => advantage_ach.id, :file_name => "flobridge_#{Date.today.to_s(:yymmdd)}_#{n}.csv")
    puts "ach_batch: #{ach_batch.inspect}"
    ach_batch.save
    ach_batch.csv = ''

    #
    # Approved Loans Awaiting Funding
    #
    approved_loans = Loan.find(:all, :conditions => ["aasm_state = 'approved'"])
    approved_loans.each do |loan|
      puts "loan id: #{loan.id}"
      LoanTransaction.transaction do
        begin
          loan.fund

          bank_account = loan.customer.bank_accounts.funding_accounts.first

          line =  "#{ADVANTAGE_ACH_CONFIG[:origin_id]},FloBridge,#{ADVANTAGE_ACH_CONFIG[:origin_id]},FloBridge,"
          line += "PPD,8665693321,#{Date.next_business_day.to_s(:yymmdd)},#{loan.id},#{loan.customer.full_name[0,22].gsub(/,/,' ')},"
          line += "#{bank_account.bank_aba_number},#{bank_account.bank_account_number},22,#{number_with_precision(loan.approved_loan_amount, :precision => 2)}"
          line += ",,,#{loan.loan_transactions.first.id}"

          ach_batch.credits += 1
          ach_batch.credit_amount += loan.approved_loan_amount
          ach_batch.csv += "#{line}\n"
          ach_batch.save!
        rescue Exception => e
          puts "Caught Exception: #{e.class.to_s} #{e.message}"
        rescue => e
          puts "Caught Exception: #{e}"
        end
      end
    end

    #
    # Loans where recission has been requested
    #
    rescinded_loans = Loan.find(:all, :conditions => ["aasm_state = 'recission_requested'"])
    rescinded_loans.each do |loan|

      LoanTransaction.transaction do
        begin
          bank_account = loan.customer.bank_accounts.funding_accounts.first
          loan.mark_as_recission_draft_submitted(ach_batch.id,Date.next_business_day,bank_account)

          line =  "#{ADVANTAGE_ACH_CONFIG[:origin_id]},FloBridge,#{ADVANTAGE_ACH_CONFIG[:origin_id]},FloBridge,"
          line += "PPD,8665693321,#{Date.next_business_day.to_s(:yymmdd)},#{loan.id},#{loan.customer.full_name[0,22].gsub(/,/,' ')},"
          line += "#{bank_account.bank_aba_number},#{bank_account.bank_account_number},27,#{number_with_precision(loan.principal_owed, :precision => 2)}"

          ach_batch.credits += 1
          ach_batch.credit_amount += loan.approved_loan_amount
          ach_batch.csv += "#{line}\n"
          ach_batch.save!
        rescue Exception => e
          puts "Caught Exception: #{e.class.to_s} #{e.message}"
        rescue => e
          puts "Caught Exception: #{e}"
        end
      end
    end


    #
    # Scheduled Payments
    #
    scheduled_payments = ScheduledPayment.find(:all, :conditions => ["draft_date <= ?", Date.today])
    scheduled_payments.each do |scheduled_payment|
      puts "processing scheduled payment"
      if scheduled_payment.payment_account.account.class == BankAccount
        LoanTransaction.transaction do
          begin
            loan_transaction = LoanTransaction.create!(
              :loan => scheduled_payment.loan,
              :tran_type => LoanTransaction::PAYMENT,
              :total => scheduled_payment.amount * -1,
              :principal => scheduled_payment.principal * -1,
              :interest => scheduled_payment.interest * -1,
              :fees => scheduled_payment.fees * -1,
              :payment_account => scheduled_payment.payment_account
            )
            scheduled_payment.loan.update_amounts_owed
            scheduled_payment.loan.save!

            ach_batch.loan_transactions << loan_transaction


            line =  "#{ADVANTAGE_ACH_CONFIG[:origin_id]},FloBridge,#{ADVANTAGE_ACH_CONFIG[:origin_id]},FloBridge,"
            line += "PPD,8665693321,#{Date.next_business_day.to_s(:yymmdd)},#{scheduled_payment.loan_id},#{scheduled_payment.loan.customer.full_name[0,22].gsub(/,/,' ')},"
            line += "#{scheduled_payment.payment_account.account.bank_aba_number},#{scheduled_payment.payment_account.account.bank_account_number},27,#{number_with_precision(scheduled_payment.amount, :precision => 2)}"
            line += ",,,#{loan_transaction.id}"

            ach_batch.debits += 1
            ach_batch.debit_amount += scheduled_payment.amount
            ach_batch.csv += "#{line}\n"
            ach_batch.save!
            scheduled_payment.destroy
          rescue Exception => e
            puts "Caught Exception: #{e.class.to_s} #{e.message}"
          rescue => e
            puts "Caught Exception: #{e}"
          end
        end
      end
    end

#    ach_batch.save
    ach_batch.create_tmp_file

    puts "After creating batch temp file, ach_batch: #{ach_batch.inspect}"
    lines = ach_batch.csv.split('\n')
    lines.each do |line|
      puts "#{line}"
    end

    # Secure FTP to Advantage ACH
    Net::SFTP.start(ADVANTAGE_ACH_CONFIG[:host],ADVANTAGE_ACH_CONFIG[:login_id], :password => ADVANTAGE_ACH_CONFIG[:password]) do |sftp|
      puts "Uploading..."
      sftp.upload!("#{RAILS_ROOT}/db/advantage_ach/tranfile/#{ach_batch.file_name}","/tranfile/#{ach_batch.file_name}")
      puts "Done Uploading..."
    end

    # Notify Advantage ACH by email
    Mailer.deliver_notify_advantage_ach_of_upload(ach_batch)
  end

  desc 'Get return files from Advantage ACH'
  task :get_return_files_from_advantage_ach => :environment do
    advantage_ach = AchProvider.find_by_name('Advantage ACH')
    raise Exception.new('Advantage ACH not found') unless advantage_ach

    Net::SFTP.start(ADVANTAGE_ACH_CONFIG[:host],ADVANTAGE_ACH_CONFIG[:login_id], :password => ADVANTAGE_ACH_CONFIG[:password]) do |sftp|
      returns = sftp.dir.entries("/returns").map { |e| e.name }
      puts "Downloading..."
      sftp.dir.glob("/returns","*.csv") do |entry|
        puts "#{entry.name}"
        remote_filename = "/returns/#{entry.name}"
        local_filename = "#{RAILS_ROOT}/db/advantage_ach/returns/#{entry.name}"
        sftp.download!(remote_filename,local_filename)

        # Create an AchReturn record for each line in the file just downloaded
        FasterCSV.foreach(local_filename) { |row|
          puts "  row: #{row.inspect}"
          AchReturn.transaction do
            begin
              loan_transaction_id = row.size >= 11 ? row[11].to_i : nil
              # There might not be a loan transaction id. For example, a draft on a recission request does not generate a loan transaction
              # at the time the draft is submitted.  In that case, we should create the loan transaction when we either get a return
              # or a successful transaction.
              loan_transaction = nil
              loan_transaction = LoanTransaction.find(loan_transaction_id) if loan_transaction_id

              amount = row[6].to_i/100.0
              loan_id = row[7].to_i
              ach_return = AchReturn.create!(
                :ach_provider_id => advantage_ach.id,
                :company_identifier => row[0],
                :company_name => row[1],
                :ee_date => row[2],
                :transaction_code => row[3],
                :routing_number => row[4],
                :account_number => row[5],
                :amount => amount,
                :loan_id => loan_id,
                :customer_name => row[8],
                :return_reason_code => row[9],
                :correction_info => row[10],
                :loan_transaction_id => loan_transaction_id
              )

              if loan_transaction
                loan_transaction.principal = 0
                loan_transaction.interest = 0
                loan_transaction.fees = 0
                loan_transaction.failed_total = amount
                loan_transaction.nsf = (row[9] == 'R01')
                loan_transaction.account_closed = (row[9] == 'R02')
                loan_transaction.ach_return_code = row[9]
                loan_transaction.ach_return_reason = ADVANTAGE_ACH_RETURN_CODES[row[9]]
                loan_transaction.save!
              else
                loan = Loan.find(loan_id)
                loan_transaction = LoanTransaction.create!(
                  :loan => loan,
                  :tran_type => LoanTransaction::PAYMENT,
                  :total => 0,
                  :principal => 0,
                  :interest => 0,
                  :fees => 0,
                  :failed_total => amount,
                  :nsf => (row[9] == 'R01'),
                  :account_closed => (row[9] == 'R02'),
                  :ach_return_code => row[9],
                  :ach_return_reason => ADVANTAGE_ACH_RETURN_CODES[row[9]]
                )
              end

              ach_return.processed_at = Time.now
              ach_return.save!

              # Handle consequences of ACH return on the loan
              loan = loan_transaction.loan
              loan.handle_ach_return(ach_return)
            rescue Exception => e
              puts "Caught exception: #{e.class.to_s} #{e.message}"
            rescue => e
              puts "Caught exception: #{e}"
            end
          end
        }

        # Upload the file back to the server in the /returns/archive directory
        puts "  Uploading to /returns/archive directory..."
        sftp.upload!(local_filename,"/returns/archive/#{entry.name}")
        puts "  Uploaded to archives, deleting from /returns directory ..."
        sftp.remove!(remote_filename)
        puts "  "
      end
      puts "Ending sFTP session"
    end
  end

  desc 'Create settlement.csv file for loans where recission requested and draft submitted.  Upload to /reports on Advantage ACH server'
  task :create_test_settlement_file do
    loans = Loan.find(:all, :conditions => ["aasm_state = 'recission_draft_submitted'"], :include => :recission_bank_account)
    csv = ''
    loans.each do |loan|
      line  = "1234567890,Flobridge Group,#{loan.recission_draft_ach_batch_id},Flobridge Group,"
      line += "RCK,REDEPCHECK,#{loan.recission_draft_on.to_s(:yymmdd)},#{loan.id},#{loan.customer.full_name[0,22]},"
      line += "#{loan.recission_bank_account.bank_aba_number},#{loan.recission_bank_account.bank_account_nunmber},27,"
      line += "#{number_with_precision(loan.principal_owed, :precision => 2)},,,,F,\n"
      csv += line
    end

    File.open("#{RAILS_ROOT}/db/advantage_ach/reports/settlement.csv", 'w') {|f| f.write(csv) }

    Net::SFTP.start(ADVANTAGE_ACH_CONFIG[:host],ADVANTAGE_ACH_CONFIG[:login_id], :password => ADVANTAGE_ACH_CONFIG[:password]) do |sftp|
      sftp.upload!("#{RAILS_ROOT}/db/advantage_ach/reports/settlement.csv","/reports/settlement.csv")
    end
  end

  desc 'Test String Substitution'
  task :test => :environment do

    loan = Loan.first
    customer = loan.customer

    s = "Hello {{customer.first_name}}"
    puts "before prep: #{s}"
    ready_for_eval = s.prep_for_eval
    puts "ready_for_eval: #{ready_for_eval}"
    puts "After eval: " + eval(ready_for_eval)
  end
end