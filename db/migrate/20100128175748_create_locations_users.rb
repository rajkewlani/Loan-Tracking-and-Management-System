require 'migration_helpers'

class CreateLocationsUsers < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :locations_users, :id => false do |t|
      t.column :location_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end

    add_index :locations_users, [:location_id, :user_id], :unique => true

    foreign_key(:locations_users, :location_id, :locations)
    foreign_key(:locations_users, :user_id, :users)
  end

  def self.down
    drop_table :locations_users
  end
end
