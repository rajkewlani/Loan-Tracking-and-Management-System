class Location < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_presence_of :name, :ip_address
  validates_uniqueness_of :name
end
