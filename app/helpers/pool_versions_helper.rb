module PoolVersionsHelper
  def pool_version_diff(pool_version)
    html = ""

    html << pool_version.changes[:added_posts].map do |post_id|
      '<ins><a href="/posts/' + post_id.to_s + '">' + post_id.to_s + '</a></ins>'
    end.join(" ")

    html << " "

    html << pool_version.changes[:removed_posts].map do |post_id|
      '<del><a href="/posts/' + post_id.to_s + '">' + post_id.to_s + '</a></del>'
    end.join(" ")

    return html.html_safe
  end
end
