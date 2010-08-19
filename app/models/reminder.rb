class Reminder < ActiveRecord::Base

  belongs_to :loan
  belongs_to :user
  acts_as_loggable
  
  validates_presence_of :loan_id, :remind_on, :comment

  named_scope :today, :conditions => ["remind_on = ?", Date.today]
end
