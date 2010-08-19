class CreateInvestors < ActiveRecord::Migration
  def self.up
    create_table  :investors do |t|
      t.string    :investor_name, :null => false # Login ID
      t.string    :first_name, :null => false
      t.string    :last_name, :null => false
      t.string    :email, :null => false
      t.string    :password_hash
      t.string    :password_salt
      t.string    :authorization_token
      t.datetime  :last_login_at
      t.string    :last_login_ip
      t.boolean   :logged_in, :null => false, :default => false
      t.timestamps
    end

    add_index :investors, :last_name
    add_index :investors, :email, :unique => true
    add_index :investors, :authorization_token, :unique => true
  end

  def self.down
    drop_table :investors
  end
end
