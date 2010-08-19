class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    # Determine who the owners of this comment are
    if comment.commentable_type == "Customer"
      customer = Customer.find(comment.commentable_id)
      if customer.underwriter_id && (customer.underwriter_id != comment.user_id)
        UserCommentNotification.create(
          :author_id => comment.user_id,
          :user_id => customer.underwriter_id,
          :comment_id => comment.id,
          :short_message => ActionController::Base.helpers.truncate(comment.comment, :length => 100)
        )
      end
    end
  end
  
end
