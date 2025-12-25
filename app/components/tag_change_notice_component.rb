# frozen_string_literal: true

class TagChangeNoticeComponent < ApplicationComponent
  extend Memoist

  attr_reader :tag, :current_user

  def initialize(tag:, current_user:)
    super
    @tag = tag
    @current_user = current_user
  end

  memoize def pending_burs
    return BulkUpdateRequest.none unless tag.present?
    BulkUpdateRequest.pending.where_array_includes_any(:tags, tag.name)
  end

  def bur_links_for_topic(forum_topic:, burs:)
    if burs.length > 1
      "topic ##{forum_topic.id}: \"#{forum_topic.title}\" (#{burs.map { |bur| link_to "forum ##{bur.forum_post.id}", bur.forum_post}.to_sentence})"
    else
      link_to "topic ##{forum_topic.id}: \"#{forum_topic.title}\"", burs.first.forum_post
    end
  end

  def render?
    !@current_user.is_anonymous? && @tag.present?
  end
end
