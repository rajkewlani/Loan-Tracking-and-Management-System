  namespace :db do
  
  desc "Erase and fill database with demo data"
  task :populate => :environment do
    
    require 'common'
    require 'populator'
    require 'faker'
    require 'digest/sha1'
    
    # Delete All Data
    User.destroy_all ["role = 'underwriter' or role = 'collections' or role='garnishments'"]
    ActiveRecord::Base.connection.execute("truncate table comments")
    ActiveRecord::Base.connection.execute("truncate table logs")
    ActiveRecord::Base.connection.execute("truncate table factor_trusts")
    ActiveRecord::Base.connection.execute("truncate table customers")
    ActiveRecord::Base.connection.execute("truncate table user_comment_notifications")
    ActiveRecord::Base.connection.execute("truncate table loans")
    ActiveRecord::Base.connection.execute("truncate table loan_transactions")
    ActiveRecord::Base.connection.execute("truncate table loan_snapshots")
    ActiveRecord::Base.connection.execute("truncate table bank_accounts")
    ActiveRecord::Base.connection.execute("truncate table credit_cards")
    ActiveRecord::Base.connection.execute("truncate table payment_accounts")
    ActiveRecord::Base.connection.execute("truncate table teams")
    ActiveRecord::Base.connection.execute("truncate table investors")
    ActiveRecord::Base.connection.execute("truncate table lead_providers")

    def occupation
      list = ["Actress", "Aerospace Engineer", "Air Traffic Controller", "Anaesthetist", "Anchorman", "Archaeologist", "Banker", "Babysitter", "Bassoonist", "Beauty therapist", "Bookkeeper", "Bookseller", "Cab driver", "Calligrapher", "Cameraman", "Camp counsellor", "Car designer", "Cardiologist", "Carpenter", "Cartographer", "Cellist", "Chess player", "Chief technology officer", "CFO", "CBDO", "Chemical Technologist", "Civil servant", "Clarinetist", "Communist", "Company Secretary", "Computer programmer", "Conductor (music)", "Construction engineer", "Correctional officer", "Proofreader", "Cosmetologist", 
              "Costume Designer", "Court jester", "CPA (Certified Public Accountant)", "Craftswoman", "Creative engineering", "Crofter", "Cryptographer", "Dancer", "Dentist", "Dermatologist", "Distiller", "Dock labourer", "Dog walker", "Domainer", "Dramatist", "Dramaturg", "Ecologist", "Educationalist", "Educator", "Egyptologist", "Electrical engineer", "Embalmer", "Engine driver", "Engraver", "Entomologist", "Environmental scientist", "Ergonomist", "Ethnologist", "Ethologist", "Corporate officer", "Fashion designer", "FBI Agent", "Ferryman", "Financial manager", "First Mate", "Florist", "Flutist", "Fortune teller", 
              "Fruiterer", "Furrier", "Gardener", "Gastroenterologist", "Genealogist", "General", "Geometer", "Geophysicist", "Government agent", "Grammarian", "Graphic artist", "Graphic Designer", "Guardian Ad Litem", "Gynecologist", "Harpist", "Handyman", "Hairdresser", "Harpist", "Headmaster", "Headmistress", "Historiographer", "Homoeopaths", "Hosier", "Illusionist", "Importer", "Industrial engineer", "Industrialist", "Information Technologist", "Innkeeper", "Interpreter (communication)", "Interrogator", "Investment banker", "Jailer", "Jeweller", "Kinesiologist", "Laundress", "Lavendar", "Law enforcement agent", 
              "Leadworker", "Leatherer", "Librettist", "Lobbyist", "Locksmith", "Postman", "Management consultant", "Manicurist", "Manufacturer", "Marine (armed services)", "Marine biologist", "Market gardener", "Martial artist", "Master of Ceremony", "MC", "Massage therapist", "Masseuse", "Masseur", "Matador", "Medical billing", "Medical Transcriptionist", "Mesmerist", "Mid-wife", "Modeller", "Moneychanger", "Muralist", "Negotiator", "Neurologist", "Newscaster", "Nightwatchmen", "Novelist", "Numerologist", "Numismatist", "Oboist", "Obstetrician", "Odontologist", "Oncologist", "Ontologist", "Ophthalmologist", "Optometrist", 
              "Ornithologist", "Otorhinolaryngologist", "Paleontologist", "Parole Officer", "Pathologist", "Pediatrician", "Percussionist", "Personal Trainer", "Philanthropist", "Philologist", "Philosopher", "Physical Therapist", "Physician Assistant", "Physiognomist", "Physiotherapist", "Piano tuner", "Pilot (shipping)", "Pirate", "Podiatrist", "Police inspector", "Press officer", "Principal (school)", "Private detective", "Probation Officer", "Proctologist", "Professional dominant", "Project Manager", "Proofreader", "Psychodramatist", "Press officer", "Publisher", "Porn star", "Quilter", "Radiologist", "Radiographer", 
              "Real estate developer", "Record Producer", "Refuse collector", "Respiratory Therapist", "Restaurateur", "Retailer", "Sanitation worker", "Saxophonist", "School superintendent", "Seamstress", "Secretary general", "Senator", "Search Engine Optimization", "Sheepshearer", "Shoemaker", "Skydiver", "Social worker", "Sound Engineer", "Speech therapist", "Spy", "Street vendor", "Structural engineers", "Surveyor (surveying)", "Swimmer", "Tanner (occupation)", "Tapicer", "Tapicer", "Tapicer", "Tax Collector", "Taxidermist", "Taxicab driver", "Taxonomist", "Technical Writer", "Telegrapher", "Tennis player", "Thatcher (profession)", 
              "Therapist", "Thimbler", "Tiler", "Toolmaker", "Transit planner", "Truck Driver", "Typist", "Undertaker", "Ufologist", "Undercover agent", "Underwriter", "Upholsterer", "Urologist", "Vibraphonist", "Video editor", "Vintner", "Violist", "Voice Actor", "Waiter", "Waiter", "Web designer", "Woodcarver", "Wood cutter", "Xylophonist", "Yodeler", "Zoologist"]
      return list[rand(list.length)]
    end

    workstation = Location.find_all_by_name('Development Workstation (localhost)')

    # Create Teams
    underwriter_team  = Team.create!(:name => 'Underwriters Test', :role => 'underwriter')
    underwriter_team_1  = Team.create!(:name => 'Underwriters 1', :role => 'underwriter')
    underwriter_team_2  = Team.create!(:name => 'Underwriters 2', :role => 'underwriter')
    collections_team  = Team.create!(:name => 'Collections Test', :role => 'collections')
    collections_team_1  = Team.create!(:name => 'Collections Team 1', :role => 'collections')
    garnishments_team = Team.create!(:name => 'Garnishments Test', :role => 'garnishments')
    garnishments_team_1 = Team.create!(:name => 'Garnishments Team 1', :role => 'garnishments')

    # Create Underwriters
    underwriter = User.create!(:username => "underwriter",
                :email => "underwriter@paydayloantracker.com",
                :password => "underwriter",
                :password_confirmation => "underwriter",
                :role => User::UNDERWRITER,
                :first_name => "Larry",
                :last_name => "Ellsworth",
                :team_id => underwriter_team.id)

    underwriter.locations = workstation
    underwriter.save

    underwriter2 = User.create!(:username => "underwriter2",
                :email => "underwriter2@paydayloantracker.com",
                :password => "underwriter",
                :password_confirmation => "underwriter",
                :role => User::UNDERWRITER,
                :first_name => "Ben",
                :last_name => "Bernanke",
                :team_id => underwriter_team.id)

    underwriter2.locations << workstation
    underwriter2.save

    underwriter3 = User.create!(:username => "underwriter3",
                :email => "underwriter3@paydayloantracker.com",
                :password => "underwriter",
                :password_confirmation => "underwriter",
                :role => User::UNDERWRITER,
                :first_name => "Timothy",
                :last_name => "Geithner",
                :team_id => underwriter_team.id)

    underwriter3.locations << workstation
    underwriter3.save

    underwriter4 = User.create!(:username => "underwriter4",
                :email => "underwriter4@paydayloantracker.com",
                :password => "underwriter",
                :password_confirmation => "underwriter",
                :role => User::UNDERWRITER,
                :first_name => "Lawrence",
                :last_name => "Summers",
                :team_id => underwriter_team.id)

    underwriter4.locations << workstation
    underwriter4.save


    # Create Collections Agents
    collector = User.create!(:username => "collector",
                :email => "collector@paydayloantracker.com",
                :password => "collector",
                :password_confirmation => "collector",
                :role => User::COLLECTIONS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => collections_team.id)

    collector.locations = workstation
    collector.save

    collector2 = User.create!(:username => "collector2",
                :email => "collector2@paydayloantracker.com",
                :password => "collector",
                :password_confirmation => "collector",
                :role => User::COLLECTIONS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => collections_team.id)

    collector2.locations = workstation
    collector2.save

    collector3 = User.create!(:username => "collector3",
                :email => "collector3@paydayloantracker.com",
                :password => "collector",
                :password_confirmation => "collector",
                :role => User::COLLECTIONS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => collections_team.id)

    collector3.locations = workstation
    collector3.save

    collector4 = User.create!(:username => "collector4",
                :email => "collector4@paydayloantracker.com",
                :password => "collector",
                :password_confirmation => "collector",
                :role => User::COLLECTIONS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => collections_team.id)

    collector4.locations = workstation
    collector4.save

    # Collection Agents


    # Create Garnisihments Agents
    garnisher = User.create!(:username => "garnisher",
                :email => "garnisher@paydayloantracker.com",
                :password => "garnisher",
                :password_confirmation => "garnisher",
                :role => User::GARNISHMENTS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => garnishments_team.id)

    garnisher.locations = workstation
    garnisher.save

    garnisher2 = User.create!(:username => "garnisher2",
                :email => "garnisher2@paydayloantracker.com",
                :password => "garnisher",
                :password_confirmation => "garnisher",
                :role => User::GARNISHMENTS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => garnishments_team.id)

    garnisher2.locations = workstation
    garnisher2.save

    garnisher3 = User.create!(:username => "garnisher3",
                :email => "garnisher3@paydayloantracker.com",
                :password => "garnisher",
                :password_confirmation => "garnisher",
                :role => User::GARNISHMENTS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => garnishments_team.id)

    garnisher3.locations = workstation
    garnisher3.save

    garnisher4 = User.create!(:username => "garnisher4",
                :email => "garnisher4@paydayloantracker.com",
                :password => "garnisher",
                :password_confirmation => "garnisher",
                :role => User::GARNISHMENTS,
                :first_name => Faker::Name.first_name,
                :last_name => Faker::Name.last_name,
                :team_id => garnishments_team.id)

    garnisher4.locations = workstation
    garnisher4.save

    # Garnishment Agents


    # Enable all locations for all users
    locations = Location.find(:all)
    users = User.find(:all)
    users.each do |user|
      user.locations = locations
    end

    portfolios = Portfolio.find(:all)
    portfolio_1 = portfolios[0]
    portfolio_2 = portfolios[1]
    
    # Portfolio_snapshot
    portfolio_snapshot_1 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 20, :reloans_today => 20, :total_loans_today => 40, :reloan_percentage => 50, :loans_out_today => 10, :total_loans_to_date => 70, :snapshot_on => (Date.today.to_date - 4).strftime('%Y-%m-%d'))
    portfolio_snapshot_2 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 15, :reloans_today => 30, :total_loans_today => 45, :reloan_percentage => 66.67, :loans_out_today => 20, :total_loans_to_date => 85, :snapshot_on => (Date.today.to_date - 4).strftime('%Y-%m-%d'))
    portfolio_snapshot_3 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 25, :reloans_today => 75, :total_loans_today => 100, :reloan_percentage => 75, :loans_out_today => 15, :total_loans_to_date => 102, :snapshot_on => (Date.today.to_date - 3).strftime('%Y-%m-%d'))
    portfolio_snapshot_4 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 30, :reloans_today => 10, :total_loans_today => 40, :reloan_percentage => 25, :loans_out_today => 17, :total_loans_to_date => 77, :snapshot_on => (Date.today.to_date - 3).strftime('%Y-%m-%d'))
    portfolio_snapshot_5 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 18, :reloans_today => 12, :total_loans_today => 30, :reloan_percentage => 40, :loans_out_today => 25, :total_loans_to_date => 80, :snapshot_on => (Date.today.to_date - 2).strftime('%Y-%m-%d'))
    portfolio_snapshot_6 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 22, :reloans_today => 11, :total_loans_today => 33, :reloan_percentage => 33.33, :loans_out_today => 28, :total_loans_to_date => 65, :snapshot_on => (Date.today.to_date - 2).strftime('%Y-%m-%d'))
    portfolio_snapshot_7 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 40, :reloans_today => 20, :total_loans_today => 60, :reloan_percentage => 33.33, :loans_out_today => 19, :total_loans_to_date => 110, :snapshot_on => (Date.today.to_date - 1).strftime('%Y-%m-%d'))
    portfolio_snapshot_8 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 50, :reloans_today => 10, :total_loans_today => 60, :reloan_percentage => 16.67, :loans_out_today => 12, :total_loans_to_date => 80, :snapshot_on => (Date.today.to_date - 1).strftime('%Y-%m-%d'))
    portfolio_snapshot_9 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 20, :reloans_today => 20, :total_loans_today => 40, :reloan_percentage => 50, :loans_out_today => 10, :total_loans_to_date => 70, :snapshot_on => (Date.today.to_date << 4).strftime('%Y-%m-%d'))
    portfolio_snapshot_10 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 15, :reloans_today => 30, :total_loans_today => 45, :reloan_percentage => 66.67, :loans_out_today => 20, :total_loans_to_date => 85, :snapshot_on => (Date.today.to_date << 4).strftime('%Y-%m-%d'))
    portfolio_snapshot_11 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 25, :reloans_today => 75, :total_loans_today => 100, :reloan_percentage => 75, :loans_out_today => 15, :total_loans_to_date => 102, :snapshot_on => (Date.today.to_date << 3).strftime('%Y-%m-%d'))
    portfolio_snapshot_12 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 30, :reloans_today => 10, :total_loans_today => 40, :reloan_percentage => 25, :loans_out_today => 17, :total_loans_to_date => 77, :snapshot_on => (Date.today.to_date << 3).strftime('%Y-%m-%d'))
    portfolio_snapshot_13 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 18, :reloans_today => 12, :total_loans_today => 30, :reloan_percentage => 40, :loans_out_today => 25, :total_loans_to_date => 80, :snapshot_on => (Date.today.to_date << 2).strftime('%Y-%m-%d'))
    portfolio_snapshot_14 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 22, :reloans_today => 11, :total_loans_today => 33, :reloan_percentage => 33.33, :loans_out_today => 28, :total_loans_to_date => 65, :snapshot_on => (Date.today.to_date << 2).strftime('%Y-%m-%d'))
    portfolio_snapshot_15 = PortfolioSnapshot.create!(:portfolio_id => '1' ,:new_loans_today => 40, :reloans_today => 20, :total_loans_today => 60, :reloan_percentage => 33.33, :loans_out_today => 19, :total_loans_to_date => 110, :snapshot_on => (Date.today.to_date << 1).strftime('%Y-%m-%d'))
    portfolio_snapshot_16 = PortfolioSnapshot.create!(:portfolio_id => '2' ,:new_loans_today => 50, :reloans_today => 10, :total_loans_today => 60, :reloan_percentage => 16.67, :loans_out_today => 12, :total_loans_to_date => 80, :snapshot_on => (Date.today.to_date << 1).strftime('%Y-%m-%d'))

    # Investors
    
    investor = Investor.create!(
        :investor_name => "investor",
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
        :email => "investor@paydayloantracker.com",
        :password => "investor",
        :password_confirmation => "investor")

    investor2 = Investor.create!(
        :investor_name => "investor2",
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
        :email => "investor2@paydayloantracker.com",
        :password => "investor",
        :password_confirmation => "investor")

    investor3 = Investor.create!(
        :investor_name => "investor3",
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
        :email => "investor3@paydayloantracker.com",
        :password => "investor",
        :password_confirmation => "investor")

    investor4 = Investor.create!(
        :investor_name => "investor4",
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
        :email => "investor4@paydayloantracker.com",
        :password => "investor",
        :password_confirmation => "investor")

    # Investments
    
    Investment.create!(:investor_id => investor.id,   :portfolio_id => portfolio_1.id, :amount => 50000.00)
    Investment.create!(:investor_id => investor.id,   :portfolio_id => portfolio_2.id, :amount => 75000.00)
    Investment.create!(:investor_id => investor2.id, :portfolio_id => portfolio_1.id, :amount => 50000.00)
    Investment.create!(:investor_id => investor2.id, :portfolio_id => portfolio_2.id, :amount => 75000.00)
    Investment.create!(:investor_id => investor3.id, :portfolio_id => portfolio_1.id, :amount => 50000.00)
    Investment.create!(:investor_id => investor3.id, :portfolio_id => portfolio_2.id, :amount => 75000.00)
    Investment.create!(:investor_id => investor4.id, :portfolio_id => portfolio_1.id, :amount => 50000.00)
    Investment.create!(:investor_id => investor4.id, :portfolio_id => portfolio_2.id, :amount => 75000.00)
    
    #Lead Providers

    LeadProvider.create!(:name => 'leadprovider', :username => 'leadprovider', :password => 'leadprovider', :lead_filter_id => 1, :status => 0)
    LeadProvider.create!(:name => 'leadprovider1', :username => 'leadprovider1', :password => 'leadprovider', :lead_filter_id => 1, :status => 0)
    LeadProvider.create!(:name => 'leadprovider2', :username => 'leadprovider2', :password => 'leadprovider', :lead_filter_id => 1, :status => 0)
    LeadProvider.create!(:name => 'leadprovider3', :username => 'leadprovider3', :password => 'leadprovider', :lead_filter_id => 1, :status => 0)
    LeadProvider.create!(:name => 'leadprovider4', :username => 'leadprovider4', :password => 'leadprovider', :lead_filter_id => 1, :status => 0)
    LeadProvider.create!(:name => 'leadprovider5', :username => 'leadprovider5', :password => 'leadprovider', :lead_filter_id => 1, :status => 0)
    LeadProvider.create!(:name => 'leadprovider6', :username => 'leadprovider6', :password => 'leadprovider', :lead_filter_id => 1, :status => 0)

    require 'tzinfo'
    us = TZInfo::Country.get('US')
    timezones = us.zone_identifiers
    num_zones = timezones.size

    1000.times do
      state = Common::US_STATES.keys[rand(Common::US_STATES.length)]
      c = Customer.new
      c.lead_provider_id              = 1
      c.portfolio_id                  = [portfolio_1.id,portfolio_2.id][rand(2)]
      c.ip_address                    = "#{rand(155)+10}.#{rand(245)+10}.#{rand(245)+10}.#{rand(245)+10}"
      c.lead_source                   = "internal"
      c.tracker_id                    = rand(1000) + 1
      c.first_name                    = Faker::Name.first_name
      c.last_name                     = Faker::Name.last_name
      c.ssn                           = Faker.numerify("#########").to_s
      c.gender                        = %w(m f)[rand(2)]
      c.email                         = Faker::Internet.email
      c.birth_date                    = Date.parse("#{1940+rand(45)}-#{rand(12)+1}-#{rand(12)+1}")
      c.dl_number                     = Faker.numerify("#########").to_s
      c.dl_state                      = state
      c.military                      = false
      c.home_phone                    = Faker.numerify("##########").to_s
      c.work_phone                    = Faker.numerify("##########").to_s
      c.cell_phone                    = '8018301794' # Bob's cell phone
      c.fax                           = rand(10) == 1 ? Faker.numerify("##########").to_s : ""
      c.address                       = Faker::Address.street_address
      c.city                          = Faker::Address.city
      c.state                         = state
      c.zip                           = Faker.numerify("#####").to_s
      c.country_code                  = 'US'
      c.time_zone                     = timezones[rand(num_zones)]
      c.monthly_income                = rand(3000) + rand(2000) + rand(1000)
      c.income_source                 = %w(EMPLOYMENT BENEFITS)[rand(2)]
      c.pay_frequency                 = %w(TWICE_MONTHLY WEEKLY BI_WEEKLY MONTHLY TWICE_MONTHLY)[rand(5)]
      c.employer_name                 = Faker::Company.name[1,30]
      c.occupation                    = occupation
      c.months_employed               = rand(34) + 2
      c.employer_address              = Faker::Address.street_address
      c.employer_city                 = Faker::Address.city
      c.employer_state                = state
      c.employer_zip                  = Faker.numerify("#####").to_s
      c.employer_phone                = Faker.numerify("##########").to_s
      c.employer_phone_ext            = rand(10) == 1 ? Faker.numerify("####").to_s : ""
      c.employer_fax                  = "8015153028" # Bob's internet fax
      c.supervisor_name               = Faker::Name.name
      c.supervisor_phone              = Faker.numerify("##########").to_s
      c.supervisor_phone_ext          = rand(10) == 1 ? Faker.numerify("####").to_s : ""
      c.residence_type                = %w(RENT OWN)[rand(2)]
      c.monthly_residence_cost        = rand(2500) + 500
      c.months_at_address             = rand(34) + 2
      c.bank_name                     = 'First Community Bank'
      c.bank_account_type             = rand(10) > 3 ? "CHECKING" : "SAVINGS"
      c.bank_aba_number               = Faker.numerify("#########").to_s
      c.bank_account_number           = Faker.numerify("####").to_s
      c.months_at_bank                = rand(34) + 2
      c.bank_direct_deposit           = true
      c.bank_address                  = Faker::Address.street_address
      c.bank_city                     = Faker::Address.city
      c.bank_state                    = state
      c.bank_zip                      = Faker.numerify("#####").to_s
      c.bank_phone                    = Faker.numerify("##########").to_s
      c.next_pay_date_1               = Date.today + (rand(25) + 1).days
      c.next_pay_date_2               = c.next_pay_date_1 + (rand(7) + 7).days
      c.reference_1_relationship      = %w(COWORKER FRIEND OTHER PARENT SIBLING)[rand(5)]
      c.reference_1_name              = Faker::Name.name
      c.reference_1_phone             = Faker.numerify("##########").to_s
      c.reference_1_address           = Faker::Address.street_address
      c.reference_1_city              = Faker::Address.city
      c.reference_1_state             = state
      c.reference_1_zip               = Faker.numerify("#####").to_s
      c.reference_2_relationship      = %w(COWORKER FRIEND OTHER PARENT SIBLING)[rand(5)]
      c.reference_2_name              = Faker::Name.name
      c.reference_2_phone             = Faker.numerify("##########").to_s
      c.reference_2_address           = Faker::Address.street_address
      c.reference_2_city              = Faker::Address.city
      c.reference_2_state             = state
      c.reference_2_zip               = Faker.numerify("#####").to_s
      c.requested_loan_amount         = (rand(3) + 1) * 100
      c.aasm_state                    = %w(not_purchased purchased)[rand(2)]
      if c.aasm_state == "not_purchased"
        c.reject_reason               = ["FactorTrust Score", "Monthly Income", "Unacceptable Bank", "Pay Frequency"][rand(4)]
      end
      c.is_test                       = true
      c.suppress_messages_after_create  = true
      c.credit_limit                  = c.requested_loan_amount + 100
      if c.save
        puts "Created"
        factor_trust = FactorTrust.create(:customer_id => c.id, :response_xml => FactorTrust::ACCEPTED_XML)
        default_loan = c.loans.first
        if [true,false].rand
          
          default_loan.signature_page_arrived_at = Time.now - (rand(60) + 30).minutes
          default_loan.signature_page_accepted_at = default_loan.signature_page_arrived_at + 10.minutes
          default_loan.signature_page_ip_address = c.ip_address
          default_loan.signature_page_accepted_name = "#{c.first_name} #{c.last_name}"
          default_loan.mark_as_underwriting!
        end

#        # Create a credit card
#        credit_card = CreditCard.create!(
#          :card_type => CreditCard::VISA,
#          :last_4_digits => '4242',
#
#          :card_number => 4242424242424242,
#          :expires_month => 7,
#          :expires_year => 2010,
#          :cvv => 900,
#          :first_name => 'John',
#          :last_name => 'Doe',
#          :billing_address => '221B Baker Street',
#          :billing_zip => '90125'
#        )
#        PaymentAccount.create!(:customer_id => c.id, :account_id => credit_card.id, :account_type => CreditCard.to_s)

        
        
#        2.times do
#          loan = Loan.create!(
#            :customer_id => c.id,
#            :underwriter_id => c.underwriter_id,
#            :due_date => Date.today + 14,
#            :initial_amount => 300.00,
#            :initial_apr => 1275.00,
#            :initial_interest => 75.00,
#            :principal_owed => 300.00,
#            :interest_owed => 75.00,
#            :fees_owed => 0.00
#          )
#          for i in 1..3
#            tran_type = [
#                LoanTransaction::PAYMENT,
#                LoanTransaction::EXTENSION,
#                LoanTransaction::NSF_FEE,
#                LoanTransaction::LATE_FEE,
#                LoanTransaction::COLLECTION_FEE,
#                LoanTransaction::GARNISHMENT_FEE
#                ].rand
#            total, principal, interest, fee, new_due_date, payment_method, account_number = nil
#            case tran_type
#            when LoanTransaction::PAYMENT
#              principal = 100
#              interest = 25
#              total = principal + interest
#              payment_method = [LoanTransaction::CHECKING,LoanTransaction::CREDIT_CARD].rand
#              if payment_method == LoanTransaction::CREDIT_CARD
#                account_number = '4204'
#              else
#                account_number = '7502239556'
#              end
#            when LoanTransaction::EXTENSION
#              new_due_date = Date.today + 14
#            when LoanTransaction::NSF_FEE
#              fee = 15.00
#            when LoanTransaction::LATE_FEE
#              fee = 25.00
#            when LoanTransaction::COLLECTION_FEE
#              fee = 35.00
#            when LoanTransaction::GARNISHMENT_FEE
#              fee = 50.00
#            end
#            loan_transaction = LoanTransaction.create!(
#              :loan_id => loan.id,
#              :tran_type => tran_type,
#              :total => total,
#              :principal => principal,
#              :interest => interest,
#              :fee => fee,
#              :new_due_date => new_due_date,
#              :payment_method => payment_method,
#              :account_number => account_number
#            )
#          end
#        end
      else
        puts "."
      end

    end

    # Set some loans to approved, denied, collections and garnishments
    Rake::Task["db:set_demo_loan_states"].execute

    # Force some customers to appear as duplicates with discrepancies
    for id in 1..50
      original_customer   = Customer.find(id)
      duplicate_customer  =  Customer.find(id+200)

      duplicate_customer.employer_phone = original_customer.employer_phone
      duplicate_customer.first_name = original_customer.first_name
      duplicate_customer.last_name = original_customer.last_name
      duplicate_customer.state = original_customer.state
      duplicate_customer.save!
    end

    for id in 1..50
      customer = Customer.find(id)
      CustomerPhoneListing.create!(
        :customer => customer,
        :phone => customer.home_phone,
        :owner => customer.full_name,
        :address => customer.address,
        :city => customer.city,
        :state => Common::US_STATES.keys[rand(Common::US_STATES.length)],
        :zip => customer.zip,
        :line_type => ['landline','cell phone'].rand,
        :provider => ['Qwest','Verizon','AT&T'].rand
      )
      CustomerPhoneListing.create!(
        :customer => customer,
        :phone => customer.cell_phone,
        :owner => customer.full_name,
        :address => customer.address,
        :city => customer.city,
        :state => Common::US_STATES.keys[rand(Common::US_STATES.length)],
        :zip => customer.zip,
        :line_type => ['landline','cell phone'].rand,
        :provider => ['Qwest','Verizon','AT&T'].rand
      )
      CustomerPhoneListing.create!(
        :customer => customer,
        :phone => customer.reference_1_phone,
        :owner => customer.reference_1_name,
        :address => customer.reference_1_address,
        :city => customer.reference_1_city,
        :state => Common::US_STATES.keys[rand(Common::US_STATES.length)],
        :zip => customer.reference_1_zip,
        :line_type => ['landline','cell phone'].rand,
        :provider => ['Qwest','Verizon','AT&T'].rand
      )
      CustomerPhoneListing.create!(
        :customer => customer,
        :phone => customer.reference_2_phone,
        :owner => customer.reference_2_name,
        :address => customer.reference_2_address,
        :city => customer.reference_2_city,
        :state => Common::US_STATES.keys[rand(Common::US_STATES.length)],
        :zip => customer.reference_2_zip,
        :line_type => ['landline','cell phone'].rand,
        :provider => ['Qwest','Verizon','AT&T'].rand
      )
      CustomerPhoneListing.create!(
        :customer => customer,
        :phone => customer.employer_phone,
        :owner => customer.supervisor_name,
        :title => 'Foreman',
        :company => customer.employer_name,
        :address => customer.employer_address,
        :city => customer.employer_city,
        :state => Common::US_STATES.keys[rand(Common::US_STATES.length)],
        :zip => customer.employer_zip,
        :line_type => ['landline','cell phone'].rand,
        :provider => ['Qwest','Verizon','AT&T'].rand
      )
      CustomerPhoneListing.create!(
        :customer => customer,
        :phone => customer.supervisor_phone,
        :owner => customer.supervisor_name,
        :title => 'Foreman',
        :company => customer.employer_name,
        :address => customer.employer_address,
        :city => customer.employer_city,
        :state => Common::US_STATES.keys[rand(Common::US_STATES.length)],
        :zip => customer.employer_zip,
        :line_type => ['landline','cell phone'].rand,
        :provider => ['Qwest','Verizon','AT&T'].rand
      )
    end
    
  end
  
end