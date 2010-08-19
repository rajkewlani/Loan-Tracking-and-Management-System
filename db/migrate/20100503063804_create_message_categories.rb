class CreateMessageCategories < ActiveRecord::Migration
  def self.up
    create_table :message_categories do |t|
      t.string    :name
      t.string    :footer
      t.timestamps
    end
  end

  def self.down
    drop_table :message_categories
  end
end
