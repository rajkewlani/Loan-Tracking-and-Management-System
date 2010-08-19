class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.column :parent_id,  :integer
      t.column :customer_id,  :integer
      t.column :loan_id,  :integer
      t.column :owner_type, :string,    :default => 'Customer'
      t.column :description, :string
      t.column :content_type, :string
      t.column :filename, :string    
      t.column :thumbnail, :string 
      t.column :size, :integer
    end
  end

  def self.down
    drop_table :documents
  end
end
