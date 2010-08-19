require 'migration_helpers'

class CreateLoanTransactions < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :loan_transactions do |t|
      t.integer       :loan_id,   :null => false
      t.integer       :ach_batch_id
      t.string        :tran_type, :null => false
      t.decimal       :total,             :precision => 15, :scale => 2, :default => 0
      t.decimal       :principal,         :precision => 15, :scale => 2, :default => 0
      t.decimal       :interest,          :precision => 15, :scale => 2, :default => 0
      t.decimal       :fees,              :precision => 15, :scale => 2, :default => 0
      t.decimal       :recovery,          :precision => 15, :scale => 2, :default => 0
      t.decimal       :failed_total,      :precision => 15, :scale => 2, :default => 0
      t.boolean       :nsf,               :default => false, :null => false
      t.boolean       :account_closed,    :default => false, :null => false
      t.integer       :check_number
      t.string        :ach_return_code
      t.string        :ach_return_reason
      t.integer       :payment_account_id
      t.date          :new_due_date
      t.string        :memo
      t.timestamps
    end

    foreign_key :loan_transactions, :loan_id, :loans
  end

  def self.down
    drop_table :loan_transactions
  end
end
