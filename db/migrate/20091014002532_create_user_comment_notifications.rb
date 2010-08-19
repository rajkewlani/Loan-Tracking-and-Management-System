require 'migration_helpers'

class CreateUserCommentNotifications < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table :user_comment_notifications do |t|
      t.integer :author_id, :null => false
      t.integer :user_id, :null => false
      t.integer :comment_id, :null => false
      t.string :short_message
      t.boolean :mark_as_read, :default => false
      t.timestamps
    end

    foreign_key :user_comment_notifications, :comment_id, :comments
    foreign_key :user_comment_notifications, :user_id, :users
  end

  def self.down
    drop_table :user_comment_notifications
  end
end
