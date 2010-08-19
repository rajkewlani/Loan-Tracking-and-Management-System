class CreateBankAccounts < ActiveRecord::Migration
  def self.up
    create_table :bank_accounts do |t|
      t.integer   :customer_id,                                 :null => false
      t.string    :bank_name,                 :limit => 30,     :null => false
      t.string    :bank_account_type,         :limit => 8,      :null => false
      t.string    :encrypted_bank_aba_number,                   :null => false
      t.string    :encrypted_bank_account_number,               :null => false
      t.integer   :months_at_bank,                              :null => false
      t.boolean   :bank_direct_deposit,                         :null => false
      t.string    :bank_address,              :limit => 30
      t.string    :bank_city,                 :limit => 30
      t.string    :bank_state,                :limit => 2
      t.string    :bank_zip,                  :limit => 5
      t.string    :bank_phone,                :limit => 10
      t.decimal   :bank_account_balance,                        :precision => 10, :scale => 2
      t.integer   :number_of_nsf,             :default => 0
      t.integer   :number_of_transactions,    :default => 0
      t.boolean   :funding_account,           :default => 0,    :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :bank_accounts
  end
end
