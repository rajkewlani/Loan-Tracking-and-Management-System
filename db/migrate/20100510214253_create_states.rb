class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.integer :country_id => false
      t.string  :name, :null => false
      t.string  :code, :null => false
      t.float   :max_apr
      t.decimal :max_loan_amount
      t.integer :min_loan_days
      t.integer :max_loan_days
      t.integer :max_loans_per_year
      t.integer :max_extensions
      t.boolean :garnishment_allowed, :null => false, :default => true
      t.references :country
      t.timestamps
    end

    add_index :states, [:country_id, :code], :unique => true
  end

  def self.down
    drop_table :states
  end
end
