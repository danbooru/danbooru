# frozen_string_literal: true

class CommentComponent < ApplicationComponent
  attr_reader :comment, :context, :dtext_data, :show_deleted, :current_user
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, :policy, to: :helpers

  def self.with_collection(comments, current_user:, **options)
    dtext_data = DText.preprocess(comments.map(&:body))
    # XXX
    #comments = comments.includes(:moderation_reports) if Pundit.policy!([current_user, nil], ModerationReport).show?

    super(comments, current_user: current_user, dtext_data: dtext_data, **options)
  end

  # XXX calls to pundit policy don't respect current_user.
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

  def has_moderation_reports?
    policy(ModerationReport).show? && comment.moderation_reports.present?
  end
end
