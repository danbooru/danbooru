class CommentVote < ApplicationRecord
  class Error < StandardError; end

  belongs_to :comment
  belongs_to :user
  validates_presence_of :score
  validates_uniqueness_of :user_id, :scope => :comment_id, :message => "have already voted for this comment"
  validate :validate_comment_can_be_down_voted
  validates_inclusion_of :score, :in => [-1, 1], :message => "must be 1 or -1"

  def self.visible(user)
    if user.is_moderator?
      all
    elsif user.is_member?
      where(user: user)
    else
      none
    end
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :score)
    q.apply_default_order(params)
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

  def self.searchable_includes
    [:comment, :user]
  end

  def self.available_includes
    [:comment, :user]
  end
end
