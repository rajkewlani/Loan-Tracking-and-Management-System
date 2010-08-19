class CreateAchProviders < ActiveRecord::Migration
  def self.up
    create_table :ach_providers do |t|
      t.string  :name, :limit => 40, :null => false
      t.string  :login_id
      t.string  :origin_id
      t.string  :processing_email
      t.string  :support_email
      t.string  :support_phone
      # Flobridge employees that provider can contact with questions about batches
      t.string  :primary_contact_name
      t.string  :primary_contact_phone
      t.string  :primary_contact_email
      t.string  :alternate_contact_name
      t.string  :alternate_contact_phone
      t.string  :alternate_contact_email
      t.timestamps
    end
  end

  def self.down
    drop_table :ach_providers
  end
end
