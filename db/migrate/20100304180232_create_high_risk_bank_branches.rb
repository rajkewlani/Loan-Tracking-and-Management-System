class CreateHighRiskBankBranches < ActiveRecord::Migration
  def self.up
    create_table :high_risk_bank_branches do |t|
      t.string      :aba_routing_number, :limit => 9, :null => false
      t.string      :name, :null => false
      t.timestamps
    end

    add_index :high_risk_bank_branches, :aba_routing_number, :unique => true
    add_index :high_risk_bank_branches, :name
  end

  def self.down
    drop_table :high_risk_bank_branches
  end
end
