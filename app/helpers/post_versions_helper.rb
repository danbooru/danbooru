module PostVersionsHelper
  def post_version_diff(post_version)
    diff = post_version.diff(post_version.previous)
    html = '<span class="diff-list">'

    diff[:added_tags].each do |tag|
      prefix = diff[:obsolete_added_tags].include?(tag) ? '+<ins class="obsolete">' : '<ins>+'
      html << prefix + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</ins>'
      html << " "
    end
    diff[:removed_tags].each do |tag|
      prefix = diff[:obsolete_removed_tags].include?(tag) ? '-<del class="obsolete">' : '<del>-'
      html << prefix + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</del>'
      html << " "
    end
    diff[:unchanged_tags].each do |tag|
      html << '<span>' + link_to(wordbreakify(tag), posts_path(:tags => tag)) + '</span>'
      html << " "
    end

    html << "</span>"
    html.html_safe
  end
end
