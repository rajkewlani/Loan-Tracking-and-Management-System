class CreatePortfolios < ActiveRecord::Migration
  def self.up
    create_table :portfolios do |t|
      t.string  :name,                :null => false
      t.float   :apr,                 :null => false,                                   :default => 664.84
      t.decimal :max_loan_amount,     :null => false,   :precision => 15, :scale => 2,  :default => 500
      t.integer :min_loan_days,       :null => false,                                   :default => 3
      t.integer :max_loan_days,       :null => false,                                   :default => 84
      t.integer :max_extensions,      :null => false,                                   :default => 11
      t.integer :max_loans_per_year,  :null => false,                                   :default => 52
      t.string  :port_key,            :null => false # A nod to Harry Potter :)
      t.timestamps
    end

    add_index :portfolios, :created_at
    add_index :portfolios, :port_key
  end

  def self.down
    drop_table :portfolios
  end
end
