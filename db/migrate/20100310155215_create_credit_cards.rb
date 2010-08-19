class CreateCreditCards < ActiveRecord::Migration
  def self.up
    create_table :credit_cards do |t|
      t.string  :card_type, :limit => 8, :null => false
      t.string  :encrypted_last_4_digits, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :credit_cards
  end
end
