class CommentVote < ApplicationRecord
  class Error < StandardError; end

  belongs_to :comment
  belongs_to :user
  before_validation :initialize_user, :on => :create
  validates_presence_of :score
  validates_uniqueness_of :user_id, :scope => :comment_id, :message => "have already voted for this comment"
  validate :validate_user_can_vote
  validate :validate_comment_can_be_down_voted
  validates_inclusion_of :score, :in => [-1, 1], :message => "must be 1 or -1"

  def self.visible(user = CurrentUser.user)
    return all if user.is_admin?
    where(user: user)
  end

  def self.comment_matches(params)
    return all if params.blank?
    where(comment_id: Comment.search(params).reorder(nil).select(:id))
  end

  def self.search(params)
    q = super
    q = q.visible
    q = q.search_attributes(params, :comment_id, :user, :score)
    q = q.comment_matches(params[:comment])
    q.apply_default_order(params)
  end

  def validate_user_can_vote
    if !user.can_comment_vote?
      errors.add :base, "You cannot vote on more than 10 comments per hour"
    end
  end

  def validate_comment_can_be_down_voted
    if is_positive? && comment.creator == CurrentUser.user
      errors.add :base, "You cannot upvote your own comments"
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

  def self.available_includes
    [:comment, :user]
  end
end
