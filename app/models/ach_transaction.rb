class AchTransaction < ActiveRecord::Base

  belongs_to :ach_batch
end
