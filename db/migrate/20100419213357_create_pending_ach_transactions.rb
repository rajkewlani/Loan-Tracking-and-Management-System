require 'migration_helpers'

class CreatePendingAchTransactions < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :pending_ach_transactions do |t|
      t.integer :loan_id
      t.integer :store_id
      t.string  :company_name
      t.string  :sec
      t.string  :description
      t.date    :effective_date
      t.string  :individual
      t.string  :name
      t.string  :receiving_routing_number
      t.string  :receiving_account_number
      t.integer :transaction_code
      t.string  :amount
      t.string  :optional_1, :limit => 20
      t.string  :optional_2, :limit => 2
      t.string  :trace_number, :limit => 15
      t.timestamps
    end

    foreign_key :pending_ach_transactions, :loan_id, :loans
  end

  def self.down
    drop_table :pending_ach_transactions
  end
end
