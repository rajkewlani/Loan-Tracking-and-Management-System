require 'migration_helpers'

class CreatePaymentAccounts < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :payment_accounts do |t|
      t.integer :customer_id, :null => false
      t.integer :account_id, :null => false
      t.string  :account_type, :null => false
      t.string  :authnet_payment_profile_id
      t.timestamps
    end
    foreign_key :payment_accounts, :customer_id, :customers
  end

  def self.down
    drop_table :payment_accounts
  end
end
