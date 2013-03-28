module PostVersionsHelper
  def post_version_diff(post_version)
    diff = post_version.diff(post_version.previous)
    html = []
    diff[:added_tags].each do |tag|
      html << '<ins>+' + link_to(tag, posts_path(:tags => tag)) + '</ins>'
    end
    diff[:removed_tags].each do |tag|
      html << '<del>-' + link_to(tag, posts_path(:tags => tag)) + '</del>'
    end
    diff[:unchanged_tags].each do |tag|
      html << '<span>' + link_to(tag, posts_path(:tags => tag)) + '</span>'
    end
    return html.join(" ").html_safe
  end
end
