class CommentVote < ApplicationRecord
  class Error < Exception ; end

  belongs_to :comment
  belongs_to :user
  before_validation :initialize_user, :on => :create
  validates_presence_of :user_id, :comment_id, :score
  validates_uniqueness_of :user_id, :scope => :comment_id, :message => "have already voted for this comment"
  validate :validate_user_can_vote
  validate :validate_comment_can_be_down_voted
  validates_inclusion_of :score, :in => [-1, 1], :message => "must be 1 or -1"

  def self.prune!
    where("created_at < ?", 14.days.ago).delete_all
  end

  def self.search(params)
    q = where("true")
    return q if params.blank?

    if params[:comment_id]
      q = q.where("comment_id = ?", params[:comment_id].to_i)
    end

    q
  end

  def validate_user_can_vote
    if !user.can_comment_vote?
      errors.add :base, "You cannot vote on more than 10 comments per hour"
      false
    else
      true
    end
  end

  def validate_comment_can_be_down_voted
    if is_positive? && comment.creator == CurrentUser.user
      errors.add :base, "You cannot upvote your own comments"
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
