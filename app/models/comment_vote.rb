class CommentVote < ActiveRecord::Base
  class Error < Exception ; end

  attr_accessor :is_positive
  validates_uniqueness_of :ip_addr, :scope => :comment_id
  belongs_to :comment
  belongs_to :user
  after_save :update_comment_score
  
  def self.prune!
    destroy_all(["created_at < ?", 14.days.ago])
  end
  
  def update_comment_score
    if is_positive
      comment.increment!(:score)
    else
      comment.decrement!(:score)
    end
  end
end
