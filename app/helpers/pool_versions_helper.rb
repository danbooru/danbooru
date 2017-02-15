module PoolVersionsHelper
  def pool_version_diff(pool_version, previous = nil, options = {})
    html = ""

    diff = pool_version.build_diff(previous)

    html << diff[:added_post_ids].map do |post_id|
      '<ins><a href="/posts/' + post_id.to_s + '">' + post_id.to_s + '</a></ins>'
    end.join(" ")

    html << " "

    html << diff[:removed_post_ids].map do |post_id|
      '<del><a href="/posts/' + post_id.to_s + '">' + post_id.to_s + '</a></del>'
    end.join(" ")

    return html.html_safe
  end
end
