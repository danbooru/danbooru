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
      forum_links = safe_join(burs.map.with_index { |bur, i| link_to "[#{i + 1}]", bur.forum_post }, ", ")
      topic_link = link_to(%{topic ##{forum_topic.id}: "#{forum_topic.title}"}, forum_topic)
      safe_join([topic_link, " (", forum_links, ")"])
    else
      link_to "topic ##{forum_topic.id}: \"#{forum_topic.title}\"", burs.first.forum_post
    end
  end

  def render?
    !@current_user.is_anonymous? && @tag.present?
  end
end
