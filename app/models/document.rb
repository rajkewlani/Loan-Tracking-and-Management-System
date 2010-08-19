class Document < ActiveRecord::Base
  
  belongs_to :docs, :polymorphic => true
  
  has_attachment :storage => :s3, 
                 :max_size => 500.kilobytes,
                 :resize_to => '320x200>',
                 :thumbnails => { :thumb => '100x100>' }

  validates_as_attachment
end
