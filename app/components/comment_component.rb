# frozen_string_literal: true

class CommentComponent < ApplicationComponent
  attr_reader :comment, :context, :dtext_data, :show_deleted, :current_user
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, to: :helpers

  def initialize(comment:, current_user:, context: nil, dtext_data: nil, show_deleted: false)
    @comment = comment
    @context = context
    @dtext_data = dtext_data
    @show_deleted = show_deleted
    @current_user = current_user
  end

  def render?
    !comment.is_deleted? || show_deleted || current_user.is_moderator?
  end

  def dimmed?
    !comment.is_sticky? && comment.score < current_user.comment_threshold/2.0
  end

  def thresholded?
    !comment.is_sticky? && comment.score < current_user.comment_threshold
  end

  def has_moderation_reports?
    policy(ModerationReport).show? && comment.moderation_reports.present?
  end
end
