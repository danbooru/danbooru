# frozen_string_literal: true

class CommentComponent < ApplicationComponent
  attr_reader :comment, :context, :dtext_data, :moderation_reports, :show_deleted, :current_user
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, :policy, to: :helpers

  def initialize(comment:, context: nil, dtext_data: nil, moderation_reports: [], show_deleted: false, current_user: User.anonymous)
    @comment = comment
    @context = context
    @dtext_data = dtext_data
    @moderation_reports = moderation_reports
    @show_deleted = show_deleted
    @current_user = current_user
  end

  def render?
    !comment.is_deleted? || show_deleted || current_user.is_moderator?
  end
end
