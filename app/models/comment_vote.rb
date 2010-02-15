class CommentVote < ActiveRecord::Base
  belongs_to :comment
  belongs_to :user
  
  def self.prune!
    destroy_all(["created_at < ?", 14.days.ago])
  end
end
