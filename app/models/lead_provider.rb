class LeadProvider < ActiveRecord::Base
  belongs_to :lead_filter
  has_many :customers
  
  validates_presence_of :name, :username, :password, :lead_filter_id, :status
  validates_uniqueness_of :name
  validates_uniqueness_of :username
  validates_inclusion_of :status, :in => (0..2)
  
  STATUS_HASH = { 0 => "Testing", 1 => "Active", 2 => "Disabled" }
  
  def display_status
    STATUS_HASH[self.status]
  end
  
end
