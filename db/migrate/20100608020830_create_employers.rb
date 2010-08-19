class CreateEmployers < ActiveRecord::Migration
  def self.up
    create_table :employers do |t|
      t.string  :name, :null => false, :limit => 30
      t.string  :name_normalized, :null => false
      t.string  :state_code
      t.string  :country_code, :null => false
      t.boolean :will_garnish, :null => false, :default => false
      t.timestamps
    end

    add_index :employers, [:name_normalized,:state_code]
  end

  def self.down
    drop_table :employers
  end
end
