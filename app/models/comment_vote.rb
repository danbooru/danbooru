class CommentVote < ApplicationRecord
  belongs_to :comment
  belongs_to :user

  validates_presence_of :score
  validates_uniqueness_of :user_id, :scope => :comment_id, :message => "have already voted for this comment"
  validates_inclusion_of :score, :in => [-1, 1], :message => "must be 1 or -1"

  after_create :update_score_after_create
  after_destroy :update_score_after_destroy

  def self.visible(user)
    if user.is_moderator?
      all
    elsif user.is_anonymous?
      none
    else
      where(user: user)
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :score, :comment, :user)
    q.apply_default_order(params)
  end

  def is_positive?
    score == 1
  end

  def is_negative?
    score == -1
  end

  def update_score_after_create
    comment.with_lock do
      comment.update_columns(score: comment.score + score)
    end
  end

  def update_score_after_destroy
    comment.with_lock do
      comment.update_columns(score: comment.score - score)
    end
  end

  def self.available_includes
    [:comment, :user]
  end
end
