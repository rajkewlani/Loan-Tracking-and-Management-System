class UserCommentNotification < ActiveRecord::Base
  validates_presence_of :author_id, :user_id, :comment_id
  
  def author_name
    if self.author_id > 0
      user = User.find(self.author_id)
      if user
        return user.full_name
      else
        return "Unknown"
      end
    else
      return "System"
    end
  end
  
  def comment
    @comment ||= Comment.find(self.comment_id)
  end
  
end
