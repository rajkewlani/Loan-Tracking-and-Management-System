# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100623225505) do

  create_table "ach_batches", :force => true do |t|
    t.integer  "ach_provider_id"
    t.integer  "credits"
    t.decimal  "credit_amount",   :precision => 15, :scale => 2, :default => 0.0
    t.integer  "debits"
    t.decimal  "debit_amount",    :precision => 15, :scale => 2, :default => 0.0
    t.string   "file_name"
    t.text     "csv"
    t.date     "batch_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ach_batches", ["ach_provider_id"], :name => "fk_ach_batches_ach_provider_id"
  add_index "ach_batches", ["created_at"], :name => "index_ach_batches_on_created_at"

  create_table "ach_providers", :force => true do |t|
    t.string   "name",                    :limit => 40, :null => false
    t.string   "login_id"
    t.string   "origin_id"
    t.string   "processing_email"
    t.string   "support_email"
    t.string   "support_phone"
    t.string   "primary_contact_name"
    t.string   "primary_contact_phone"
    t.string   "primary_contact_email"
    t.string   "alternate_contact_name"
    t.string   "alternate_contact_phone"
    t.string   "alternate_contact_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ach_returns", :force => true do |t|
    t.integer  "ach_provider_id",                                                  :null => false
    t.string   "company_identifier"
    t.string   "company_name"
    t.string   "ee_date"
    t.integer  "transaction_code"
    t.string   "routing_number",                                                   :null => false
    t.string   "account_number",                                                   :null => false
    t.integer  "amount",              :limit => 10, :precision => 10, :scale => 0, :null => false
    t.integer  "loan_id",                                                          :null => false
    t.string   "customer_name",                                                    :null => false
    t.string   "return_reason_code",                                               :null => false
    t.string   "correction_info"
    t.integer  "loan_transaction_id",                                              :null => false
    t.datetime "processed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ach_returns", ["ach_provider_id"], :name => "fk_ach_returns_ach_provider_id"
  add_index "ach_returns", ["loan_id"], :name => "index_ach_returns_on_loan_id"
  add_index "ach_returns", ["loan_transaction_id"], :name => "index_ach_returns_on_loan_transaction_id", :unique => true
  add_index "ach_returns", ["processed_at"], :name => "index_ach_returns_on_processed_at"

  create_table "ach_transactions", :force => true do |t|
    t.integer  "ach_batch_id"
    t.integer  "loan_id"
    t.integer  "store_id"
    t.string   "company_name"
    t.string   "sec"
    t.string   "description"
    t.string   "effective_date"
    t.string   "individual"
    t.string   "name"
    t.string   "receiving_routing_number"
    t.string   "receiving_account_number"
    t.integer  "transaction_code"
    t.string   "amount"
    t.string   "optional_1",               :limit => 20
    t.string   "optional_2",               :limit => 2
    t.string   "trace_number",             :limit => 15
    t.string   "status_code",              :limit => 1
    t.string   "reason",                   :limit => 30
    t.string   "corrective_information",   :limit => 35
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_accounts", :force => true do |t|
    t.integer  "customer_id",                                                                                   :null => false
    t.string   "bank_name",                     :limit => 30,                                                   :null => false
    t.string   "bank_account_type",             :limit => 8,                                                    :null => false
    t.string   "encrypted_bank_aba_number",                                                                     :null => false
    t.string   "encrypted_bank_account_number",                                                                 :null => false
    t.integer  "months_at_bank",                                                                                :null => false
    t.boolean  "bank_direct_deposit",                                                                           :null => false
    t.string   "bank_address",                  :limit => 30
    t.string   "bank_city",                     :limit => 30
    t.string   "bank_state",                    :limit => 2
    t.string   "bank_zip",                      :limit => 5
    t.string   "bank_phone",                    :limit => 10
    t.decimal  "bank_account_balance",                        :precision => 10, :scale => 2
    t.integer  "number_of_nsf",                                                              :default => 0
    t.integer  "number_of_transactions",                                                     :default => 0
    t.boolean  "funding_account",                                                            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "countries", :force => true do |t|
    t.string   "name",                                                            :null => false
    t.string   "code",                                                            :null => false
    t.float    "max_apr"
    t.integer  "max_loan_amount",    :limit => 10, :precision => 10, :scale => 0
    t.integer  "min_loan_days"
    t.integer  "max_loan_days"
    t.integer  "max_loans_per_year"
    t.integer  "max_extensions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["code"], :name => "index_countries_on_code", :unique => true

  create_table "credit_cards", :force => true do |t|
    t.string   "card_type",               :limit => 8, :null => false
    t.string   "encrypted_last_4_digits",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customer_phone_listings", :force => true do |t|
    t.integer  "customer_id",               :null => false
    t.string   "phone",       :limit => 10, :null => false
    t.string   "owner"
    t.string   "title"
    t.string   "company"
    t.string   "address"
    t.string   "city"
    t.string   "state",       :limit => 2
    t.string   "zip",         :limit => 20
    t.string   "line_type"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customer_phone_listings", ["customer_id"], :name => "fk_customer_phone_listings_customer_id"

  create_table "customers", :force => true do |t|
    t.integer  "lead_provider_id",                                                           :default => 0,               :null => false
    t.integer  "portfolio_id",                                                                                            :null => false
    t.string   "ip_address",                   :limit => 20,                                                              :null => false
    t.string   "lead_source",                  :limit => 100
    t.string   "tracker_id"
    t.boolean  "relaxed_validation",                                                         :default => false,           :null => false
    t.string   "first_name",                   :limit => 30,                                                              :null => false
    t.string   "middle_name",                  :limit => 30
    t.string   "last_name",                    :limit => 30,                                                              :null => false
    t.string   "mothers_maiden_name",          :limit => 30
    t.string   "encrypted_ssn",                                                                                           :null => false
    t.string   "gender",                       :limit => 1
    t.string   "email",                        :limit => 50
    t.date     "birth_date"
    t.binary   "encrypted_dl_number"
    t.string   "dl_state",                     :limit => 2
    t.boolean  "military",                                                                   :default => false,           :null => false
    t.string   "home_phone",                   :limit => 10
    t.string   "work_phone",                   :limit => 10
    t.string   "cell_phone",                   :limit => 10
    t.boolean  "do_not_call_home",                                                           :default => false
    t.boolean  "do_not_call_work",                                                           :default => false
    t.boolean  "do_not_call_cell",                                                           :default => false
    t.string   "fax",                          :limit => 10
    t.string   "address",                      :limit => 30
    t.string   "city",                         :limit => 30
    t.string   "state",                        :limit => 2
    t.string   "zip",                          :limit => 5
    t.string   "country_code",                 :limit => 2,                                                               :null => false
    t.string   "time_zone",                                                                                               :null => false
    t.boolean  "time_zone_geocoded",                                                         :default => false
    t.string   "best_time_to_call"
    t.string   "language"
    t.integer  "monthly_income",                                                             :default => 0,               :null => false
    t.string   "income_source",                :limit => 20,                                                              :null => false
    t.string   "pay_frequency",                :limit => 20,                                                              :null => false
    t.string   "employer_name",                :limit => 30
    t.string   "occupation",                   :limit => 100
    t.integer  "months_employed",                                                                                         :null => false
    t.string   "employer_address",             :limit => 30
    t.string   "employer_city",                :limit => 30
    t.string   "employer_state",               :limit => 2
    t.string   "employer_zip",                 :limit => 5
    t.string   "employer_phone",               :limit => 10
    t.string   "employer_phone_ext",           :limit => 5
    t.string   "employer_fax",                 :limit => 10
    t.string   "supervisor_name",              :limit => 30
    t.string   "supervisor_phone",             :limit => 10
    t.string   "supervisor_phone_ext",         :limit => 5
    t.string   "residence_type",               :limit => 4,                                                               :null => false
    t.integer  "monthly_residence_cost",                                                                                  :null => false
    t.integer  "months_at_address",                                                                                       :null => false
    t.string   "landlord_name",                :limit => 50
    t.string   "landlord_phone",               :limit => 10
    t.string   "landlord_address",             :limit => 30
    t.string   "landlord_city",                :limit => 30
    t.string   "landlord_state",               :limit => 2
    t.string   "landlord_zip",                 :limit => 5
    t.boolean  "contact_by_mail",                                                            :default => true
    t.boolean  "contact_by_email",                                                           :default => true
    t.boolean  "contact_by_sms",                                                             :default => true
    t.date     "next_pay_date_1"
    t.date     "next_pay_date_2"
    t.integer  "credit_limit",                 :limit => 10,  :precision => 10, :scale => 0,                              :null => false
    t.string   "reference_1_name",             :limit => 50
    t.string   "reference_1_phone",            :limit => 10
    t.string   "reference_1_address",          :limit => 30
    t.string   "reference_1_city",             :limit => 30
    t.string   "reference_1_state",            :limit => 2
    t.string   "reference_1_zip",              :limit => 5
    t.string   "reference_1_relationship",     :limit => 20
    t.string   "reference_2_name",             :limit => 50
    t.string   "reference_2_phone",            :limit => 10
    t.string   "reference_2_address",          :limit => 30
    t.string   "reference_2_city",             :limit => 30
    t.string   "reference_2_state",            :limit => 2
    t.string   "reference_2_zip",              :limit => 5
    t.string   "reference_2_relationship",     :limit => 20
    t.string   "authnet_customer_profile_id"
    t.boolean  "is_test",                                                                    :default => false
    t.string   "aasm_state",                                                                 :default => "not_purchased"
    t.integer  "manually_entered_by"
    t.string   "reject_reason"
    t.boolean  "send_sms_messages",                                                          :default => false,           :null => false
    t.boolean  "send_marketing_emails",                                                      :default => false,           :null => false
    t.boolean  "send_prerecorded_messages",                                                  :default => false,           :null => false
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "reset_password_at_next_login",                                               :default => false,           :null => false
    t.boolean  "login_suspended",                                                            :default => false,           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["encrypted_ssn"], :name => "index_customers_on_encrypted_ssn"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.integer "parent_id"
    t.integer "customer_id"
    t.integer "loan_id"
    t.string  "owner_type",   :default => "Customer"
    t.string  "description"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
  end

  create_table "employers", :force => true do |t|
    t.string   "name",            :limit => 30,                    :null => false
    t.string   "name_normalized",                                  :null => false
    t.string   "state_code"
    t.string   "country_code",                                     :null => false
    t.boolean  "will_garnish",                  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "employers", ["name_normalized", "state_code"], :name => "index_employers_on_name_normalized_and_state_code"

  create_table "factor_trusts", :force => true do |t|
    t.integer  "customer_id",  :null => false
    t.text     "response_xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "factor_trusts", ["customer_id"], :name => "index_factor_trusts_on_customer_id"

  create_table "high_risk_bank_branches", :force => true do |t|
    t.string   "aba_routing_number", :limit => 9, :null => false
    t.string   "name",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "high_risk_bank_branches", ["aba_routing_number"], :name => "index_high_risk_bank_branches_on_aba_routing_number", :unique => true
  add_index "high_risk_bank_branches", ["name"], :name => "index_high_risk_bank_branches_on_name"

  create_table "investments", :force => true do |t|
    t.integer  "investor_id",                                 :null => false
    t.integer  "portfolio_id",                                :null => false
    t.decimal  "amount",       :precision => 15, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "investments", ["investor_id"], :name => "fk_investments_investor_id"
  add_index "investments", ["portfolio_id"], :name => "fk_investments_portfolio_id"

  create_table "investors", :force => true do |t|
    t.string   "investor_name",                          :null => false
    t.string   "first_name",                             :null => false
    t.string   "last_name",                              :null => false
    t.string   "email",                                  :null => false
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "authorization_token"
    t.datetime "last_login_at"
    t.string   "last_login_ip"
    t.boolean  "logged_in",           :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "investors", ["authorization_token"], :name => "index_investors_on_authorization_token", :unique => true
  add_index "investors", ["email"], :name => "index_investors_on_email", :unique => true
  add_index "investors", ["last_name"], :name => "index_investors_on_last_name"

  create_table "lead_filters", :force => true do |t|
    t.string   "name",                                :null => false
    t.integer  "minimum_months_at_job"
    t.integer  "minimum_months_at_bank"
    t.integer  "minimum_age"
    t.boolean  "allow_pay_frequency_weekly"
    t.boolean  "allow_pay_frequency_biweekly"
    t.boolean  "allow_pay_frequency_monthly"
    t.boolean  "allow_pay_frequency_twice_per_month"
    t.boolean  "allow_payroll_type_cash"
    t.boolean  "allow_payroll_type_check"
    t.boolean  "allow_payroll_type_direct_deposit"
    t.boolean  "allow_payroll_type_benefits"
    t.integer  "minimum_factor_trust_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lead_providers", :force => true do |t|
    t.string   "name",                                 :null => false
    t.string   "username",                             :null => false
    t.string   "password",                             :null => false
    t.integer  "lead_filter_id",                       :null => false
    t.integer  "status",                :default => 0, :null => false
    t.string   "primary_contact"
    t.string   "primary_contact_email"
    t.string   "primary_contact_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loan_snapshots", :force => true do |t|
    t.integer  "loan_id",                                                     :null => false
    t.integer  "principal_owed", :limit => 10, :precision => 10, :scale => 0, :null => false
    t.integer  "interest_owed",  :limit => 10, :precision => 10, :scale => 0, :null => false
    t.integer  "fees_owed",      :limit => 10, :precision => 10, :scale => 0, :null => false
    t.string   "aasm_state",                                                  :null => false
    t.date     "created_on",                                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loan_snapshots", ["created_on"], :name => "index_loan_snapshots_on_created_on"

  create_table "loan_transactions", :force => true do |t|
    t.integer  "loan_id",                                                              :null => false
    t.integer  "ach_batch_id"
    t.string   "tran_type",                                                            :null => false
    t.decimal  "total",              :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "principal",          :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "interest",           :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "fees",               :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "recovery",           :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "failed_total",       :precision => 15, :scale => 2, :default => 0.0
    t.boolean  "nsf",                                               :default => false, :null => false
    t.boolean  "account_closed",                                    :default => false, :null => false
    t.integer  "check_number"
    t.string   "ach_return_code"
    t.string   "ach_return_reason"
    t.integer  "payment_account_id"
    t.date     "new_due_date"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loan_transactions", ["loan_id"], :name => "fk_loan_transactions_loan_id"

  create_table "loans", :force => true do |t|
    t.integer  "customer_id",                                                                             :null => false
    t.integer  "portfolio_id",                                                                            :null => false
    t.integer  "underwriter_id"
    t.string   "underwriter_type",                                                    :default => "User"
    t.integer  "collections_agent_id"
    t.string   "collections_agent_type",                                              :default => "User"
    t.integer  "garnishments_agent_id"
    t.string   "garnishments_agent_type",                                             :default => "User"
    t.date     "garnishment_approved_on"
    t.datetime "garnishment_packet_sent_at"
    t.string   "garnishment_sub_status"
    t.boolean  "imported",                                                            :default => false
    t.boolean  "paying",                                                              :default => false
    t.date     "due_date"
    t.date     "auto_extend_to_upon_funding"
    t.decimal  "requested_loan_amount",                :precision => 15, :scale => 2,                     :null => false
    t.float    "apr",                                                                                     :null => false
    t.decimal  "principal_owed",                       :precision => 15, :scale => 2
    t.decimal  "interest_owed",                        :precision => 15, :scale => 2
    t.decimal  "fees_owed",                            :precision => 15, :scale => 2
    t.date     "amounts_owed_updated_on"
    t.date     "last_payment_confirmed_on"
    t.string   "aasm_state"
    t.string   "reject_reason"
    t.decimal  "max_loan_amount",                      :precision => 15, :scale => 2
    t.integer  "min_loan_days"
    t.integer  "max_loan_days"
    t.integer  "max_extensions"
    t.integer  "max_loans_per_year",                                                  :default => 52,     :null => false
    t.datetime "disclosed_finance_charge_amount_at"
    t.datetime "disclosed_due_date_at"
    t.datetime "disclosed_apr_at"
    t.datetime "disclosed_extend_12_weeks_max_at"
    t.datetime "disclosed_partial_payments_at"
    t.datetime "disclosed_recission_at"
    t.datetime "disclosed_must_request_extensions_at"
    t.datetime "disclosed_member_area_at"
    t.decimal  "signature_page_loan_amount",           :precision => 15, :scale => 2,                     :null => false
    t.decimal  "signature_page_finance_charge",        :precision => 15, :scale => 2
    t.string   "signature_token"
    t.datetime "signature_page_arrived_at"
    t.datetime "signature_page_accepted_at"
    t.string   "signature_page_ip_address"
    t.string   "signature_page_accepted_name"
    t.boolean  "verified_personal",                                                   :default => false
    t.boolean  "verified_financial",                                                  :default => false
    t.boolean  "verified_employment_with_customer",                                   :default => false
    t.boolean  "verified_employment_with_employer",                                   :default => false
    t.boolean  "verified_tila",                                                       :default => false
    t.integer  "approved_by"
    t.datetime "approved_at"
    t.decimal  "approved_loan_amount",                 :precision => 15, :scale => 2
    t.date     "funded_on"
    t.boolean  "financial_data_change",                                               :default => false
    t.boolean  "reloan",                                                              :default => false
    t.date     "paid_in_full_on"
    t.integer  "extensions_granted",                                                  :default => 0
    t.date     "recission_requested_on"
    t.date     "recission_draft_on"
    t.integer  "recission_draft_ach_batch_id"
    t.date     "defaulted_on"
    t.date     "collections_on"
    t.date     "garnishments_on"
    t.date     "written_off_on"
    t.integer  "written_off_by"
    t.string   "remark"
    t.integer  "garnishment_fax_attempts",                                            :default => 0,      :null => false
    t.datetime "garnishment_fax_confirmed_at"
    t.date     "garnishment_packet_sent_by_mail_on"
    t.string   "garnishment_telephone_status"
    t.date     "created_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loans", ["customer_id"], :name => "fk_loans_customer_id"
  add_index "loans", ["defaulted_on"], :name => "index_loans_on_defaulted_on"
  add_index "loans", ["portfolio_id"], :name => "fk_loans_portfolio_id"
  add_index "loans", ["signature_token"], :name => "index_loans_on_signature_token", :unique => true

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["name"], :name => "index_locations_on_name", :unique => true

  create_table "locations_users", :id => false, :force => true do |t|
    t.integer "location_id", :null => false
    t.integer "user_id",     :null => false
  end

  add_index "locations_users", ["location_id", "user_id"], :name => "index_locations_users_on_location_id_and_user_id", :unique => true
  add_index "locations_users", ["user_id"], :name => "fk_locations_users_user_id"

  create_table "log_details", :force => true do |t|
    t.integer "log_id"
    t.string  "label"
    t.text    "detail"
  end

  create_table "logs", :force => true do |t|
    t.text     "message"
    t.integer  "loggable_id"
    t.string   "loggable_type"
    t.integer  "user_id"
    t.string   "group"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logs", ["loggable_id"], :name => "index_logs_on_loggable_id"
  add_index "logs", ["loggable_type"], :name => "index_logs_on_loggable_type"
  add_index "logs", ["owner_id"], :name => "index_logs_on_owner_id"
  add_index "logs", ["owner_type"], :name => "index_logs_on_owner_type"
  add_index "logs", ["user_id"], :name => "index_logs_on_user_id"

  create_table "mail_templates", :force => true do |t|
    t.string   "name"
    t.string   "subject"
    t.string   "content_type"
    t.text     "body"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_categories", :force => true do |t|
    t.string   "name"
    t.string   "footer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_templates", :force => true do |t|
    t.string   "name"
    t.integer  "message_category_id"
    t.boolean  "enabled",             :default => false, :null => false
    t.string   "content_type",                           :null => false
    t.string   "subject"
    t.text     "email_body"
    t.text     "sms_body"
    t.string   "description"
    t.string   "msg_event"
    t.string   "send_schedule_flag",                     :null => false
    t.integer  "days"
    t.string   "before_after"
    t.string   "base_date"
    t.integer  "send_hour"
    t.string   "required_aasm_state"
    t.boolean  "underwriting",        :default => false, :null => false
    t.boolean  "collections",         :default => false, :null => false
    t.boolean  "garnishments",        :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_accounts", :force => true do |t|
    t.integer  "customer_id",                :null => false
    t.integer  "account_id",                 :null => false
    t.string   "account_type",               :null => false
    t.string   "authnet_payment_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_accounts", ["customer_id"], :name => "fk_payment_accounts_customer_id"

  create_table "pending_ach_transactions", :force => true do |t|
    t.integer  "loan_id"
    t.integer  "store_id"
    t.string   "company_name"
    t.string   "sec"
    t.string   "description"
    t.date     "effective_date"
    t.string   "individual"
    t.string   "name"
    t.string   "receiving_routing_number"
    t.string   "receiving_account_number"
    t.integer  "transaction_code"
    t.string   "amount"
    t.string   "optional_1",               :limit => 20
    t.string   "optional_2",               :limit => 2
    t.string   "trace_number",             :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pending_ach_transactions", ["loan_id"], :name => "fk_pending_ach_transactions_loan_id"

  create_table "portfolio_snapshots", :force => true do |t|
    t.integer  "portfolio_id",        :null => false
    t.integer  "new_loans_today",     :null => false
    t.integer  "reloans_today",       :null => false
    t.integer  "total_loans_today",   :null => false
    t.float    "reloan_percentage",   :null => false
    t.integer  "loans_out_today",     :null => false
    t.integer  "total_loans_to_date", :null => false
    t.date     "snapshot_on",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portfolio_snapshots", ["portfolio_id"], :name => "fk_portfolio_snapshots_portfolio_id"
  add_index "portfolio_snapshots", ["snapshot_on"], :name => "index_portfolio_snapshots_on_snapshot_on"

  create_table "portfolios", :force => true do |t|
    t.string   "name",                                                                  :null => false
    t.float    "apr",                                               :default => 664.84, :null => false
    t.decimal  "max_loan_amount",    :precision => 15, :scale => 2, :default => 500.0,  :null => false
    t.integer  "min_loan_days",                                     :default => 3,      :null => false
    t.integer  "max_loan_days",                                     :default => 84,     :null => false
    t.integer  "max_extensions",                                    :default => 11,     :null => false
    t.integer  "max_loans_per_year",                                :default => 52,     :null => false
    t.string   "port_key",                                                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portfolios", ["created_at"], :name => "index_portfolios_on_created_at"
  add_index "portfolios", ["port_key"], :name => "index_portfolios_on_port_key"

  create_table "reminders", :force => true do |t|
    t.integer  "loan_id",    :null => false
    t.integer  "user_id"
    t.date     "remind_on",  :null => false
    t.string   "comment",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reminders", ["loan_id"], :name => "fk_reminders_loan_id"

  create_table "scheduled_ach_drafts", :force => true do |t|
    t.integer  "loan_id",                                                                     :null => false
    t.integer  "bank_account_id",                                                             :null => false
    t.date     "draft_date",                                                                  :null => false
    t.integer  "amount",          :limit => 10, :precision => 10, :scale => 0,                :null => false
    t.integer  "principal",       :limit => 10, :precision => 10, :scale => 0, :default => 0, :null => false
    t.integer  "interest",        :limit => 10, :precision => 10, :scale => 0, :default => 0, :null => false
    t.integer  "fees",            :limit => 10, :precision => 10, :scale => 0, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduled_ach_drafts", ["loan_id"], :name => "fk_scheduled_ach_drafts_loan_id"

  create_table "scheduled_payments", :force => true do |t|
    t.integer  "customer_id",                                                                 :null => false
    t.integer  "loan_id",                                                                     :null => false
    t.integer  "payment_account_id",                                                          :null => false
    t.date     "draft_date",                                                                  :null => false
    t.decimal  "amount",                    :precision => 15, :scale => 2,                    :null => false
    t.decimal  "principal",                 :precision => 15, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "interest",                  :precision => 15, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "fees",                      :precision => 15, :scale => 2, :default => 0.0,   :null => false
    t.date     "due_date_before_extension"
    t.string   "aasm_state",                                                                  :null => false
    t.boolean  "extension",                                                :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduled_payments", ["loan_id", "draft_date"], :name => "index_scheduled_payments_on_loan_id_and_draft_date", :unique => true

  create_table "settings", :force => true do |t|
    t.float    "apr",                           :default => 664.84, :null => false
    t.integer  "max_new_customer_credit_limit", :default => 300,    :null => false
    t.integer  "max_credit_limit",              :default => 1500,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "name",                                                                               :null => false
    t.string   "code",                                                                               :null => false
    t.float    "max_apr"
    t.integer  "max_loan_amount",     :limit => 10, :precision => 10, :scale => 0
    t.integer  "min_loan_days"
    t.integer  "max_loan_days"
    t.integer  "max_loans_per_year"
    t.integer  "max_extensions"
    t.boolean  "garnishment_allowed",                                              :default => true, :null => false
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "states", ["country_id", "code"], :name => "index_states_on_country_id_and_code", :unique => true

  create_table "teams", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "underwriter_verifications", :force => true do |t|
    t.integer  "customer_id",                      :null => false
    t.integer  "underwriter_id",                   :null => false
    t.string   "verification_type",                :null => false
    t.text     "notes"
    t.integer  "status",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "underwriter_verifications", ["customer_id"], :name => "fk_underwriter_verifications_customer_id"

  create_table "user_comment_notifications", :force => true do |t|
    t.integer  "author_id",                        :null => false
    t.integer  "user_id",                          :null => false
    t.integer  "comment_id",                       :null => false
    t.string   "short_message"
    t.boolean  "mark_as_read",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_comment_notifications", ["comment_id"], :name => "fk_user_comment_notifications_comment_id"
  add_index "user_comment_notifications", ["user_id"], :name => "fk_user_comment_notifications_user_id"

  create_table "users", :force => true do |t|
    t.string   "role",                                            :null => false
    t.string   "username",                                        :null => false
    t.string   "email",                                           :null => false
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "reset_password_at_next_login", :default => false, :null => false
    t.boolean  "login_suspended",              :default => false, :null => false
    t.string   "first_name",                                      :null => false
    t.string   "last_name",                                       :null => false
    t.string   "authorization_token"
    t.integer  "team_id"
    t.boolean  "manager",                      :default => false, :null => false
    t.boolean  "available",                    :default => true,  :null => false
    t.datetime "last_login_at"
    t.string   "last_login_ip"
    t.boolean  "logged_in",                    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authorization_token"], :name => "index_users_on_authorization_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["team_id"], :name => "index_users_on_team_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
