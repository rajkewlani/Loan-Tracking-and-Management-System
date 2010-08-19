class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string  :name, :null => false
      t.string  :code, :null => false
      t.float   :max_apr
      t.decimal :max_loan_amount
      t.integer :min_loan_days
      t.integer :max_loan_days
      t.integer :max_loans_per_year
      t.integer :max_extensions
      t.timestamps
    end

    add_index :countries, :code, :unique => true
  end

  def self.down
    drop_table :countries
  end
end
