class CreateAchTransactions < ActiveRecord::Migration
  def self.up
    create_table :ach_transactions do |t|
      t.integer :ach_batch_id
      t.integer :loan_id
      t.integer :store_id
      t.string  :company_name
      t.string  :sec
      t.string  :description
      t.string  :effective_date
      t.string  :individual
      t.string  :name
      t.string  :receiving_routing_number
      t.string  :receiving_account_number
      t.integer :transaction_code
      t.string  :amount
      t.string  :optional_1, :limit => 20
      t.string  :optional_2, :limit => 2
      t.string  :trace_number, :limit => 15
      t.string  :status_code, :limit => 1
      t.string  :reason, :limit => 30
      t.string  :corrective_information, :limit => 35
      t.timestamps
    end
  end

  def self.down
    drop_table :ach_transactions
  end
end
