require 'migration_helpers'

class CreateCustomerPhoneListings < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :customer_phone_listings do |t|
      t.integer :customer_id, :null => false
      t.string  :phone, :limit => 10, :null => false
      t.string  :owner
      t.string  :title
      t.string  :company
      t.string  :address
      t.string  :city
      t.string  :state, :limit => 2
      t.string  :zip, :limit => 20
      t.string  :line_type
      t.string  :provider
      t.timestamps
    end

    foreign_key :customer_phone_listings, :customer_id, :customers
  end

  def self.down
    drop_table :customer_phone_listings
  end
end
