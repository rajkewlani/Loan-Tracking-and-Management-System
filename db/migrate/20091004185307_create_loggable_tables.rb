class CreateLoggableTables < ActiveRecord::Migration
  def self.up
    create_table "logs" do |t|
      t.text "message"
      t.integer "loggable_id"
      t.string "loggable_type"
      t.integer "user_id"
      t.string "group"
      t.integer "owner_id"
      t.string "owner_type"
      t.timestamps
    end
    create_table "log_details" do |t|
      t.integer "log_id"
      t.string "label"
      t.text "detail"
    end
    add_index :logs, :loggable_id
    add_index :logs, :loggable_type
    add_index :logs, :user_id
    add_index :logs, :owner_id
    add_index :logs, :owner_type
  end

  def self.down
    drop_table :logs
    drop_table :log_details
  end

end
