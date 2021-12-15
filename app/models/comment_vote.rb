# frozen_string_literal: true

class CommentVote < ApplicationRecord
  attr_accessor :updater

  belongs_to :comment
  belongs_to :user

  validate :validate_vote_is_unique, if: :is_deleted_changed?
  validates :score, inclusion: { in: [-1, 1], message: "must be 1 or -1" }

  before_save :update_score_on_delete_or_undelete, if: -> { !new_record? && is_deleted_changed? }
  before_create :update_score_on_create

  deletable

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
    q = search_attributes(params, :id, :created_at, :updated_at, :score, :is_deleted, :comment, :user)
    q.apply_default_order(params)
  end

  def is_positive?
    score == 1
  end

  def is_negative?
    score == -1
  end

  # allow duplicate deleted votes but not duplicate active votes
  def validate_vote_is_unique
    if !is_deleted? && CommentVote.active.where.not(id: id).exists?(comment_id: comment_id, user_id: user_id)
      errors.add(:user, "have already voted for this comment")
    end
  end

  def update_score_on_create
    comment.with_lock do
      comment.update_columns(score: comment.score + score)
    end
  end

  def update_score_on_delete_or_undelete
    comment.with_lock do
      if is_deleted_changed?(from: false, to: true)
        comment.update_columns(score: comment.score - score)

        if updater != user
          ModAction.log("#{updater.name} deleted comment vote ##{id} on comment ##{comment_id}", :comment_vote_delete, updater)
        end
      else
        comment.update_columns(score: comment.score + score)

        if updater != user
          ModAction.log("#{updater.name} undeleted comment vote ##{id} on comment ##{comment_id}", :comment_vote_undelete, updater)
        end
      end
    end
  end

  def self.available_includes
    [:comment, :user]
  end
end
