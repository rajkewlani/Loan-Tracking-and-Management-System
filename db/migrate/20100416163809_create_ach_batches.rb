require 'migration_helpers'

class CreateAchBatches < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :ach_batches do |t|
      t.integer :ach_provider_id
      t.integer :credits
      t.decimal :credit_amount, :precision => 15, :scale => 2, :default => 0
      t.integer :debits
      t.decimal :debit_amount,  :precision => 15, :scale => 2, :default => 0
      t.string  :file_name
      t.text    :csv
      t.date    :batch_date
      t.timestamps
    end

    add_index :ach_batches, :created_at
    foreign_key :ach_batches, :ach_provider_id, :ach_providers
  end

  def self.down
    drop_table :ach_batches
  end
end
