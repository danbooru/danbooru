module PoolVersionsHelper
  def pool_version_diff(pool_version)
    html = ""

    html << pool_version.added_post_ids.map do |post_id|
      '<ins><a href="/posts/' + post_id.to_s + '">' + post_id.to_s + '</a></ins>'
    end.join(" ")

    html << " "

    html << pool_version.removed_post_ids.map do |post_id|
      '<del><a href="/posts/' + post_id.to_s + '">' + post_id.to_s + '</a></del>'
    end.join(" ")

    if pool_version.description_changed?
      html << '<ins>desc:' + h(pool_version.description) + '</ins> '
      html << '<del>desc:' + h(pool_version.previous.description) + '</del> '
    end

    return html.html_safe
  end
end
