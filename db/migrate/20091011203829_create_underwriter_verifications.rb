require 'migration_helpers'

class CreateUnderwriterVerifications < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :underwriter_verifications do |t|
      t.integer :customer_id, :null => false
      t.integer :underwriter_id, :null => false
      t.string  :verification_type, :null => false
      t.text    :notes
      t.integer :status, :default => 0
      t.timestamps
    end
    foreign_key :underwriter_verifications, :customer_id, :customers
  end

  def self.down
    drop_table :underwriter_verifications
  end
end
