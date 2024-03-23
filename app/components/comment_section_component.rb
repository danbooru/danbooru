# frozen_string_literal: true

class CommentSectionComponent < ApplicationComponent
  attr_reader :post, :comments, :current_user, :limit, :dtext_references

  def initialize(post:, current_user:, limit: nil)
    super
    @post = post
    @current_user = current_user
    @limit = limit

    @comments = @post.comments.order(id: :asc)
    @comments = @comments.includes(:creator)
    @comments = @comments.includes(:active_votes) if !current_user.is_anonymous?
    @comments = @comments.includes(:pending_moderation_reports) if policy(ModerationReport).can_see_moderation_reports?
    @comments = @comments.last(limit) if limit.present?

    @dtext_references = DText.preprocess(@comments.map(&:body))
  end

  def has_unloaded_comments?
    unloaded_comment_count > 0
  end

  def unloaded_comment_count
    return 0 if limit.nil?
    [post.comments.size - limit, 0].max
  end
end
