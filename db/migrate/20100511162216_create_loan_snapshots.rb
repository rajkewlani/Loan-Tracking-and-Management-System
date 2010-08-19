class CreateLoanSnapshots < ActiveRecord::Migration
  def self.up
    create_table :loan_snapshots do |t|
      t.integer :loan_id,         :null => false
      t.decimal :principal_owed,  :null => false
      t.decimal :interest_owed,   :null => false
      t.decimal :fees_owed,       :null => false
      t.string  :aasm_state,      :null => false
      t.date    :created_on,      :null => false
      t.timestamps
    end

    add_index :loan_snapshots, :created_on
  end

  def self.down
    drop_table :loan_snapshots
  end
end
