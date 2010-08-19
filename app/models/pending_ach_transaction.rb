class PendingAchTransaction < ActiveRecord::Base
  belongs_to :loan
end
