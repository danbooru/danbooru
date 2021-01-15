# frozen_string_literal: true

class ForumPostComponent < ApplicationComponent
  attr_reader :forum_post, :original_forum_post_id, :dtext_data, :moderation_reports, :current_user
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, :policy, to: :helpers

  with_collection_parameter :forum_post

  def initialize(forum_post:, original_forum_post_id: nil, dtext_data: nil, moderation_reports: [], current_user: User.anonymous)
    @forum_post = forum_post
    @original_forum_post_id = original_forum_post_id
    @dtext_data = dtext_data
    @moderation_reports = moderation_reports
    @current_user = current_user
  end

  def render?
    policy(forum_post).show_deleted?
  end
end
