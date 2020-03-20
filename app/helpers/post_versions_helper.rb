module PostVersionsHelper
  def post_version_diff(post_version, type)
    other = post_version.send(type)

    this_tags = post_version.tag_array
    this_tags << "rating:#{post_version.rating}" if post_version.rating.present?
    this_tags << "parent:#{post_version.parent_id}" if post_version.parent_id.present?
    this_tags << "source:#{post_version.source}" if post_version.source.present?

    other_tags = other.present? ? other.tag_array : []
    if other.present?
      other_tags << "rating:#{other.rating}" if other.rating.present?
      other_tags << "parent:#{other.parent_id}" if other.parent_id.present?
      other_tags << "source:#{other.source}" if other.source.present?
    elsif type == "subsequent"
      other_tags = this_tags
    end

    if type == "previous"
      added_tags = this_tags - other_tags
      removed_tags = other_tags - this_tags
    else
      added_tags = other_tags - this_tags
      removed_tags = this_tags - other_tags
    end
    unchanged_tags = this_tags & other_tags

    html = '<span class="diff-list">'

    added_tags.each do |tag|
      html << '<ins>+' + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</ins>'
      html << " "
    end
    removed_tags.each do |tag|
      html << '<del>-' + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</del>'
      html << " "
    end
    unchanged_tags.each do |tag|
      html << '<span>' + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</span>'
      html << " "
    end

    html << "</span>"
    html.html_safe
  end
end
