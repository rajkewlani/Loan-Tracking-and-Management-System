require 'migration_helpers'

class CreateFactorTrusts < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :factor_trusts do |t|
      t.integer :customer_id, :null => false
      t.text    :response_xml
      t.timestamps
    end
    add_index :factor_trusts, :customer_id
    foreign_key :factor_trusts, :customer_id, :customers
  end

  def self.down
    drop_table :factor_trusts
  end
end
