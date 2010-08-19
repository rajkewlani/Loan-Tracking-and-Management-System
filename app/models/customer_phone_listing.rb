class CustomerPhoneListing < ActiveRecord::Base
  belongs_to :customer
  validates_presence_of :customer_id, :phone
  validates_uniqueness_of :phone, :scope => [:customer_id]
end
