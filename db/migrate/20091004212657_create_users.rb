require 'migration_helpers'

class CreateUsers < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    create_table  :users do |t|
      t.string    :role, :null => false
      t.string    :username, :null => false
      t.string    :email, :null => false
      t.string    :password_hash
      t.string    :password_salt
      t.boolean   :reset_password_at_next_login, :null => false, :default => false
      t.boolean   :login_suspended,              :null => false, :default => false
      t.string    :first_name, :null => false
      t.string    :last_name, :null => false
      t.string    :authorization_token
      t.integer   :team_id
      t.boolean   :manager, :null => false, :default => false
      t.boolean   :available, :null => false, :default => true
      t.datetime  :last_login_at
      t.string    :last_login_ip
      t.boolean   :logged_in, :null => false, :default => false
      t.timestamps
    end

    add_index :users, :username, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :authorization_token, :unique => true
    add_index :users, :team_id

    before_delete_trigger :users, "update reminders set user_id = null where user_id = OLD.id;update loans set underwriter_id = null where underwriter_id = OLD.id;update loans set collections_agent_id = null where collections_agent_id = OLD.id;update loans set garnishments_agent_id = null where garnishments_agent_id = OLD.id;"
  end
  
  def self.down
    drop_table :users
  end
end
