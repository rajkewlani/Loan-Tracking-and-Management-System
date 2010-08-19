require 'migration_helpers'

class CreateLoans < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :loans do |t|
      t.integer   :customer_id,                                     :null => false
      t.integer   :portfolio_id,                                    :null => false
      t.integer   :underwriter_id
      t.string    :underwriter_type,            :default => 'User'
      t.integer   :collections_agent_id
      t.string    :collections_agent_type,      :default => 'User'
      t.integer   :garnishments_agent_id
      t.string    :garnishments_agent_type,     :default => 'User'
      t.date      :garnishment_approved_on
      t.datetime  :garnishment_packet_sent_at
      t.string    :garnishment_sub_status
      t.boolean   :imported,                    :default => false
      t.boolean   :paying,                      :default => false
      t.date      :due_date
      t.date      :auto_extend_to_upon_funding
      t.decimal   :requested_loan_amount,                           :null => false,   :precision => 15, :scale => 2
      t.float     :apr,                                             :null => false
      t.decimal   :principal_owed,                                                    :precision => 15, :scale => 2
      t.decimal   :interest_owed,                                                     :precision => 15, :scale => 2
      t.decimal   :fees_owed,                                                         :precision => 15, :scale => 2
      t.date      :amounts_owed_updated_on
      t.date      :last_payment_confirmed_on
      t.string    :aasm_state
      t.string    :reject_reason
      
      # Limits - from portfolio, state, and country
      t.decimal   :max_loan_amount,                                                   :precision => 15, :scale => 2
      t.integer   :min_loan_days
      t.integer   :max_loan_days
      t.integer   :max_extensions
      t.integer   :max_loans_per_year,                              :null => false,  :default => 52

      # TILA Disclosures
      t.datetime  :disclosed_finance_charge_amount_at
      t.datetime  :disclosed_due_date_at
      t.datetime  :disclosed_apr_at
      t.datetime  :disclosed_extend_12_weeks_max_at
      t.datetime  :disclosed_partial_payments_at
      t.datetime  :disclosed_recission_at
      t.datetime  :disclosed_must_request_extensions_at
      t.datetime  :disclosed_member_area_at
      # TILA Signature
      t.decimal   :signature_page_loan_amount,                      :null => false,   :precision => 15, :scale => 2
      t.decimal   :signature_page_finance_charge,                                     :precision => 15, :scale => 2
      t.string    :signature_token
      t.datetime  :signature_page_arrived_at
      t.datetime  :signature_page_accepted_at
      t.string    :signature_page_ip_address
      t.string    :signature_page_accepted_name
      # Underwriting verifications
      t.boolean   :verified_personal, :default => false
      t.boolean   :verified_financial, :default => false
      t.boolean   :verified_employment_with_customer, :default => false
      t.boolean   :verified_employment_with_employer, :default => false
      t.boolean   :verified_tila, :default => false
      # Final Approval
      t.integer   :approved_by
      t.datetime  :approved_at
      t.decimal   :approved_loan_amount,                                              :precision => 15, :scale => 2
      # Funding
      t.date      :funded_on
      t.boolean   :financial_data_change, :default => false
      t.boolean   :reloan, :default => false   # Customer's most recent funded loan is paid_in_full
      t.date      :paid_in_full_on

      # Extensions
      t.integer   :extensions_granted, :default => 0

      # Recission
      t.date      :recission_requested_on
      t.date      :recission_draft_on
      t.integer   :recission_draft_ach_batch_id
      t.ingeter   :recission_bank_account_id

      # Default
      t.date      :defaulted_on
      t.date      :collections_on   # Date of first default and referral to collections
      t.date      :garnishments_on  # Date that collections agent referred to garnishments
      t.date      :written_off_on   # Date written off
      t.integer   :written_off_by
      t.string    :remark           # Remarks by underwriter
      t.integer   :garnishment_fax_attempts,      :null => false, :default => 0     # Set the number of fax attempts
      t.datetime  :garnishment_fax_confirmed_at  # Date/time that receipt of garnishment document packet by employer is confirmed.
      t.date      :garnishment_packet_sent_by_mail_on
      t.string    :garnishment_telephone_status
      t.date      :created_on # We need a date-only field for message template scheduling
      t.timestamps
    end

    foreign_key :loans, :customer_id, :customers
    foreign_key :loans, :portfolio_id, :portfolios
    add_index :loans, :signature_token, :unique => true
    add_index :loans, :defaulted_on
  end

  def self.down
    drop_table :loans
  end
end
