module PostVersionsHelper
  def post_version_diff(post_version)
    previous = post_version.previous
    post = post_version.post

    if post.nil?
      latest_tags = post_version.tag_array
    else
      latest_tags = post.tag_array
      latest_tags << "rating:#{post.rating}" if post.rating.present?
      latest_tags << "parent:#{post.parent_id}" if post.parent_id.present?
      latest_tags << "source:#{post.source}" if post.source.present?
    end

    new_tags = post_version.tag_array
    new_tags << "rating:#{post_version.rating}" if post_version.rating.present?
    new_tags << "parent:#{post_version.parent_id}" if post_version.parent_id.present?
    new_tags << "source:#{post_version.source}" if post_version.source.present?

    old_tags = previous.present? ? previous.tag_array : []
    if previous.present?
      old_tags << "rating:#{previous.rating}" if previous.rating.present?
      old_tags << "parent:#{previous.parent_id}" if previous.parent_id.present?
      old_tags << "source:#{previous.source}" if previous.source.present?
    end

    added_tags = new_tags - old_tags
    removed_tags = old_tags - new_tags
    obsolete_added_tags = added_tags - latest_tags,
    obsolete_removed_tags = removed_tags & latest_tags,
    unchanged_tags = new_tags & old_tags

    html = '<span class="diff-list">'

    added_tags.each do |tag|
      prefix = obsolete_added_tags.include?(tag) ? '+<ins class="obsolete">' : '<ins>+'
      html << prefix + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</ins>'
      html << " "
    end
    removed_tags.each do |tag|
      prefix = obsolete_removed_tags.include?(tag) ? '-<del class="obsolete">' : '<del>-'
      html << prefix + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</del>'
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
