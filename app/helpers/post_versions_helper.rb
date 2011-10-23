module PostVersionsHelper
  def post_version_diff(post_version)
    diff = post_version.diff(post_version.previous)
    html = []
    diff[:added_tags].each do |tag|
      html << '<ins>' + tag + '</ins>'
    end
    diff[:removed_tags].each do |tag|
      html << '<del>' + tag + '</del>'
    end
    diff[:unchanged_tags].each do |tag|
      html << '<span>' + tag + '</span>' unless tag =~ /^(?:rating|source):/
    end
    return html.join(" ").html_safe
  end
end
