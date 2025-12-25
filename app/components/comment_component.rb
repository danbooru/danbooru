# frozen_string_literal: true

class CommentComponent < ApplicationComponent
  attr_reader :comment, :context, :classes, :dtext_references, :current_user

  def initialize(comment:, current_user:, context: nil, classes: nil, dtext_references: DText.preprocess(comment.body))
    super
    @comment = comment
    @context = context
    @classes = classes
    @dtext_references = dtext_references
    @current_user = current_user
  end

  def dimmed?
    comment.is_deleted? || (!comment.is_sticky? && comment.score <= current_user.comment_threshold / 2.0)
  end

  def thresholded?
    !comment.is_deleted? && !comment.is_sticky? && comment.score <= current_user.comment_threshold
  end

  def can_see_creator?
    policy(comment).can_see_creator?
  end

  def redact_deleted?
    comment.is_deleted? && !policy(comment).can_see_deleted?
  end

  def votable?
    !comment.is_deleted? || current_user.is_moderator?
  end

  def upvoted?
    return false if current_user.is_anonymous?
    !!current_vote&.is_positive?
  end

  def downvoted?
    return false if current_user.is_anonymous?
    !!current_vote&.is_negative?
  end

  def current_vote
    @current_vote ||= comment.active_votes.find { |v| v.user_id == current_user.id }
  end

  def reported?
    policy(ModerationReport).can_see_moderation_reports? && comment.pending_moderation_reports.present?
  end

  def component_state
    { component: { classes: classes, context: context }}
  end
end
