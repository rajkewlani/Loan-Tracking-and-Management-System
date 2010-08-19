require 'migration_helpers'

class CreateReminders < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :reminders do |t|
      t.integer :loan_id,   :null => false
      t.integer :user_id
      t.date    :remind_on, :null => false
      t.string  :comment,   :null => false
      t.timestamps
    end

    foreign_key :reminders, :loan_id, :loans
  end

  def self.down
    drop_table :reminders
  end
end
