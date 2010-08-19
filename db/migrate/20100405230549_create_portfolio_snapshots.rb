require 'migration_helpers'

class CreatePortfolioSnapshots < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :portfolio_snapshots do |t|
      t.integer :portfolio_id, :null => false
      t.integer :new_loans_today, :null => false
      t.integer :reloans_today, :null => false
      t.integer :total_loans_today, :null => false
      t.float   :reloan_percentage, :null => false # (reloans.to_f / loans.to_f) * 100.0
      t.integer :loans_out_today, :null => false
      t.integer :total_loans_to_date, :null => false
      t.date    :snapshot_on, :null => false # Same as created_at but date only for easier selection/reporting
      t.timestamps
    end

    foreign_key :portfolio_snapshots, :portfolio_id, :portfolios
    add_index :portfolio_snapshots, :snapshot_on
  end

  def self.down
    drop_table :portfolio_snapshots
  end
end
