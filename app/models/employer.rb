class Employer < ActiveRecord::Base

  validates_presence_of :name, :country_code

  def before_save
    self.name_normalized = self.name.downcase
  end
end
