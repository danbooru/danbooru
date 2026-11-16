# frozen_string_literal: true

class CommentSectionComponent < ApplicationComponent
  attr_reader :post, :comments, :comment_count, :current_user, :limit, :dtext_references

  # @param comments [Array<Comment>, nil] The comments to show. Loaded here if nil.
  # @param comment_count [Integer, nil] The post's total number of comments, if `comments` is given with a limit.
  def initialize(post:, current_user:, limit: nil, comments: nil, comment_count: nil)
    super
    @post = post
    @current_user = current_user
    @limit = limit
    @comment_count = comment_count
    @comments = comments || self.class.comments_for(post.comments, current_user: current_user)
    @comments = @comments.last(limit) if comments.nil? && limit.present?
    @dtext_references = DText.preprocess(@comments.map(&:body))
  end

  # Build the comment sections for many posts at once, loading their comments and comment counts in one query each
  # instead of one per post.
  # @return [Hash<Integer, CommentSectionComponent>] The comment section for each post, keyed by post id.
  def self.for_posts(posts, limit:, current_user:)
    comments = Comment.where(post: posts)
    comments_by_post_id = comments_for(comments.last_per_post(limit), current_user: current_user).group_by(&:post_id)
    comment_counts = comments.group(:post_id).count

    posts.to_h do |post|
      [post.id, new(post: post, current_user: current_user, limit: limit, comments: comments_by_post_id.fetch(post.id, []), comment_count: comment_counts.fetch(post.id, 0))]
    end
  end

  # @param comments [ActiveRecord::Relation<Comment>] The comments to load.
  # @return [ActiveRecord::Relation<Comment>] The comments in order, with what the comment components need preloaded.
  def self.comments_for(comments, current_user:)
    comments = comments.order(id: :asc).includes(:creator, :updater)
    comments = comments.includes(:active_votes) if !current_user.is_anonymous?
    comments = comments.includes(:pending_moderation_reports) if Pundit.policy(current_user, ModerationReport).can_see_moderation_reports?
    comments
  end

  def has_unloaded_comments?
    unloaded_comment_count > 0
  end

  def unloaded_comment_count
    return 0 if limit.nil?
    [(comment_count || post.comments.size) - limit, 0].max
  end
end
