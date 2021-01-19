# frozen_string_literal: true

class CommentComponent < ApplicationComponent
  attr_reader :comment, :context, :dtext_data, :current_user
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, to: :helpers

  def initialize(comment:, current_user:, context: nil, dtext_data: nil)
    @comment = comment
    @context = context
    @dtext_data = dtext_data
    @current_user = current_user
  end

  def dimmed?
    comment.is_deleted? || (!comment.is_sticky? && comment.score <= current_user.comment_threshold/2.0)
  end

  def thresholded?
    !comment.is_deleted? && !comment.is_sticky? && comment.score <= current_user.comment_threshold
  end

  def redact_deleted?
    comment.is_deleted? && !policy(comment).can_see_deleted?
  end

  def has_moderation_reports?
    policy(ModerationReport).show? && comment.moderation_reports.present?
  end
end
