namespace :db do

  desc 'Import Customers/Loans'
  task :import_customers_and_loans => :environment do
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TextHelper
    ActiveRecord::Base.connection.execute("ALTER TABLE customers MODIFY id INT NOT NULL")
    ActiveRecord::Base.connection.execute("ALTER TABLE loans MODIFY id INT NOT NULL")
    if RAILS_ENV != 'production'
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE customers")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE loans")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE bank_accounts")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE logs")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE comments")
    end

    ACCOUNT_NUMBER = 0
    LOAN_NUMBER = 1
    XML_LEAD_REF_ID = 2
    STORE = 3
    XML_LEAD_ACCOUNT = 4
    FIRST_NAME = 5
    LAST_NAME = 6
    SSN = 7
    EMAIL = 8
    DOB = 9
    HOME_PHONE = 10
    WORK_PHONE = 11
    CELL_PHONE = 12
    HOME_ADDRESS = 13
    HOME_CITY = 14
    HOME_STATE = 15
    HOME_ZIP = 16
    BEST_TIME_TO_CALL = 17
    MONTHLY_INCOME = 18
    PAY_FREQUENCY = 19
    EMPLOYER = 20
    WORK_FAX = 21
    SUPERVISOR_NAME = 22
    SUPERVISOR_PHONE = 23
    LANDLORD_PHONE = 24
    NEXT_PAY_DAY = 25
    CREDIT_LIMIT = 26
    STATUS = 27
    DENIAL_REASON = 28
    ADVERTISING_METHOD = 29
    LANGUAGE = 30
    PREFERRED_PHONE = 31
    ABA = 32
    BANK_NAME = 33
    BANK_PHONE = 34
    CHECKING_ACCOUNT_NUMBER = 35
    APR = 36
    LOAN_AMOUNT = 37
    INTEREST_PLUS_FEES = 38
    TOTAL_PAYMENTS = 39
    DAYS_PAST_DUE = 40
    PRINCIPAL_DUE = 41
    INTEREST_DUE = 42
    BACK_INTEREST_DUE = 43
    NSF_FEE_DUE = 44
    LATE_FEE_DUE = 45
    CONVENIENCE_FEE_DUE = 46
    FEES_DUE = 47
    BACK_INTEREST_PLUS_FEES_DUE = 48
    TOTAL_INTEREST_PLUS_FEES_DUE = 49
    TOTAL_DUE = 50
    LOAN_DATE_TIME = 51
    APPROVE_DATE_TIME = 52
    EMP_APPROVED = 53
    DENIAL_DATE = 54
    EMP_DENIED = 55
    EMP_REVERSED = 56
    CREATED = 57
    ORIG_DATE = 58
    DUE_DATE = 59
    DUE_DATE_BEFORE_PAYMENT_HOLD = 60
    BANKRUPTCY_DATE = 61
    LAST_PAYMENT_DATE = 62
    LAST_PAYMENT_DAYS_LATE = 63
    DAYS_SINCE_LAST_PAYMENT = 64
    RETURN_CODE = 65
    PRINCIPAL_PAID = 66
    INTEREST_PAID = 67
    BACK_INTEREST_PAID = 68
    NSF_FEE_PAID = 69
    LATE_FEE_PAID = 70
    CONVENIENCE_FEE_PAID = 71
    FEES_PAID = 72
    BACK_INTEREST_PLUS_FEES_PAID = 73
    TOTAL_INTEREST_PLUS_FEES_PAID = 74
    TOTAL_PAID = 75
    COLLECTED_BY_COLLECTIONS_ADMIN = 76
    WRITE_OFF_DATE = 77
    EMP_WROTE_OFF = 78
    PAYOFF_DATE = 79
    FILE_DATE = 80
    COURT_DATE = 81
    COLLECTION_AGENCY = 82
    EMP_CREATED = 83
    N_R = 84
    COLLECTIONS_ASSIGNED_TO = 85
    NOTES = 86
    PENDING_REMARK = 87
    MATURITY_DATE = 88
    MATURITY_PERIOD = 89
    PROMOTIONAL_CODE = 90
    LOAN_LENGTH = 91
    EXTENSIONS_COUNT = 92


    def portfolio_id_from_name(store)
      case store
      when 'FBG sid1'
        return 1
      when 'FBGsid1'
        return 1
      when 'FBML1sid3'
        return 2
      end
    end

    def pay_frequency(freq)
      case freq
      when 'Weekly'
        return 'WEEKLY'
      when 'Twice per Month'
        return 'TWICE_MONTHLY'
      when 'Bi-weekly'
        return 'BI_WEEKLY'
      when 'Monthly'
        return 'MONTHLY'
      end
      'TWICE_MONTHLY'
    end

    def date_from_string(str)
      return nil if str.blank?
      date_portion = str.split(' ')[0]
      date_parts = date_portion.split('/')
      month = date_parts[0].to_i
      day = date_parts[1].to_i
      year = date_parts[2].to_i
      year += 2000 if year <= 10
      year += 1900 if year > 10 and year < 100
      Date.civil(year,month,day)
    end

    def datetime_from_string(str)
    end

    def amount(str)
      str.gsub(/\$/,'').to_f
    end

    def payday_2(payday,frequency)
      case frequency
      when 'WEEKLY'
        payday + 1.week
      when 'BI_WEEKLY'
        payday + 2.weeks
      when 'TWICE_MONTHLY'
        payday + 15.days
      when 'MONTHLY'
        payday + 1.month
      end
    end

    def select_aasm_state(loan)
      return 'denied' unless loan.reject_reason.blank?
      return 'written_off' if loan.written_off_on
      aasm_state = 'pending_underwriting'
      aasm_state = 'underwriting' if loan.underwriter_id
      aasm_state = 'approved' if loan.approved_at && loan.approved_loan_amount
      aasm_state = 'active' if loan.funded_on
      aasm_state = 'collections' if loan.collections_agent_id
      aasm_state = 'garnishments' if loan.garnishments_agent_id
      aasm_state = 'paid_in_full' if loan.funded_on and loan.paid_in_full_on and loan.principal_owed == 0 and loan.interest_owed == 0 and loan.fees_owed == 0
      aasm_state
    end

    def set_loan_aasm_state(loan)
      loan.aasm_state = select_aasm_state(loan)
      loan.save!
    end

    def find_user_by_name(name)
      return nil if name.nil?
      return nil if name == 'PLM Support'
      name_parts = name.split(' ')
      first_name = name_parts[0]
      last_name  = name_parts[1]
      User.find(:first, :conditions => ["first_name = ? and last_name = ?",first_name, last_name])
    end

    robot = User.first
    
    collections_manager = User.find_by_username('kario')
    garnishments_manager = User.find_by_username('')

    users_not_found = []
    row_number = 0
    file_name = RAILS_ENV == 'production' ? "/home/deploy/plt/shared/import/customers.txt" : "/Users/bob/test/customers.txt"
    FasterCSV.foreach(file_name, :col_sep => "\t") do |row|
      row_number += 1
      next if row_number == 1
      puts row_number if row_number % 100 == 0
      next unless row[0]
      c = Customer.find_by_id(row[0])
      unless c
        c = Customer.new
        c.id = row[0].to_i
        c.portfolio_id = portfolio_id_from_name(row[3])
        c.ip_address = '174.143.205.24'
        c.lead_source = row[XML_LEAD_REF_ID]
        c.relaxed_validation = true
        c.first_name =  row[FIRST_NAME]
        c.last_name = row[LAST_NAME]
        c.ssn = row[SSN]
        c.email = row[EMAIL].downcase unless row[EMAIL].blank?
        c.birth_date = date_from_string(row[DOB]) unless row[DOB].blank?
        c.dl_number = ''
        c.dl_state = row[HOME_STATE]
        c.military = false
        c.home_phone = row[HOME_PHONE].gsub(/-/,'') unless row[HOME_PHONE].nil?
        c.work_phone = row[WORK_PHONE].gsub(/-/,'') unless row[WORK_PHONE].nil?
        c.cell_phone = row[CELL_PHONE].gsub(/-/,'') unless row[CELL_PHONE].nil?
        c.address = row[HOME_ADDRESS]
        c.city = row[HOME_CITY]
        c.state = row[HOME_STATE]
        c.zip = row[HOME_ZIP]
        c.country_code = 'US'
        c.monthly_income = row[MONTHLY_INCOME].gsub(/[$,]/,'').to_i unless row[MONTHLY_INCOME].nil?
        c.income_source = 'EMPLOYMENT'
        c.pay_frequency = pay_frequency(row[PAY_FREQUENCY])
        c.employer_name = row[EMPLOYER][0,30] unless row[EMPLOYER].nil?
        c.months_employed = 0
        c.employer_phone = row[SUPERVISOR_PHONE].gsub(/-/,'') unless row[SUPERVISOR_PHONE].blank?
        c.employer_fax = row[WORK_FAX].gsub(/-/,'') unless row[WORK_FAX].blank?
        c.supervisor_name = row[SUPERVISOR_NAME]
        c.supervisor_phone = row[SUPERVISOR_PHONE].gsub(/-/,'') unless row[SUPERVISOR_PHONE].blank?
        c.residence_type = 'RENT'
        c.monthly_residence_cost = 0
        c.months_at_address = 0
        c.bank_name = truncate(row[BANK_NAME], :length => 30)
        c.bank_name = 'Unknown' if c.bank_name.blank?
        c.bank_phone = row[BANK_PHONE].gsub(/-/,'') unless row[BANK_PHONE].blank?
        c.bank_account_type = 'CHECKING'
        c.months_at_bank = 0
        c.bank_aba_number = row[ABA]
        c.bank_account_number = row[CHECKING_ACCOUNT_NUMBER]
        c.bank_direct_deposit = true
        unless row[NEXT_PAY_DAY].blank?
          c.next_pay_date_1 = date_from_string(row[NEXT_PAY_DAY])
          c.next_pay_date_2 = payday_2(c.next_pay_date_1,c.pay_frequency)
        end
        c.credit_limit = row[CREDIT_LIMIT].to_f unless row[CREDIT_LIMIT].blank?
        c.time_zone = 'America/Boise'

        c.suppress_default_loan = true
        c.imported = true
        c.save!
      end

      # Create the loan
      log_message = nil
      loan = Loan.new
      loan.imported = true
      loan.id = row[LOAN_NUMBER].to_i
      loan.aasm_state = 'garnishments'
      loan.customer_id = c.id
      loan.portfolio_id = c.portfolio_id
      loan.due_date = date_from_string(row[DUE_DATE])
      loan.requested_loan_amount = amount(row[LOAN_AMOUNT])
      loan.apr = row[APR].to_f
      loan.principal_owed = amount(row[PRINCIPAL_DUE])
      loan.interest_owed = amount(row[INTEREST_DUE])
      loan.fees_owed = amount(row[FEES_DUE])
      loan.amounts_owed_updated_on = Date.today

      # Underwriting
      underwriter = find_user_by_name(row[EMP_APPROVED])
      underwriter = find_user_by_name(row[EMP_DENIED]) unless underwriter
      loan.underwriter_id = underwriter.id if underwriter
      loan.reject_reason = row[DENIAL_REASON]

      loan.signature_page_loan_amount = amount(row[LOAN_AMOUNT])
      loan.signature_page_finance_charge = 0
      loan.signature_page_ip_address = '127.0.0.1'
      loan.signature_page_accepted_name = c.full_name


      # Approval
      underwriter = find_user_by_name(row[EMP_APPROVED])
      loan.approved_by = underwriter.id if underwriter
      loan.approved_at = DateTime.parse(row[APPROVE_DATE_TIME]) unless row[APPROVE_DATE_TIME].blank?
      loan.approved_loan_amount = amount(row[LOAN_AMOUNT])

      # Funding
      loan.funded_on = DateTime.parse(row[LOAN_DATE_TIME]).to_date unless row[LOAN_DATE_TIME].blank?

      # Payoff
      loan.paid_in_full_on = date_from_string(row[PAYOFF_DATE])

      # Collections & Garnishments
      name = row[COLLECTIONS_ASSIGNED_TO]
      unless name.blank?
        if name != 'PLM Support'
          name = 'Anna Fernandini' if name == 'Ana Fernandini'
          name = 'Britain Baker' if name == 'Britian Baker'
          agent = find_user_by_name(name)
          if agent
            if agent.role == 'garnishments'
              if agent.login_suspended && amount(row[TOTAL_DUE]) > 0
                loan.garnishments_agent_id = garnishments_manager.id
                log_message = "Import automatically re-assigned from #{agent.full_name} to #{garnishments_manager.full_name} because loan is collectable"
              else
                loan.garnishments_agent_id = agent.id
              end
            else
              if agent.login_suspended && amount(row[TOTAL_DUE]) > 0
                loan.collections_agent_id = collections_manager.id
                log_message = "Import automatically re-assigned from #{agent.full_name} to #{collections_manager.full_name} because loan is collectable"
              else
                loan.collections_agent_id = agent.id
              end
            end
            loan.collections_agent_type = 'User'
          else
            puts "Employee Not Found - #{name}"
            users_not_found << name
          end
        end
      end

      written_off_by_user = find_user_by_name(row[EMP_WROTE_OFF])
      loan.written_off_by = written_off_by_user.id if written_off_by_user
      loan.written_off_on = date_from_string(row[WRITE_OFF_DATE]) unless row[WRITE_OFF_DATE].blank?

      loan.extensions_granted = row[EXTENSIONS_COUNT].to_i
      loan.suppress_messages_after_create = true
      loan.created_at = Date.parse(row[CREATED])
      loan.save!
      set_loan_aasm_state(loan)
      loan.logs << Log.new(:message => log_message, :user => robot) if log_message
      loan.add_comment(row[NOTES],robot) unless row[NOTES].blank?
    end
    ActiveRecord::Base.connection.execute("ALTER TABLE customers MODIFY id INT NOT NULL AUTO_INCREMENT")
    ActiveRecord::Base.connection.execute("ALTER TABLE loans MODIFY id INT NOT NULL AUTO_INCREMENT")

    puts "Users Not Found: #{users_not_found.inspect}"
  end

  desc 'Import Loan Transactions'
  task :import_payments => :environment do
    row_number = 0
    file_name = RAILS_ENV == 'production' ? "/home/deploy/plt/shared/import/payments.txt" : "/Users/bob/test/payments.txt"
    FasterCSV.foreach(file_name, :col_sep => "\t") do |row|
      row_number += 1
      next if row_number <= 2
      next if row[0].blank?
      loan_id = row[0].to_i
      puts "loan_id: #{loan_id}"
      loan = Loan.find(loan_id)
      for i in 0..12
        base = 2+(i*6)
        tran_type = row[base]
        if tran_type
          tran_date = Date.parse(row[base+2])
          interest  = row[base+3].to_f * -1
          fees      = row[base+4].to_f * -1
          principal = row[base+5].to_f * -1
          total = interest + fees + principal
          puts "#{tran_type} #{tran_date.to_s(:m_d_y)} p: #{principal} i: #{interest} f: #{fees}"
          LoanTransaction.create!(
            :loan_id => loan_id,
            :tran_type => 'payment',
            :total => total,
            :principal => principal,
            :interest => interest,
            :fees => fees,
            :payment_account_id => loan.customer.default_funding_payment_account.id,
            :created_at => tran_date,
            :updated_at => tran_date
          )
        end
      end
    end
  end
end