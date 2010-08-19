require 'migration_helpers'

class CreateAchReturns < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table  :ach_returns do |t|
      t.integer   :ach_provider_id, :null => false
      t.string    :company_identifier
      t.string    :company_name
      t.string    :ee_date
      t.integer   :transaction_code
      t.string    :routing_number, :null => false
      t.string    :account_number, :null => false
      t.decimal   :amount, :null => false
      t.integer   :loan_id, :null => false
      t.string    :customer_name, :null => false
      t.string    :return_reason_code, :null => false
      t.string    :correction_info
      t.integer   :loan_transaction_id, :null => false
      t.datetime  :processed_at
      t.timestamps
    end

    foreign_key :ach_returns, :ach_provider_id, :ach_providers
    add_index   :ach_returns, :loan_id
    add_index   :ach_returns, :loan_transaction_id, :unique => true
    add_index   :ach_returns, :processed_at
  end

  def self.down
    drop_table :ach_returns
  end
end
