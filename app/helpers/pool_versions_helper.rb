module PoolVersionsHelper
  def pool_version_show_diff(pool_version)
    previous = pool_version.previous
    previous.present? && pool_version.description != previous.description
  end

  def pool_version_name_diff(pool_version)
    previous = pool_version.previous
    if previous.present? && (pool_version.name != previous.name)
      name_diff = diff_name_html(pool_version.pretty_name, previous.pretty_name)
      %(<br><br><b>Rename:</b><br>&ensp;#{name_diff}</p>).html_safe
    else
      ""
    end
  end

  def pool_version_post_diff(pool_version)
    previous = pool_version.previous
    diff = {}

    if previous.present?
      diff[:added_post_ids] = pool_version.post_ids - previous.post_ids
      diff[:removed_post_ids] = previous.post_ids - pool_version.post_ids
    else
      diff[:added_post_ids] = pool_version.added_post_ids
      diff[:removed_post_ids] = pool_version.removed_post_ids
    end

    render "pool_versions/diff", diff: diff
  end
end
