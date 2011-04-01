class CommentVote < ActiveRecord::Base
  class Error < Exception ; end

  belongs_to :comment
  belongs_to :user
  before_validation :initialize_user, :on => :create
  validates_presence_of :user_id, :comment_id, :score
  validates_uniqueness_of :user_id, :scope => :comment_id
  validate :validate_user_can_vote
  validate :validate_comment_can_be_down_voted
  validates_inclusion_of :score, :in => [-1, 1], :message => "must be 1 or -1"
  
  def self.prune!
    destroy_all(["created_at < ?", 14.days.ago])
  end
  
  def validate_user_can_vote
    if !user.can_comment_vote?
      errors.add :user, "can not comment vote"
      false
    else
      true
    end
  end
  
  def validate_comment_can_be_down_voted
    if is_negative? && comment.creator.is_janitor? 
      errors.add :user, "can not downvote a janitor comment"
      false
    else
      true
    end
  end
  
  def is_positive?
    score == 1
  end
  
  def is_negative?
    score == -1
  end
  
  def initialize_user
    self.user_id = CurrentUser.user.id
  end
end
