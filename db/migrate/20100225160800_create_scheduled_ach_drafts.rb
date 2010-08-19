require 'migration_helpers'

class CreateScheduledAchDrafts < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :scheduled_ach_drafts do |t|
      t.integer   :loan_id, :null => false
      t.integer   :bank_account_id, :null => false
      t.date      :draft_date, :null => false
      t.decimal   :amount, :null => false
      t.decimal   :principal, :default => 0, :null => false
      t.decimal   :interest, :default => 0, :null => false
      t.decimal   :fees, :default => 0, :null => false
      t.timestamps
    end

    foreign_key :scheduled_ach_drafts, :loan_id, :loans
  end

  def self.down
    drop_table :scheduled_ach_drafts
  end
end
