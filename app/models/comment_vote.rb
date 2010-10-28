class CommentVote < ActiveRecord::Base
  class Error < Exception ; end

  belongs_to :comment
  belongs_to :user
  before_validation :initialize_user, :on => :create
  validates_presence_of :user_id, :comment_id
  
  def self.prune!
    destroy_all(["created_at < ?", 14.days.ago])
  end
  
  def initialize_user
    self.user_id = CurrentUser.user.id
  end
end
