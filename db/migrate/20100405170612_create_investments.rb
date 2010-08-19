require 'migration_helpers'

class CreateInvestments < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :investments do |t|
      t.integer :investor_id, :null => false
      t.integer :portfolio_id, :null => false
      t.decimal :amount, :null => false,   :precision => 15, :scale => 2
      t.timestamps
    end

    foreign_key :investments, :investor_id, :investors
    foreign_key :investments, :portfolio_id, :portfolios
  end

  def self.down
    drop_table :investments
  end
end
