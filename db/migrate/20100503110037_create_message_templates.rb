class CreateMessageTemplates < ActiveRecord::Migration
  def self.up
    create_table :message_templates do |t|
      t.string  :name
      t.references :message_category
      t.boolean :enabled,             :null => false, :default => false
      t.string  :content_type,        :null => false
      t.string  :subject
      t.text    :email_body
      t.text    :sms_body
      t.string  :description
      t.string  :msg_event
      t.string  :send_schedule_flag,  :null => false
      t.integer :days
      t.string  :before_after
      t.string  :base_date
      t.integer :send_hour
      t.string  :required_aasm_state # Specify an aasm_state that a loan must be in for this template to be sent.
      # Role Limitations
      t.boolean :underwriting, :null => false, :default => false
      t.boolean :collections,  :null => false, :default => false
      t.boolean :garnishments, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :message_templates
  end
end
