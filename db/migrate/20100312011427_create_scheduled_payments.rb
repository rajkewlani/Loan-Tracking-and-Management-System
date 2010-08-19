require 'migration_helpers'

class CreateScheduledPayments < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :scheduled_payments do |t|
      t.integer   :customer_id, :null => false
      t.integer   :loan_id, :null => false
      t.integer   :payment_account_id, :null => false
      t.date      :draft_date, :null => false
      t.decimal   :amount, :precision => 15, :scale => 2, :null => false
      t.decimal   :principal, :precision => 15, :scale => 2, :default => 0, :null => false
      t.decimal   :interest, :precision => 15, :scale => 2, :default => 0, :null => false
      t.decimal   :fees, :precision => 15, :scale => 2, :default => 0, :null => false
      t.date      :due_date_before_extension
      t.string    :aasm_state, :null => false
      t.boolean   :extension, :null => false, :default => false
      t.timestamps
    end

    add_index   :scheduled_payments, [:loan_id, :draft_date], :unique => true
    foreign_key :scheduled_payments, :loan_id, :loans
  end

  def self.down
    drop_table :scheduled_payments
  end
end
