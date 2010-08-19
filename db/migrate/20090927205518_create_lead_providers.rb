class CreateLeadProviders < ActiveRecord::Migration
  def self.up
    create_table :lead_providers do |t|
      t.string :name, :null => false
      t.string :username, :null => false
      t.string :password, :null => false
      t.integer :lead_filter_id, :null => false
      t.integer :status, :default => 0, :null => false
      t.string :primary_contact
      t.string :primary_contact_email
      t.string :primary_contact_phone
      t.timestamps
    end
  end

  def self.down
    drop_table :lead_providers
  end
end
