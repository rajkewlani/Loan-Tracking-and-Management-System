class Team < ActiveRecord::Base
  has_many :users

  validates_presence_of :name, :role
  
  ROLES = ['underwriter', 'collections','garnishments']
  
end
