module PoolVersionsHelper
  def pool_versions_listing_type
    params.dig(:search, :pool_id).present? ? :revert : :standard
  end

  def pool_version_status_diff(pool_version)
    cur = pool_version
    prev = pool_version.previous

    return "New" if prev.blank?

    status = []
    status += ["Renamed"] if cur.name != prev.name
    status += ["DescChanged"] if cur.description != prev.description
    status += ["Deleted"] if cur.is_deleted? && !prev.is_deleted?
    status += ["Undeleted"] if !cur.is_deleted? && prev.is_deleted?
    status += ["Activated"] if cur.is_active? && !prev.is_active?
    status += ["Deactivated"] if !cur.is_active? && prev.is_active?
    status.join(" ")
  end

  def pool_page_diff(pool_version, other_version)
    pattern = Regexp.new('(?:<.+?>)|(?:\w+)|(?:[ \t]+)|(?:\r?\n)|(?:.+?)')
    DiffBuilder.new(other_version.description, pool_version.description, pattern).build
  end
end