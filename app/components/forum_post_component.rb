# frozen_string_literal: true

class ForumPostComponent < ApplicationComponent
  attr_reader :forum_post, :original_forum_post_id, :dtext_references, :current_user

  delegate :link_to_user, :time_ago_in_words_tagged, :data_attributes_for, to: :helpers

  with_collection_parameter :forum_post

  def self.with_collection(forum_posts, forum_topic:, current_user:)
    dtext_references = DText.preprocess(forum_posts.map(&:body))
    original_forum_post_id = forum_topic.original_post&.id

    forum_posts = forum_posts.includes(:creator, :bulk_update_request)
    forum_posts = forum_posts.includes(:pending_moderation_reports) if Pundit.policy(current_user, ModerationReport).can_see_moderation_reports?

    super(forum_posts, dtext_references: dtext_references, original_forum_post_id: original_forum_post_id, current_user: current_user)
  end

  def initialize(forum_post:, original_forum_post_id: nil, dtext_references: DText.preprocess(forum_post.body), current_user: User.anonymous)
    super
    @forum_post = forum_post
    @original_forum_post_id = original_forum_post_id
    @dtext_references = dtext_references
    @current_user = current_user
  end

  def render?
    policy(forum_post).show_deleted?
  end

  def reported?
    policy(ModerationReport).can_see_moderation_reports? && forum_post.pending_moderation_reports.present?
  end
end
