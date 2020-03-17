module PoolVersionsHelper
  def pool_version_show_diff(pool_version, type)
    other = pool_version.send(type)
    other.present? && pool_version.description != other.description
  end

  def pool_version_name_diff(pool_version, type)
    other = pool_version.send(type)
    if other.present? && (pool_version.name != other.name)
      if type == "previous"
        name_diff = diff_name_html(pool_version.name, other.name)
      else
        name_diff = diff_name_html(other.name, pool_version.name)
      end
      %(<br><br><b>Rename:</b><br>&ensp;#{name_diff}</p>).html_safe
    else
      ""
    end
  end

  def pool_version_post_diff(pool_version, type)
    other = pool_version.send(type)
    diff = {}

    if other.present? && type == "previous"
      diff[:added_post_ids] = pool_version.post_ids - other.post_ids
      diff[:removed_post_ids] = other.post_ids - pool_version.post_ids
    elsif other.present?
      diff[:added_post_ids] = other.post_ids - pool_version.post_ids
      diff[:removed_post_ids] = pool_version.post_ids - other.post_ids
    elsif type == "previous"
      diff[:added_post_ids] = pool_version.added_post_ids
      diff[:removed_post_ids] = pool_version.removed_post_ids
    else
      return ""
    end

    render "pool_versions/diff", diff: diff
  end
end
