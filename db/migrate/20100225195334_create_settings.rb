class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.float   :apr,                           :default => 664.84, :null => false
      t.integer :max_new_customer_credit_limit, :default => 300,    :null => false
      t.integer :max_credit_limit,              :default => 1500,   :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
