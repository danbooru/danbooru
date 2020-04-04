module PostVersionsHelper
  def post_version_diff(post_version, type)
    return "" if type == "previous" && post_version.version == 1

    other = post_version.send(type)

    added_tags = post_version.added_tags
    added_tags << "rating:#{post_version_value(post_version.rating)}" if post_version.rating_changed
    added_tags << "parent:#{post_version_value(post_version.parent_id)}" if post_version.parent_changed
    added_tags << "source:#{post_version_value(post_version.source)}" if post_version.source_changed

    removed_tags = post_version.removed_tags

    if type == "previous" || other.nil?
      obsolete_added_tags = []
      obsolete_removed_tags = []
    else
      other_tags = other.tags.split
      other_tags << "rating:#{post_version_value(other.rating)}"
      other_tags << "parent:#{post_version_value(other.parent_id)}"
      other_tags << "source:#{post_version_value(other.source)}"
      obsolete_added_tags = added_tags - other_tags
      obsolete_removed_tags = removed_tags & other_tags
    end
    html = '<span class="diff-list">'

    added_tags.each do |tag|
      obsolete_class = (obsolete_added_tags.include?(tag) ? "diff-obsolete" : "");
      html << %(<ins class="#{obsolete_class}">#{link_to(wordbreakify(tag), posts_path(:tags => tag))}</ins> )
    end
    removed_tags.each do |tag|
      obsolete_class = (obsolete_removed_tags.include?(tag) ? "diff-obsolete" : "");
      html << %(<del class="#{obsolete_class}">#{link_to(wordbreakify(tag), posts_path(:tags => tag))}</del> )
    end

    html << "</span>"
    html.html_safe
  end

  def post_version_field(post_version, field)
    value = post_version_value(post_version.send(field))
    prefix = (field == :parent_id ? "parent" : field.to_s)
    search = prefix + ":" + value.to_s
    display = (field == :rating ? post_version.pretty_rating : value)
    %(<b>#{field.to_s.titleize}:</b> #{link_to(display, posts_path(:tags => search))}).html_safe
  end

  def post_version_value(value)
    return (value.present? ? value : "none")
  end
end
