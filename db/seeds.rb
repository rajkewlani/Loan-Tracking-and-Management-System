ActiveRecord::Base.connection.execute("truncate table ach_providers")
ActiveRecord::Base.connection.execute("truncate table ach_batches")
ActiveRecord::Base.connection.execute("truncate table ach_transactions")
ActiveRecord::Base.connection.execute("truncate table settings")
ActiveRecord::Base.connection.execute("truncate table locations")
ActiveRecord::Base.connection.execute("truncate table high_risk_bank_branches")
ActiveRecord::Base.connection.execute("truncate table users")
ActiveRecord::Base.connection.execute("truncate table lead_providers")
ActiveRecord::Base.connection.execute("truncate table lead_filters")
ActiveRecord::Base.connection.execute("truncate table portfolios")
ActiveRecord::Base.connection.execute("truncate table countries")
ActiveRecord::Base.connection.execute("truncate table states")
ActiveRecord::Base.connection.execute("truncate table message_categories")
ActiveRecord::Base.connection.execute("truncate table message_templates")

us = Country.create!(
  :name => 'United States',
  :code => 'US'
)

State.create!(
  :country => us,
  :name => 'Utah',
  :code => 'UT',
  :max_loan_days => 70
)

State.create!(
  :country => us,
  :name => 'Pennsylvania',
  :code => 'PA',
  :garnishment_allowed => false
)

State.create!(
  :country => us,
  :name => 'South Carolina',
  :code => 'SC',
  :garnishment_allowed => false
)

State.create!(
  :country => us,
  :name => 'North Carolina',
  :code => 'NC',
  :garnishment_allowed => false
)

State.create!(
  :country => us,
  :name => 'Texas',
  :code => 'TX',
  :garnishment_allowed => false
)

Setting.create!( :apr => 664.84, :max_new_customer_credit_limit => 300, :max_credit_limit => 1500 )

# Locations
Location.create!( :name => 'Springville Office (old)', :ip_address => '67.222.228.30')
Location.create!( :name => 'Springville Office (new)', :ip_address => '63.248.39.48')
Location.create!( :name => 'Development Workstation (localhost)', :ip_address => '127.0.0.1')
Location.create!( :name => "Bob's House", :ip_address => '166.70.26.134')
Location.create!( :name => "India Office", :ip_address => '110.172.27.253')
Location.create!( :name => "Chad's House", :ip_address => '72.8.69.47')
Location.create!( :name => "Blake's House", :ip_address => '63.248.10.14')
Location.create!( :name => "Kirby's House", :ip_address => '66.29.163.178')

# High Risk Bank Branches
HighRiskBankBranch.create!( :name => "alio credit union", :aba_routing_number => "267081927")
HighRiskBankBranch.create!( :name => "Arkansas Federal Credit Union", :aba_routing_number => "282075028")
HighRiskBankBranch.create!( :name => "Bank One", :aba_routing_number => "071900948")
HighRiskBankBranch.create!( :name => "Capital City Bank", :aba_routing_number => "063100688")
HighRiskBankBranch.create!( :name => "Captial One", :aba_routing_number => "065401181")
HighRiskBankBranch.create!( :name => "Centennial", :aba_routing_number => "111102431")
HighRiskBankBranch.create!( :name => "Centennial", :aba_routing_number => "104902114")
HighRiskBankBranch.create!( :name => "CENTENNIAL BANK", :aba_routing_number => "124303065")
HighRiskBankBranch.create!( :name => "Checkspring Bank", :aba_routing_number => "123734755")
#HighRiskBankBranch.create!( :name => "Concordia Bank & Trust", :aba_routing_number => "111102431")
HighRiskBankBranch.create!( :name => "Federal Home Loan Bank", :aba_routing_number => "074001019")
HighRiskBankBranch.create!( :name => "First Consecutive Bank", :aba_routing_number => "083901113")
HighRiskBankBranch.create!( :name => "FIRST PREMIER BANK ", :aba_routing_number => "091408598")
HighRiskBankBranch.create!( :name => "H&R Block", :aba_routing_number => "101089742")
HighRiskBankBranch.create!( :name => "International Bank", :aba_routing_number => "102106844")
HighRiskBankBranch.create!( :name => "JP", :aba_routing_number => "021409169")
HighRiskBankBranch.create!( :name => "meta", :aba_routing_number => "700076770")
HighRiskBankBranch.create!( :name => "Meta", :aba_routing_number => "265476411")
HighRiskBankBranch.create!( :name => "Metabank", :aba_routing_number => "084003997")
HighRiskBankBranch.create!( :name => "Metabank", :aba_routing_number => "273970116")
HighRiskBankBranch.create!( :name => "Metabank", :aba_routing_number => "073972181")
HighRiskBankBranch.create!( :name => "Net Bank", :aba_routing_number => "061091977")
HighRiskBankBranch.create!( :name => "PENTAGON FEDERAL ", :aba_routing_number => "256078446")
HighRiskBankBranch.create!( :name => "Republic Bank", :aba_routing_number => "083001314")
HighRiskBankBranch.create!( :name => "Stillwater National Bank", :aba_routing_number => "103113153")
HighRiskBankBranch.create!( :name => "Tri-Century", :aba_routing_number => "101106942")

# Teams
underwriter_team_1    = Team.create!(:name => 'Underwriters 1', :role => 'underwriter')
underwriter_team_2    = Team.create!(:name => 'Underwriters 2', :role => 'underwriter')
underwriter_inactive  = Team.create!(:name => 'Underwriters - Inactive', :role => 'underwriter')
collections_team_1    = Team.create!(:name => 'Collections Team 1', :role => 'collections')
collections_inactive  = Team.create!(:name => 'Collections - Inactive', :role => 'collections')
garnishments_team_1   = Team.create!(:name => 'Garnishments Team 1', :role => 'garnishments')
garnishments_inactive = Team.create!(:name => 'Garnishments - Inactive', :role => 'garnishments')

User.create!(:username => "robot",
            :email => "robot@paydayloantracker.com",
            :password => "robot",
            :password_confirmation => "robot",
            :role => User::ROBOT,
            :first_name => "Auto-Assign",
            :last_name => "Robot")

# Admins
User.create!(:username => "admin",
            :email => "admin@paydayloantracker.com",
            :password => "NorthPoint99", :password_confirmation => "NorthPoint99",
            :role => User::ADMINISTRATOR,
            :first_name => "Bob",
            :last_name => "Haupt")
User.create!(:username => "bob",
            :email => "bob@np-adv.com",
            :password => "zodiac", :password_confirmation => "zodiac",
            :role => User::ADMINISTRATOR,
            :first_name => "Bob",
            :last_name => "Haupt")

User.create!(:username => "chad",
            :email => "chad@np-adv.com",
            :password => "spedlins", :password_confirmation => "spedlins",
            :role => User::ADMINISTRATOR,
            :first_name => "Chad",
            :last_name => "Jardine")

User.create!(:username => "bcollins",
            :email => "blakecollins35@yahoo.com",
            :password => "a123104", :password_confirmation => "a123104",
            :role => User::ADMINISTRATOR,
            :first_name => "Blake",
            :last_name => "Collins")

User.create!(:username => "stevec",
            :email => "steve@flobridge.com",
            :password => "payday2", :password_confirmation => "payday2",
            :role => User::ADMINISTRATOR,
            :first_name => "Steve",
            :last_name => "Cochran")

User.create!(:username => "natec",
            :email => "nate@flobridge.com",
            :password => "Flo99", :password_confirmation => "Flo99",
            :role => User::ADMINISTRATOR,
            :first_name => "Nathan",
            :last_name => "Cochran")

User.create!(:username => "nathanl",
            :email => "nathan@np-adv.com",
            :password => "FloBridge13", :password_confirmation => "FloBridge13",
            :role => User::ADMINISTRATOR,
            :first_name => "Nathan",
            :last_name => "Lord")

# Underwriters
User.create!(:username => "meganm",
            :email => "megan@flobridge.com",
            :password => "1298meg", :password_confirmation => "1298meg",
            :role => User::UNDERWRITER, :manager => true, :team_id => underwriter_team_1.id,
            :first_name => "Megan",
            :last_name => "McCrary")

User.create!(:username => "emilya",
            :email => "emily@flobridge.com",
            :password => "shoes1", :password_confirmation => "shoes1",
            :role => User::UNDERWRITER, :manager => true, :team_id => underwriter_team_1.id,
            :first_name => "Emily",
            :last_name => "D'Argy")

User.create!(:username => "drewe",
            :email => "drew@flobridge.com",
            :password => "8687", :password_confirmation => "8687",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "Drew",
            :last_name => "Ensslin")

User.create!(:username => "rachelp",
            :email => "rachel@flobridge.com",
            :password => "alfabet3", :password_confirmation => "alfabet3",
            :role => User::UNDERWRITER, :team_id => underwriter_team_2.id,
            :first_name => "Rachel",
            :last_name => "Pickett")

User.create!(:username => "bena",
            :email => "ben@flobridge.com",
            :password => "pilipinas", :password_confirmation => "pilipinas",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "Ben",
            :last_name => "Anstead")

User.create!(:username => "tamaras",
            :email => "tamara@flobridge.com",
            :password => "auntd", :password_confirmation => "auntd",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "Tamara",
            :last_name => "Stone")

User.create!(:username => "diannap",
            :email => "dianna@flobridge.com",
            :password => "area51", :password_confirmation => "area51",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "Dianna",
            :last_name => "Palmer")

User.create!(:username => "luannb",
            :email => "luann@flobridge.com",
            :password => "maddie", :password_confirmation => "maddie",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "LuAnn",
            :last_name => "Brito")

User.create!(:username => "sheau",
            :email => "shea@flobridge.com",
            :password => "paraguay1", :password_confirmation => "paraguay1",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "Shea",
            :last_name => "Ulibarri")

User.create!(:username => "saray",
            :email => "sara@flobridge.com",
            :password => "young", :password_confirmation => "young",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "Sara",
            :last_name => "Young")

User.create!(:username => "manuell",
            :email => "manuell@flobridge.com",
            :password => "cuarger1", :password_confirmation => "cuarger1",
            :role => User::UNDERWRITER, :team_id => underwriter_team_1.id,
            :first_name => "Manuel",
            :last_name => "Lopez")

User.create!(:username => "matt",
            :email => "matt@flobridge.com",
            :password => "payday", :password_confirmation => "payday",
            :role => User::UNDERWRITER, :manager => true, :team_id => underwriter_team_2.id,
            :first_name => "Matt",
            :last_name => "Webster")

User.create!(:username => "troy",
            :email => "troy@flobridge.com",
            :password => "payday", :password_confirmation => "payday",
            :role => User::UNDERWRITER, :team_id => underwriter_team_2.id,
            :first_name => "Troy",
            :last_name => "Jensen")

User.create!(:username => "macaelap",
            :email => "macaela@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Macaela",
            :last_name => "Pacher")

User.create!(:username => "raym",
            :email => "ray@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Ray",
            :last_name => "McCumber")

User.create!(:username => "leeh",
            :email => "lee@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Lee",
            :last_name => "Hale-Pratt")

User.create!(:username => "natalies",
            :email => "natalie@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Natalie",
            :last_name => "Scott")

User.create!(:username => "aracelyh",
            :email => "aracely@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Aracely",
            :last_name => "Hallam")

User.create!(:username => "andret",
            :email => "andre@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Andre",
            :last_name => "Trochez")

User.create!(:username => "alfredog",
            :email => "alfredo@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Alfredo",
            :last_name => "Garcia")

User.create!(:username => "rayneev",
            :email => "raynee@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :role => User::UNDERWRITER, :team_id => underwriter_inactive.id,
            :first_name => "Raynee",
            :last_name => "Valdivia")


# Collections Agents
User.create!(:username => "kario",
            :email => "kari@flobridge.com",
            :password => "kari0415", :password_confirmation => "kari0415",
            :role => User::COLLECTIONS, :manager => true, :team_id => collections_team_1.id,
            :first_name => "Kari",
            :last_name => "Odum")

User.create!(:username => "annaf",
            :email => "anna@flobridge.com",
            :password => "aileen", :password_confirmation => "aileen",
            :role => User::COLLECTIONS, :team_id => collections_team_1.id,
            :first_name => "Anna",
            :last_name => "Fernandini")

User.create!(:username => "julianam",
            :email => "juliana@flobridge.com",
            :password => "payday", :password_confirmation => "payday",
            :role => User::COLLECTIONS, :team_id => collections_team_1.id,
            :first_name => "Juliana",
            :last_name => "Magana")

User.create!(:username => "maliaf",
            :email => "malia@flobridge.com",
            :password => "tejay", :password_confirmation => "tejay",
            :role => User::COLLECTIONS, :team_id => collections_team_1.id,
            :first_name => "Malia",
            :last_name => "Finau")

User.create!(:username => "johnnye",
            :email => "johnny@flobridge.com",
            :password => "azareya", :password_confirmation => "azareya",
            :role => User::COLLECTIONS, :team_id => collections_team_1.id,
            :first_name => "Johnny",
            :last_name => "Elias")

User.create!(:username => "starlee",
            :email => "starlee@flobridge.com",
            :password => "star", :password_confirmation => "star",
            :role => User::COLLECTIONS, :team_id => collections_team_1.id,
            :first_name => "Starlee",
            :last_name => "Hopkin")

User.create!(:username => "kellio",
            :email => "kelli@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Kelli",
            :last_name => "Ottesen")

User.create!(:username => "delilahj",
            :email => "delilah@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Delilah",
            :last_name => "Jerman")

User.create!(:username => "jeremyc",
            :email => "jeremy@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Jeremy",
            :last_name => "Conterio")

User.create!(:username => "sofiao",
            :email => "sofia@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Sofia",
            :last_name => "Opmanis")

User.create!(:username => "sidneys",
            :email => "sidney@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Sidney",
            :last_name => "Sanford")

User.create!(:username => "samanthas",
            :email => "samantha@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Samantha",
            :last_name => "Simms")

User.create!(:username => "britainb",
            :email => "britain@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Britain",
            :last_name => "Baker")

User.create!(:username => "coryj",
            :email => "cory@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Cory",
            :last_name => "Junck")

User.create!(:username => "adams",
            :email => "adam@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Adam",
            :last_name => "Schriefer")

User.create!(:username => "nathans",
            :email => "nathans@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Nathan",
            :last_name => "Steele")

User.create!(:username => "randyh",
            :email => "randy@flobridge.com",
            :password => "inactive", :password_confirmation => "inactive",
            :login_suspended => true,
            :role => User::COLLECTIONS, :team_id => collections_inactive.id,
            :first_name => "Randy",
            :last_name => "Hallam")

# Garnishment Agents
User.create!(:username => "kamid",
            :email => "kami@flobridge.com",
            :password => "betty0415", :password_confirmation => "betty0415",
            :role => User::GARNISHMENTS, :manager => true, :team_id => garnishments_team_1.id,
            :first_name => "Kami",
            :last_name => "Dickson")

User.create!(:username => "yeshiae",
            :email => "yeshia@flobridge.com",
            :password => "chasteise", :password_confirmation => "chasteise",
            :role => User::GARNISHMENTS, :team_id => garnishments_team_1.id,
            :first_name => "Yeshia",
            :last_name => "Edwards")

User.create!(:username => "taunih",
            :email => "tauni@flobridge.com",
            :password => "hard", :password_confirmation => "hard",
            :role => User::GARNISHMENTS, :team_id => garnishments_team_1.id,
            :first_name => "Tauni",
            :last_name => "Hardman")

User.create!(:username => "marief",
            :email => "marie@flobridge.com",
            :password => "baxter", :password_confirmation => "baxter",
            :role => User::GARNISHMENTS, :team_id => garnishments_team_1.id,
            :first_name => "Marie",
            :last_name => "Fuell")


locations = Location.find(:all)
users = User.find(:all)
users.each do |user|
  user.locations = locations
end

# Create Lead Filters
LeadFilter.create!(:name => "Default",
            :minimum_months_at_job => 3,
            :minimum_months_at_bank => 2,
            :minimum_age => 21,
            :allow_pay_frequency_weekly => true,
            :allow_pay_frequency_biweekly => true,
            :allow_pay_frequency_monthly => false,
            :allow_pay_frequency_twice_per_month => true,
            :allow_payroll_type_cash => false,
            :allow_payroll_type_check => false,
            :allow_payroll_type_direct_deposit => true,
            :allow_payroll_type_benefits => false,
            :minimum_factor_trust_score => 650)
            
LeadProvider.create!(:name => "Test",
            :username => "test",
            :password => "test",
            :lead_filter_id => LeadFilter.first.id)
                    

# Portfolios
portfolio_1 = Portfolio.create!(
  :name => 'FBG',
  :apr => 664.84,
  :max_loan_amount => 500,
  :min_loan_days => 4,
  :max_loan_days => 84,
  :max_extensions => 52,
  :max_loans_per_year => 52
)
portfolio_2 = Portfolio.create!(
  :name => 'FBML',
  :apr => 664.84,
  :max_loan_amount => 500,
  :min_loan_days => 4,
  :max_loan_days => 84,
  :max_extensions => 52,
  :max_loans_per_year => 52
)
portfolio_3 = Portfolio.create!(
  :name => 'FBML II',
  :apr => 664.84,
  :max_loan_amount => 500,
  :min_loan_days => 4,
  :max_loan_days => 84,
  :max_extensions => 52,
  :max_loans_per_year => 52
)
portfolio_4 = Portfolio.create!(
  :name => 'FBML III',
  :apr => 664.84,
  :max_loan_amount => 500,
  :min_loan_days => 4,
  :max_loan_days => 84,
  :max_extensions => 52,
  :max_loans_per_year => 52
)

# ACH

AchProvider.create(
  :name => 'Advantage ACH',
  :login_id => ADVANTAGE_ACH_CONFIG[:login_id],
  :processing_email => 'processing@advantageach.com',
  :support_email => 'support@advantageach.com',
  :support_phone => '(888) 891-8612',
  :primary_contact_name => 'Bob Haupt',
  :primary_contact_phone => '(801) 830-1794',
  :primary_contact_email => 'bob@np-adv.com',
  :alternate_contact_name => 'Chad Jardine',
  :alternate_contact_phone => '(801) 362-7654',
  :alternate_contact_email => 'chad@np-adv.com'
)

loans_category = MessageCategory.create(
  :name => "Loans",
  :footer => "Loans Footer"
)
collections_category = MessageCategory.create(
  :name => "Collections",
  :footer => "Collections Footer"
)
marketing_category = MessageCategory.create(
  :name => "Marketing",
  :footer => "To unsubscribe from messages like this, <a href=\"#{WebServer.domain}/customers/opt_out_of_marketing_emails/[customer_id]\">click here.</a>"
)

MessageTemplate.create!(
              :name => "Pending Text",
              :enabled => false,
              :subject => "Additional Information Needed",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],
                        FloBridge has received your loan application and are currently processing it. If you have any questions call 1-866-569-3321.
                        FlBridge",

              :msg_event => Loan::PENDING_SIGNATURE,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :send_hour => 14,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Application Received [AUTO]",
              :enabled => true,
              :subject => "[first_name] [last_name], your loan application has been received",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Dear <strong>[first_name]</strong>,

                        <p>Welcome to Flobridge. We have received your loan application, thank you. You will be contacted shortly by one of our experienced Customer Service Representatives to confirm the information on your application and complete the approval process. We are a direct lender so in most cases, once your loan is approved, funds are deposited in your account by the next business day.</p>
                        <p>If you have any questions, we are available Mon-Fri from 7:30 am to 6:30 pm MST at (866) 569-3321 (Option #1), or use the contact form on our website at flobridge.com.</p>

                        <p>Thank you,</p>
                        Flobridge Customer Service
                        <br/>contact@flobridge.com

                        <p>Toll Free: (866) 569-3321 (Option #1)</p>",

              :msg_event => Loan::PENDING_SIGNATURE,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :send_hour => 14,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "E-sign Please",
              :enabled => true,
              :sms_body => "[first_name], Your loan is ready to finalize, however, we need you to e-sign your loan docs. Call 1-866-569-3321 and Option #1.",
              :subject => "[first_name], E-sign Please",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name] [last_name]</strong>,</p>

                        <p>We have your information and we are ready to finalize your loan.  Here's what you still need to do to complete the process.</p>
                        <p>1. Login to the <u>Member Area</u> at <u>www.Flobridge.com</u>.  Enter your username and password. ( if you can't remember, just call us at  <strong>866 569 3321</strong>)</p>
                        <p>2. Click on the Loan Agreement, Go to the bottom of the form and <strong>e-sign</strong>.</p>
                        <p>When approved before 4:00pm, <strong>the money will be in your bank account by the next business day</strong>.</p>

                        <p>Call us at 866 569 3321, Option #1 from 7:30am until 5:30pm MST if you have any questions.</p>

                        <p>Sincerely,</p>

                        Customer Service Team
                        <br/>Flobridge Cash 'Til Payday
                        <br/><strong>866-569-3321</strong>
                        <br/><u>www.Flobridge.com</u>

                        <p>PS the quicker you sign this the quicker</p>",

              :send_schedule_flag => MessageTemplate::POINT_IN_TIME,
              :required_aasm_state => 'pending_signature',
              :base_date => Loan::CREATED_ON,
              :days => 0,
              :before_after => 'after',
              :send_hour => 14,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "Employment Verification  ",
              :enabled => true,
              :subject => "Employment Verification ",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],
              FloBridge needs some additional employment information to process your loan.  Please call 1-866-569-3321 and Option #1.

              FloBridge ",

              :msg_event => Loan::NEED_EMPLOYMENT_INFO,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "FRAUD ALERT",
              :enabled => true,
              :subject => "FRAUD ALERT",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<strong>[first_name] [last_name]</strong>,
              <p>It has come to our attention that unscrupulous individuals and/or organizations, claiming to be FloBridge or Cash-N-Dash, are attempting to defraud you into disclosing your personal and financial information in an attempt to steal your money and/or your identity.</p>
              <p>Please know that FloBridge has taken every precaution to safegaurd this information.</p>
              <p>All calls and correspondence from FloBridge will come from phone numbers 801-701-9900, 866-569-3321, fax numbers 801-515-8081, 801-692-6690, and emails like contact@flobridge.com.</p>
              <p>If you receive threatening/malicious calls or emails, be assured that they are not from FloBridge. DO NOT DISCLOSE anything! Write down the number and report it to your local police agency.</p>
              <p>If you are unsure if the call is from FloBridge, hang up and call FloBridge directly at 866-569-3321.</p>
              <p>Regards,</p>
              FloBridge Group LLC",

              :msg_event => Loan::FRAUD_ALERT,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :message_category_id => loans_category.id
              )



MessageTemplate.create!(
              :name => "Loan Approved [AUTO]",
              :enabled => true,
              :subject => "[first_name], your loan has been approved!",
              :content_type => MessageTemplate::TEXT_HTML,
              :sms_body => "Congratulations [first_name]!  Your Flobridge loan has been approved.  Funds should arrive in your account on the next business day.",
              :email_body => "<strong>[first_name]</strong>,
              <p>Congratulations! Your loan in the amount of [loan_amount] has been approved. Loans approved before 6pm MST are typically funded the next business day depending on how your bank processes electronic transactions. We are scheduled to debit your payment of <strong>[loan_amount]</strong>, on <strong>[due_date]</strong>. If you have requested an extension, your account will be drafted for [interest_owed], which will extend your loan to your next payday.  If you wish to extend your loan, we need to receive your request <strong>at least 2 days prior to your due date</strong> by calling our toll-free number <strong>1 (866) 569-3321</strong>.</p>
              <p>You may pay in full or make a partial payment toward the principal so long as you complete the arrangements <strong>at least two days</strong> prior to your due date to allow time for accurate processing.</p>
              <p>Please be aware that you have the right to rescind this loan per the terms of your contract within 24 hours.  Should you decide to cancel this loan, please sign the rescind statement at the bottom of your agreement and fax it back to us at (801) 515-8081 by 5pm MST tomorrow.  If the loan has already been credited to your account, we will simply debit the prinicpal balance issued from your account and you will not be charged any interest.</p>
              <p>This is a short term loan and the terms are designed as such.  We ask that you borrow responsibly and make every possible effort to pay this loan down in advance if possible.  Payments of $50 towards principal are acceptable at any time.  All loans must be <strong>paid off within 12 weeks</strong>.</p>
              <p>If you have any questions, please do not hesitate to contact us.</p>
              <p>Thank you for your business.</p>

              Flobridge Customer Service
              <br/>contact@flobridge.com

              <strong>Toll Free: (866) 569-3321</strong>
              ",
             
              :msg_event => Loan::APPROVED,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :message_category_id => loans_category.id
              )



MessageTemplate.create!(
              :name => "Loan Denied (App Suspended) [AUTO]",
              :enabled => true,
              :subject => "Loan request suspended",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear [first_name]</p>,

              <p>Thank you for applying for a loan with Flobridge.  Unfortunately we are unable to proceed with the processing of your loan request at this time.  Our records indicate that your application has a status of [reject_reason].  If this indicates that we were unable to obtain the necessary information from you to complete your application, you may still qualify for the loan if you can provide the missing information. Please feel free to contact us with any questions or concerns you may have.</p>
              <pSincerely,</p>

              <br/>Flobridge Customer Service
              <br/>contact@flobridge.com

              <strong>Toll Free: (866) 569-3321 (Option #1)</strong>
              ",
             
              :msg_event => Loan::DENIED,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "Missed Payment plan Letter",
              :enabled => true,
              :subject => "[first_name] [last_name], Your Payment Plan is being cancelled",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Dear <strong>[first_name] [last_name]</strong>,
              <p>We recently established a payment plan with you to help you repay your Flobridge payday loan.  We also had stopped additional interest and fees from continuing.</p>
              <p>We are now cancelling your payment plan because when we attempted to draw your payment, it failed.</p>
              <p>We are now forced to reinstate the loan balance, fees and penalties.  And take the next step to collect what is owed by contacting your employer to garnish wages to repay the principle and fees you currently owe.</p>
              <p>You must contact us immediately to stop further action.  If you do not contact us by, tomorrow, [currentdate+1], we will begin the garnishment process with your employer.</p>
              <p>Our hope is that we can work with you to immediately resolve this issue.  Please call 866-569-3321 (Option #2).</p>

              <p>Sincerely,</p>

              <br/>Customer Servicer Team
              <br/>Flobridge Cash 'Til Payday
              <br/><strong>866-569-3321</strong>
              <br/><u>www.Flobridge.com</u>


              <p>This communication is an attempt to collect a debt and any information obtained will be used for that purpose.</p> ",
             
              :msg_event => Loan::PAYMENT_PLAN_CANCELLED,
              :send_schedule_flag => MessageTemplate::TRIGGER_EVENT,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Paid in Full",
              :enabled => true,
              :subject => "Your loan is paid off, thank you.",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Dear <strong>[first_name]</strong>,
              <p>Our records indicate that final payment on your loan has been received and that your account is paid in full. Should you need another loan from us, please visit the MEMBER AREA of our website, where you can apply for a new loan.</p>
              <p>Please click on the link and take a moment to tell us about your experience by taking a short Survey .</p>
              <p>Thank you for your business.</p>
              <p></p>
              Flobridge Customer Service
              <br/>contact@flobridge.com

              <strong>Toll Free: (866) 569-3321 (Option #1)</strong>",
             
              :msg_event => Loan::PAID_IN_FULL,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Payment Date Letter",
              :enabled => true,
              :subject => "Flobridge Loan Payment",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong>,
              <p>Thank you for using Flobridge for your short-term lending needs. A payment has been submitted to draft from your acount today in accordance with your loan agreement.</p>
              <p>Over the next few days your bank will notify us that your payment went through and your account will continue to be in good standing. We appreciate your business. If this is your final payment, thank you. We hope to serve you again in the future.</p>
              <p>If, for any reason your account was unable to cover the payment amount, your bank will notify us over the next few days, placing your account in default. Default can be avoided if you contact us immediately at 1 (866) 569-3321 to make payment arrangements.</p>
              <p>Best regards,</p>
              <p></p>
              Flobridge Customer Service
              <br/>contact@flobridge.com

              <strong>Toll Free: (866) 569-3321 (Option #2)</strong>
               ",
             
              :msg_event => Loan::SCHEDULED_PAYMENT_SUBMITTED,
              :send_schedule_flag => MessageTemplate::TRIGGER_EVENT,
              :message_category_id => loans_category.id
              )



MessageTemplate.create!(
              :name => "Payment Due Reminder",
              :enabled => true,
              :subject => "Payment scheduled for [due_date]",
              :sms_body => "A loan payoff is scheduled to come from your acct on [due_date]. To extend and pay only [interest_at_due_date], call (866) 569-3321 (Option #2).FloBridge",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Dear <strong>[first_name]</strong>,
              <p>This is a reminder that on [due_date] we are scheduled to debit your account for the loan principal of <strong>[principal_owed]</strong> and interest of <strong>[total_interest_at_due_date]</strong>.</p>
              <p>If you have already been granted an extension, your account will be drafted only for <strong>[total_interest_at_due_date]</strong>, which will extend your loan payoff until your next payday.  If you have not requested an extension, but would like to, we need to receive your request at least 2 days prior to your due date by calling our toll-free number <strong>1 (866) 569-3321.</strong></p>
              <p>Also, Please remember that this loan must be paid in full within 12 weeks of the original date of [funded_on]. The maximum number of extensions is FIVE. We typically allow up to three extensions that require payment of the interest due and a fourth or fifth extension requires the interest due, plus a principal payment of at least 1/3 of the principal owed.  You may contact us to make additional principal payments at any time. Thank you for your business.</p>

              <p>Regards,</p>

              Flobridge Customer Service
              <br/>contact@flobridge.com

              <strong>Toll Free: (866) 569-3321 (Option #2)</strong>",
             
              :send_schedule_flag => MessageTemplate::POINT_IN_TIME,
              :base_date => Loan::DUE_DATE,
              :before_after => 'before',
              :days => 5,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Pending Want to Finalize",
              :enabled => true,
              :subject => "[first_name], We are waiting on you ... so we can send you our money",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Dear <strong>[first_name]</strong>,
              <p>Your loan approval is almost complete ... but we need your help!</p>
              <p>We are ready to put money into your account, but we need you to call and verify over the phone.</p>
              <p>As soon as we hear from you, we will then put the money in to your checking account by tomorrow morning.</p>
              <p><strong>Can you help us complete your loan? Please call as soon as possible at 866-569-3321 (Option #1)</strong></p>
              <p>Thanks You,</p>

              <br/>Flobridge Customer Service Team
              <br/>contact@flobridge.com

              <p><strong>Toll Free: (866) 569-3321 (Option #1)</strong></p>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Phone Connection Issues",
              :enabled => true,
              :subject => "Phone Connection Issues",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Dear <strong>[first_name]</strong>,
              <p>We here at Flobridge value your business and time, however at this time we are having some technical issues with our phone system and are in the process of updating our software. We are working our hardest to get this resolved as soon as possible, until  further notice please contact us via email and we will have a customer service representative contact you tomorrow.</p>
              <p>thanks,</p>

              <p>Flobridge</p>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :collections => true,
              :garnishments => true,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Phone Connection Issues",
              :enabled => true,
              :subject => "Phone Connection Issues",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Flobridge is having some technical problems with their phones right now, please contact us via Email at contact@flobridge.com",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :collections => true,
              :garnishments => true,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Processing Your Loan",
              :enabled => true,
              :subject => "Pending Status",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<strong>[first_name]</strong>,
              <p>We have received your loan application and we are currently in the process of reviewing the information.  You should hear from one of our customer service representatives shortly regarding the application and the approval of your loan.</p>
              <p>If you have any questions or would like to find out further details of your loan status, please contact us 1-866-569-3321 (Option #1).</p>
              <p>Thank you,</p>
              <br/>FloBridge Customer Service Team
              <br/>Contact@flobridge.com",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Processing Your Loan",
              :enabled => true,
              :subject => "Pending Status",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],
              FloBridge has received your loan application and we are currently verifing the information. For status of loan call 1-866-569-3321 (Option #1).",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :message_category_id => loans_category.id
              )


MessageTemplate.create!(
              :name => "Ready To Give You Money  ",
              :enabled => true,
              :subject => "Finalize Text",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],
              FloBridge is ready to finalize your loan and submit the money into your account, please call 1-866-569-3321 (Option #1)to complete your loan.",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "Verification Required",
              :enabled => true,
              :subject => "Loan Approved Pending Employment Verification",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Dear [first_name],
              <p>Your loan approval is almost complete!</p>
              <p>However, we noticed that the employment information on your application is either incomplete or we have not been able to verify it.  Before we can send the money into your bank account, we need a full application including verified employment information.</p>
              <p>Can you help us complete your loan? Please contact us at 1 (866) 569-3321 (Option #1) so we can finalize your approval. Once approved, cash is usually available in your bank account the next business day.

              <p>Thank you.</p>

              <br/>Flobridge Customer Service
              <br/>contact@flobridge.com

              <p><strong>Toll Free: (866) 569-3321 (Option #1)</strong></p>
               ",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "Work Phone Verification",
              :enabled => true,
              :subject => "Work Phone Verification",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],
              You are approved.  However, we need to verify employment, please provide us with a valid work number. Call now 1-866-569-3321 (Option #1).  ",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "Work Phone Verification",
              :enabled => true,
              :subject => "Work Phone Verification",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<strong>[first_name]</strong>,
              <p>You are approved for your loan.  However, on your application you sumitted a bad number as your work number.  We aren't able to accept a cell phones or home phone number as your work phone.</p>
              <p>We want to give you the loan so please help us by giving us a verifiable landline number for your work.  As soon as this is done we can proceed with your loan.</p>
              <p>Regards,</p>
              <br/>FloBridge Group Customer Service
              1-866-569-3321 (Optoion #1)
              <u>contact@flobridge.com</u>
              ",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :underwriting => true,
              :message_category_id => loans_category.id
              )

MessageTemplate.create!(
              :name => "Immediate Attention Required",
              :enabled => true,
              :subject => "Immediate Attention Required",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Unless we hear from you today your account will be submitted to your employer for wage garnishment. FloBridge (866) 569-3321 (Option #2)    ",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :garnishments => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Contacting References",
              :enabled => true,
              :subject => "Unable to reach you. Contacting your references.",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear [first_name],</p>
              <p>We have been unable to contact you regarding the past due status of your loan. We will be reaching out to the references listed on your application as well as to neigbors living near your mailing address in order to locate you. We just need to communicate with you in order to schedule a payment.&nbsp;</p>
              <p>Our account representatives are standing by from 7:30 am to 6:30 pm MST. We will work with you to bring your account current, but that requires communication from you.&nbsp; Please contact our office at <strong>866-569-3321</strong> (Option #2) as soon as possible to make arrangements for payment.</p>
              <p>Sincerely,</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: 12pt;'>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )


MessageTemplate.create!(
              :name => "Contacting References",
              :enabled => true,
              :subject => "Contacting References",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "We haven’t heard from you regarding your past due loan.
              A $20 NSF fee has been charged and we’ll be contacting
              your references. FloBridge (866) 569-3321",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )



MessageTemplate.create!(
              :name => "Court Docs.",
              :enabled => true,
              :subject => "Court Docs.",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>&nbsp;</p>
              <div style='margin: 0in 0in 0pt;'>Dear <strong>[first_name]&nbsp;[last_name]</strong>,<strong>&nbsp;</strong></div>
              <div style='margin: 0in 0in 0pt;'><strong>
              <p>Should you choose to ignore us the following&nbsp;paperwork will be submitted to the court and we will get a Court Order to garnish wages.&nbsp;</p>
              <p>Call NOW.&nbsp; 1-866-569-3321 (Option 2)</p>
              <p>FloBridge&nbsp;Customer Support&nbsp;&nbsp;</p>
              &nbsp;</strong>&nbsp;</div>
              <div style='margin: 0in 0in 0pt;'>
              <div style='margin: 0in 0in 0pt;'><font size='2'>The Defendant took out a loan with FloBridge Group LLC. and has failed to make payments or create payment Arrangements.&nbsp;The defendant has signed a contractual agreement stating the terms and conditions of the loan.&nbsp;We have made several attempts to contact the defendant by mail, email and phone.&nbsp;The Defendant has ignored all opportunities to resolve this matter and has left us no other alternatives but to use court intervention.&nbsp;&nbsp; </font></div>
              <p>&nbsp;</p>
              </div>
              <p>
              <table width='637' cellspacing='0' cellpadding='0' border='0' style='width: 477.9pt; border-collapse: collapse;'>
                  <tbody>
                      <tr>
                          <td width='637' valign='top' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 477.9pt;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>I am the<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b><u>X </u></b>Plaintiff</span></font></div>
                          <div style='margin: 0in 0in 0pt;'><font size='2'><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span>&nbsp;Attorney for the Plaintiff and my Utah Bar number is _______</font></div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div style='margin: 6pt 0in 0pt;'>&nbsp;</div>
              <p>
              <table cellspacing='0' cellpadding='0' border='1' style='border: medium none; border-collapse: collapse;'>
                  <tbody>
                      <tr>
                          <td width='638' valign='top' colspan='2' style='border-width: 1pt medium; border-style: solid none; border-color: black rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 6.65in;'>
                          <div align='center' style='margin: 12pt 0in 0pt;'><font size='2'>In the <b><u>4<sup>th</sup> </u></b>&nbsp;District <span>&nbsp;&nbsp;</span>&nbsp;Justice Court of Utah</font></div>
                          <div align='center' style='margin: 12pt 0in 0pt;'><font size='2'>___Fourth _______ Judicial District ________Utah ________ County</font></div>
                          <div align='center' style='margin: 6pt 0in 0pt;'><font size='2'>Court Address __75 East 80 North American Fork, Utah 84003</font></div>
                          </td>
                      </tr>
                      <tr>
                          <td width='319' valign='top' style='border-width: medium 1pt 1pt medium; border-style: none solid solid none; border-color: rgb(240, 240, 240) black black rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 239.4pt;'>
                          <div style='margin: 12pt 0in 0pt;'><u><font size='2'>FloBridge Group LLC. </font></u></div>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>Plaintiff</font></div>
                          <div style='margin: 12pt 0in 0pt;'><font size='2'>v.</font></div>
                          <div style='margin: 12pt 0in 0pt;'><font size='2'><strong>[first_name] [last_name]</strong><br />
                           ____________________________________</font></div>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>Defendant</font></div>
                          <div style='margin: 12pt 0in 0pt;'><font size='2'>And</font></div>
                          <div style='margin: 6pt 0in 0pt;'><font size='2'>_____________________________________</font></div>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>Defendant</font></div>
                          </td>
                          <td width='319' valign='top' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) black; padding: 0in 5.4pt; background-color: transparent; width: 239.4pt;'>
                          <div style='margin: 12pt 0in 0pt;'><b><font size='2'>Affidavit and Summons</font></b></div>
                          <div style='margin: 12pt 0in 0pt;'><font size='2'>Case Number ___________________</font></div>
                          <div style='margin: 12pt 0in 0pt;'><font size='2'>Judge&nbsp;_________________________</font></div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div style='margin: 12pt 0in 0pt;'><font size='2'>I swear that the following is true.</font></div>
              <p>
              <table width='691' cellspacing='0' cellpadding='0' border='0' style='width: 7.2in; border-collapse: collapse;'>
                  <tbody>
                      <tr style='height: 0.3in;'>
                          <td width='247' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 185.4pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>(1) Defendant owes me</font></div>
                          </td>
                          <td width='144' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 1.5in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>$ <strong>[payoff_amount]</strong>,</font></div>
                          </td>
                          <td width='300' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 225pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>for the claim described in paragraph (2).</font></div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='247' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 185.4pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>plus the filing fee of</font></div>
                          </td>
                          <td width='144' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 1.5in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>$ 60.00</font></div>
                          </td>
                          <td width='300' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 225pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='247' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 185.4pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>plus an estimated service fee of</font></div>
                          </td>
                          <td width='144' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 1.5in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>$ 40.00</font></div>
                          </td>
                          <td width='300' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 225pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='247' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 185.4pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>for a total of:</font></div>
                          </td>
                          <td width='144' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 1.5in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>$ <strong>[payoff_amount]</strong>,</font></div>
                          </td>
                          <td width='300' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 225pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div style='margin: 12pt 0in 0pt;'><font size='2'>plus prejudgment, if qualified for prejudgment interest.</font></div>
              <div style='text-indent: -0.5in; margin: 12pt 0in 12pt 0.5in;'><font size='2'>(2)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; The events happened on / in the year 2009 / 2010.&nbsp;My claim is based on the following facts.</font></div>
              <p>
              <table cellspacing='0' cellpadding='0' border='0' style='border-collapse: collapse;'>
                  <tbody>
                      <tr style='height: 0.3in;'>
                          <td width='638' valign='top' style='border-width: 1pt medium; border-style: solid none; border-color: windowtext rgb(240, 240, 240) black; padding: 0in 5.4pt; background-color: transparent; width: 6.65in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>The Defendant took out a loan with FloBridge Group LLC. and has failed to make payments or create payment&nbsp;</font></div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='638' valign='top' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) black; padding: 0in 5.4pt; background-color: transparent; width: 6.65in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>Arrangements.&nbsp;The defendant has signed a contractual agreement stating the terms and conditions of the loan. &nbsp;We&nbsp;&nbsp; </font></div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='638' valign='top' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) black; padding: 0in 5.4pt; background-color: transparent; width: 6.65in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>Have made several attempts to contact the defendant by mail, email and phone.&nbsp;The Defendant has ignored all &nbsp;&nbsp;&nbsp;</font></div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='638' valign='top' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) black; padding: 0in 5.4pt; background-color: transparent; width: 6.65in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>opportunities to resolve this matter and has left us no other alternatives but to use court intervention.&nbsp;&nbsp; </font></div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='638' valign='top' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) black; padding: 0in 5.4pt; background-color: transparent; width: 6.65in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>&nbsp;</font></div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div style='text-indent: -0.5in; margin: 12pt 0in 0pt 0.5in;'><font size='2'>(3)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Defendant resides within the jurisdiction of the court.</font></div>
              <div style='text-indent: -0.5in; margin: 0in 0in 12pt 1in;'><font size='2'><b><u>X</u></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; The events happened within the jurisdiction of the court.</font></div>
              <div style='text-indent: -0.5in; margin: 12pt 0in 12pt 0.5in;'><font size='2'>(4)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b><u>X</u></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; I am not suing a government entity. I am not suing a government employee for the employee&rsquo;s on-the-job conduct.</font></div>
              <div style='text-indent: -0.5in; margin: 12pt 0in 12pt 0.5in;'><font size='2'>(5)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b><u>X</u></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; I am not suing on a claim that has been assigned to me.</font></div>
              <div style='text-indent: -0.5in; margin: 12pt 0in 12pt 0.5in;'>&nbsp;</div>
              <div style='text-indent: -0.5in; margin: 12pt 0in 12pt 0.5in;'>&nbsp;</div>
              <p>
              <table width='635' cellspacing='0' cellpadding='0' border='1' style='border: medium none; margin: auto auto auto -0.3pt; width: 476.2pt; border-collapse: collapse;'>
                  <tbody>
                      <tr>
                          <td style='border: medium none rgb(240, 240, 240); padding: 0in; background-color: transparent;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>&nbsp;</font></div>
                          </td>
                          <td width='635' valign='top' colspan='4' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 475.9pt;'>
                          <div style='text-indent: -0.5in; margin: 6pt 0in 0pt 0.5in;'><font size='2'>I have not included any non-public information in this document.</font></div>
                          </td>
                      </tr>
                      <tr style='page-break-inside: avoid; height: 0.3in;'>
                          <td width='56' valign='bottom' colspan='2' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 41.7pt; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Date:</font></div>
                          </td>
                          <td width='167' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 125.4pt; height: 0.3in;'>
                          <div style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>April 29, 2010</font></div>
                          </td>
                          <td width='142' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 106.5pt; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Sign here ?</font></div>
                          </td>
                          <td width='270' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 202.35pt; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                      <tr style='page-break-inside: avoid; height: 0.3in;'>
                          <td width='365' valign='bottom' colspan='4' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 3.8in; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Printed Name of Plaintiff or Plaintiff&rsquo;s Agent</font></div>
                          </td>
                          <td width='270' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 202.35pt; height: 0.3in;'>
                          <div style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Blake Collins</font></div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div style='margin: 6pt 0in 0pt;'>&nbsp;</div>
              <p>
              <table width='635' cellspacing='0' cellpadding='0' border='1' style='border: medium none; margin: auto auto auto -0.3pt; width: 475.95pt; border-collapse: collapse;'>
                  <tbody>
                      <tr style='page-break-inside: avoid; height: 0.4in;'>
                          <td width='635' valign='bottom' colspan='4' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 475.95pt; height: 0.4in;'>
                          <div style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>I certify that <u>Blake Collins</u>, who is known to me or who presented satisfactory identification, has, while in my presence and while under oath or affirmation, voluntarily signed this document and declared that it is true.</font></div>
                          </td>
                      </tr>
                      <tr style='page-break-inside: avoid; height: 0.3in;'>
                          <td width='56' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 41.7pt; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Date:</font></div>
                          </td>
                          <td width='167' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 125.4pt; height: 0.3in;'>
                          <div style='text-indent: 0.3pt; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                          <td width='142' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 106.5pt; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Sign here ?</font></div>
                          </td>
                          <td width='270' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 202.35pt; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                      <tr style='page-break-inside: avoid; height: 0.3in;'>
                          <td width='365' valign='bottom' colspan='3' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 3.8in; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Notary or Court Clerk</font></div>
                          </td>
                          <td width='270' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 202.35pt; height: 0.3in;'>
                          <div style='text-indent: 0.3pt; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                      <tr style='page-break-inside: avoid; height: 0.3in;'>
                          <td width='365' valign='bottom' colspan='3' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 3.8in; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'><font size='2'>Notary Seal</font></div>
                          </td>
                          <td width='270' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 202.35pt; height: 0.3in;'>
                          <div align='right' style='text-indent: 0.3pt; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div align='center' style='margin: 12pt 0in;'><b><span style='font-size: 14pt;'>Summons</span></b></div>
              <div style='margin: 12pt 0in 0.25in;'><font size='2'>The State of Utah to the Defendant(s):</font></div>
              <p>
              <table width='638' cellspacing='0' cellpadding='0' border='1' style='border: medium none; margin: auto auto auto 0.9pt; width: 6.65in; border-collapse: collapse;'>
                  <tbody>
                      <tr style='height: 0.3in;'>
                          <td width='638' valign='top' style='border-width: 1pt medium; border-style: solid none; border-color: black rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 6.65in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='638' valign='top' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) black; padding: 0in 5.4pt; background-color: transparent; width: 6.65in; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div style='margin: 12pt 0in;'><font size='2'>You are summoned to appear at trial to answer the above claim. The trial will be held at the court address shown above. <b>If you fail to appear, judgment may be entered against you for the total amount claimed</b>.</font></div>
              <p>
              <table width='643' cellspacing='0' cellpadding='0' border='0' style='width: 6.7in; border-collapse: collapse;'>
                  <tbody>
                      <tr style='height: 0.3in;'>
                          <td width='57' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 42.85pt; height: 0.3in;'>
                          <div align='right' style='text-align: right; margin: 0in 0in 0pt;'><font size='2'>Date</font></div>
                          </td>
                          <td width='177' valign='bottom' colspan='2' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 133.1pt; height: 0.3in;'>
                          <div align='right' style='text-align: right; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                          <td width='52' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 39.2pt; height: 0.3in;'>
                          <div align='right' style='text-align: right; margin: 0in 0in 0pt;'><font size='2'>Time</font></div>
                          </td>
                          <td width='86' valign='bottom' colspan='2' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 64.75pt; height: 0.3in;'>
                          <div align='center' style='text-align: center; margin: 0in 0in 0pt;'><font size='2'>:</font></div>
                          </td>
                          <td width='270' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 202.5pt; height: 0.3in;'>
                          <div style='margin: 0in 0in 0pt;'><font size='2'>&nbsp;a.m.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;p.m.</font></div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='57' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 42.85pt; height: 0.3in;'>
                          <div align='right' style='text-align: right; margin: 0in 0in 0pt;'><font size='2'>Room</font></div>
                          </td>
                          <td width='177' valign='bottom' colspan='2' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 133.1pt; height: 0.3in;'>
                          <div align='right' style='text-align: right; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                          <td width='139' valign='bottom' colspan='3' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 103.95pt; height: 0.3in;'>
                          <div align='right' style='text-align: right; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                          <td width='270' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 202.5pt; height: 0.3in;'>
                          <div align='right' style='text-align: right; margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='643' valign='bottom' colspan='7' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 6.7in; height: 0.3in;'>
                            <div style='margin: 6pt 0in 0pt;'><font size='2'><b>Notice to the Defendant.</b> A small claims case has been filed against you. This imposes upon you certain rights and responsibilities. You may obtain small claims information and instructions at </font><a href='http://www.utcourts.gov/howto/'><font color='#0000ff' size='2'>www.utcourts.gov/howto/</font></a></div>
                            <div style='margin: 6pt 0in;'>
                              <font size='2'><b>Disability Accommodations.</b> If you need accommodation of a disability, contact a judicial service assistant at least 3 days before the hearing.</font>
                            </div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='57' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 42.85pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'><font size='2'>Date:</font></div>
                          </td>
                          <td width='161' valign='bottom' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 120.6pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'><b>&nbsp;</b></div>
                          </td>
                          <td width='149' valign='bottom' colspan='3' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 111.95pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'><font size='2'>Sign here ?</font></div>
                          </td>
                          <td width='276' valign='bottom' colspan='2' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 207pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'><b>&nbsp;</b></div>
                          </td>
                      </tr>
                      <tr style='height: 0.3in;'>
                          <td width='57' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 42.85pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'>&nbsp;</div>
                          </td>
                          <td width='161' valign='bottom' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 120.6pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'><b>&nbsp;</b></div>
                          </td>
                          <td width='149' valign='bottom' colspan='3' style='border: medium none rgb(240, 240, 240); padding: 0in 5.4pt; background-color: transparent; width: 111.95pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'><font size='2'>Court Clerk</font></div>
                          </td>
                          <td width='276' valign='bottom' colspan='2' style='border-width: medium medium 1pt; border-style: none none solid; border-color: rgb(240, 240, 240) rgb(240, 240, 240) windowtext; padding: 0in 5.4pt; background-color: transparent; width: 207pt; height: 0.3in;'>
                          <div align='right' style='margin: 0in 0in 0pt;'><b>&nbsp;</b></div>
                          </td>
                      </tr>
                  </tbody>
              </table>
              </p>
              <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
              <div style='margin: 0in -63pt 0pt 0in;'>&nbsp;</div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :garnishments => true,
              :message_category_id => collections_category.id
              )


MessageTemplate.create!(
              :name => "Final Demand Letter",
              :enabled => true,
              :subject => "Loan in default. Garnishment pending.",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear [first_name],</p>
              <div>Your account is currently past due and carries an outstanding balance of <b>[payoff_amount]</b>. Several attempts have been made to contact you by phone, postal mail, and e-mail.&nbsp; It is very important that you contact our office immediately to make payment arrangements.&nbsp;</div>
              <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
              <div style='margin: 0in 0in 0pt;'>Not doing so will not stop further collections or legal actions against you. We are and always have been willing to work with you to pay down your balance, but you must contact us immediately.&nbsp;</div>
              <div style='margin: 0in 0in 0pt;'>&nbsp;</div>
              <div style='margin: 0in 0in 0pt;'>Should you elect to not respond to this correspondence we have no other alternative but to submit this debt to our legal department so that they may contact your employer for Wage Garnishment.&nbsp; Time is of the essence so please contact us immediately!</div>
              <p>&nbsp;</p>
              <div>Regards,</div>
              <p>&nbsp;</p>
              <p>FloBridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p><span style='font-size: medium;'>&nbsp;<span style='font-size: 12pt;'>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></p>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :garnishments => true,
              :message_category_id => collections_category.id
              )


MessageTemplate.create!(
              :name => "Garnishment & SCAN Notice",
              :enabled => true,
              :subject => "Wage Garnishment Pending",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Regarding [first_name] [last_name]'s past due loan balance of</p>
              <p><strong>[payoff_amount]</strong></p>
              <p>&nbsp;</p>
              <p>Dear [first_name],</p>
              <p>We have made repeated attempts to reach you regarding your past due loan balance.</p>
              <p>You are hereby given seven days from this notice in accordance with Section 7-15-1, Utah Code Annotated, or appropriate Civil Legal Action is being filed against you for the amount due and owing together with interest, court cost, attorney's fees and actual cost of collections as provided by law.</p>
              <p>Your employer is currently being contacted and we will immediately seek to garnish wages.</p>
              <p>You are currently being added to <strong>SCAN</strong> (<strong>S</strong>hared <strong>C</strong>heck <strong>A</strong>uthorization <strong>N</strong>etwork).&nbsp; This will permanently affect your credit rating with all bureaus.&nbsp; This will immediately stop your ability to do the following:</p>
              <p>1. Write checks throughout the United States.</p>
              <p>2. Open any bank account throughout the United States.</p>
              <p>3. Receive another loan from any short-term lender throughout the United States.</p>
              <p>Representatives are standing by to assist you in bringing your account current, but we cannot help you without communication from you.&nbsp; Call now <strong>1 (866) 569-3321 (Option #2)</strong>.</p>
              <p>Regards,<br />
              &nbsp;</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: 12pt;'>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></div>",
             
              :msg_event => Loan::GARNISHMENTS,
              :send_schedule_flag => MessageTemplate::MANUAL,
              :message_category_id => collections_category.id
              )


MessageTemplate.create!(
              :name => "Loan Collection Letter",
              :enabled => true,
              :subject => "Past Due Notice: Please contact ASAP",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p><span style='font-size: larger;'><br />
              Dear [first_name]</span></p>
              <div style='line-height: normal; text-indent: 0.5in; margin: 0in 0in 0pt;'><span style='font-size: larger;'>&nbsp;</span></div>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: larger;'>We are trying to reach you regarding your account.&nbsp; Your scheduled payments have not gone through and your account is currently <b>past due</b>. The outstanding balance is <b>[payoff_amount]</b><span style='color: rgb(51, 51, 51);'>.</span>&nbsp; </span></div>
              <div style='line-height: normal; margin: 0in 0in 0pt;'>&nbsp;</div>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: larger;'>In order to correct the default on your account, it is very important that you contact us immediately&nbsp; at <strong>(866) 569-3321</strong> to make payment arrangements. <br />
              </span></div>
              <p><span style='font-size: larger;'>Thank you,</span></p>
              <p>&nbsp;</p>
              <p>FloBridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;<span style='font-size: 12pt;'>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></p>
              <p>&nbsp;</p>",
             
              :msg_event => Loan::COLLECTIONS,
              :send_schedule_flag => Loan::TRIGGER_EVENT,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Loan is Past Due",
              :enabled => true,
              :subject => "Loan is Past Due",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],
              Your loan is currently past due. Call
              1(866)569-3321 (Option #2) ASAP to arrange pmt and avoid extra fees.
              FloBridge.",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Loan Payment NSF",
              :enabled => true,
              :subject => "Past Due Notice",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],

              Your loan pmt did not go through. Call
              1(866)569-3321 (Option #2)to make payment and avoid additional fees.
              FloBridge",
             
              :msg_event => Loan::PAYMENT_NSF,
              :send_schedule_flag => MessageTemplate::TRIGGER_EVENT,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 01",
              :enabled => true,
              :subject => "Past Due Notice: Collection Action",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 02",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 03",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 04",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 05",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 06",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 07",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 08",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 09",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Ongoing Collection 10",
              :enabled => true,
              :subject => "Past Due Notice: Flobridge short-term loan",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear <strong>[first_name]</strong><strong>:</strong></p>
              <p>We have been trying to reach you in regards to your past due account.&nbsp; Our Collections Department is authorized to work with you to make payment arrangements. This account is at risk for futher collection activities and additional fees associated with delinquent accounts.&nbsp; Our account representatives are standing by Mon-Fri, 7:30 am to 6:30 pm MST.&nbsp; Please contact us at <strong>1 (866) 569-3321</strong>.</p>
              <p>Thank you.</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'><span><span><span>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></span></span></span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Payment Returned NSF [AUTO]",
              :enabled => true,
              :subject => "Problem with your loan payment",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Dear [first_name],</p>
              <p>Your payment was returned to us by your bank. As a result, you will be automatically charged an NSF fee and your account is currently in default. Please contact our office at <strong>866-569-3321</strong> as soon as possible to make arrangements for payment.&nbsp;</p>
              <p>Our account representatives will be trying to contact you, but please feel free to call us.&nbsp; Communication from you provides us with the greatest lattitude as we help you bring your account current. Our account representatives are standing by from 7:30 am to 6:30 pm MST to assist you.</p>
              <p>Sincerely,</p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Processed Extension",
              :enabled => true,
              :subject => "Processed Extension",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p>Your Loan Extension Has Been Processed. If you have any questions please call Flobridge at 1-866-569-3321 (Option #2)</p>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Processed Extension",
              :enabled => true,
              :subject => "Processed Extension",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Your Loan Extension Has Been Processed. If you have any questions please call Flobridge at 1-866-569-3321 (Option #2)",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Reporting to Credit Bureaus",
              :enabled => true,
              :subject => "Reporting to Credit Bureaus",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "Your past due loan is about to be reported to the credit bureaus.
              You can avoid this by calling (866) 569-3321 (Option #2)to arrange pmt.
              FloBridge",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Settlement Letter",
              :enabled => true,
              :subject => "Past Due Notice: Final Offer",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "<p><span style='font-size: small;'>Dear <strong>[first_name]</strong>:</span></p>
              <p><span style='font-size: small;'>Your account has been past due since [due_date]. Your outstanding balance is [payoff_amount]. </span></p>
              <p><span style='font-size: small;'>We anticipate that before [currentdate+7] your account will be transferred to a very aggressive outside collection agency, where it will be subject to additional fees and a very thorough collection regime.&nbsp; Before that happens, we would like to offer you a final opportunity to contact and settle your account.&nbsp; </span></p>
              <p><span style='font-size: small;'><span>By taking advantage of this offer, all negative data that we have reported on you will be removed.&nbsp; </span></span><span style='font-size: small;'>We are willing to offer a partial reduction in the interest and fees that have accrued thus far if you contact us at <strong>(866) 569-3321</strong> <u><em>before</em></u> the account goes to outside collections. </span></p>
              <p>&nbsp;</p>
              <p><span style='font-size: small;'>Regards, </span></p>
              <p>Flobridge Collection Department<br />
              contact@flobridge.com</p>
              <p><span style='font-size: larger;'><strong><span>Toll Free: (866) 569-3321 (Option #2)</span></strong></span></p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <p>&nbsp;</p>
              <div style='line-height: normal; margin: 0in 0in 0pt;'><span style='font-size: x-small;'>&ldquo;This communication is an attempt to collect a debt and any information obtained will be used for that purpose.&rdquo; </span></div>",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Wage Garnishment",
              :enabled => true,
              :subject => "Wage Garnishment",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "[first_name],
              In order to avoid additional fees and garnishment of your wages,
              Call (866) 569-3321 (Option #2)to pay your past due loan.
              FloBridge",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :garnishments => true,
              :message_category_id => collections_category.id
              )

MessageTemplate.create!(
              :name => "Your Past Due Loan",
              :enabled => true,
              :subject => "Contacting Your Work",
              :content_type => MessageTemplate::TEXT_HTML,
              :email_body => "We need to get in touch with you regarding the past due status of your loan.
              FloBridge (866) 569-3321 (Option #2)",
             
              :send_schedule_flag => MessageTemplate::MANUAL,
              :collections => true,
              :garnishments => true,
              :message_category_id => collections_category.id
              )


