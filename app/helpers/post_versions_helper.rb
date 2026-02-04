# frozen_string_literal: true

module PostVersionsHelper
  def post_version_diff(post_version, type)
    return "" if type == "previous" && post_version.version == 1

    other = post_version.send(type)

    added_tags = post_version.added_tags.compact
    added_tags << "rating:#{post_version_value(post_version.rating)}" if post_version.rating_changed
    added_tags << "parent:#{post_version_value(post_version.parent_id)}" if post_version.parent_changed
    added_tags << "source:#{post_version_source(post_version.source)}" if post_version.source_changed
    added_tags << "published:#{post_version_time(post_version.published_at)}" if post_version.published_at_changed

    removed_tags = post_version.removed_tags.compact

    if type == "previous" || other.nil?
      obsolete_added_tags = []
      obsolete_removed_tags = []
    else
      other_tags = other.tags.split
      other_tags << "rating:#{post_version_value(other.rating)}"
      other_tags << "parent:#{post_version_value(other.parent_id)}"
      other_tags << "source:#{post_version_source(other.source)}"
      other_tags << "published:#{post_version_time(other.published_at)}"
      obsolete_added_tags = added_tags - other_tags
      obsolete_removed_tags = removed_tags & other_tags
    end
    html = '<span class="diff-list break-words">'.dup

    added_tags.each do |tag|
      obsolete_class = (obsolete_added_tags.include?(tag) ? "diff-obsolete" : "")
      html << %{<ins class="#{obsolete_class}">#{link_to tag, posts_path(tags: tag)}</ins> }
    end
    removed_tags.each do |tag|
      obsolete_class = (obsolete_removed_tags.include?(tag) ? "diff-obsolete" : "")
      html << %{<del class="#{obsolete_class}">#{link_to tag, posts_path(tags: tag)}</del> }
    end

    html << "</span>"
    html.html_safe
  end

  def post_version_field(post_version, field)
    if field == :published_at
      value = post_version_time(post_version.send(field))
      prefix = "published"
      title = "Published"
    else
      value = post_version_value(post_version.send(field))
      prefix = ((field == :parent_id) ? "parent" : field.to_s)
      title = field.to_s.titleize
    end
    search = "#{prefix}:#{value}"
    display = ((field == :rating) ? post_version.pretty_rating : value)
    %{<b>#{title}:</b> #{link_to(display, posts_path(:tags => search))}}.html_safe
  end

  def post_version_value(value)
    value.presence || "none"
  end

  def post_version_source(source)
    if source.blank?
      "none"
    elsif source =~ %r{\Ahttps?://}i
      source
    else
      # This turns non-web sources with spaces (e.g., "File provided by the artist") into a single clickable entity.
      %{"#{source}"}
    end
  end

  def post_version_time(time)
    time&.iso8601 || "none"
  end
end
