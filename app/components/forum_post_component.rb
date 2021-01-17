# frozen_string_literal: true

class ForumPostComponent < ApplicationComponent
  attr_reader :forum_post, :original_forum_post_id, :dtext_data, :moderation_reports, :current_user
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, :policy, to: :helpers

  with_collection_parameter :forum_post

  def self.with_collection(forum_posts, forum_topic:, current_user:)
    dtext_data = DText.preprocess(forum_posts.map(&:body))
    original_forum_post_id = forum_topic.original_post&.id

    forum_posts = forum_posts.includes(:creator, :bulk_update_request)
    forum_posts = forum_posts.includes(:moderation_reports) if Pundit.policy!(current_user, ModerationReport).show?

    super(forum_posts, dtext_data: dtext_data, original_forum_post_id: original_forum_post_id, current_user: current_user)
  end

  def initialize(forum_post:, original_forum_post_id: nil, dtext_data: nil, current_user: User.anonymous)
    @forum_post = forum_post
    @original_forum_post_id = original_forum_post_id
    @dtext_data = dtext_data
    @current_user = current_user
  end

  def render?
    policy(forum_post).show_deleted?
  end

  def has_moderation_reports?
    policy(ModerationReport).show? && forum_post.moderation_reports.present?
  end
end
