class BulkRevert
  BIG_QUERY_LIMIT = 5_000
  attr_reader :constraints

  class ConstraintTooGeneralError < Exception ; end

  def process
    ModAction.log("#{CurrentUser.name} processed bulk revert for #{constraints.inspect}")

    find_post_versions.order("updated_at, id").each do |version|
      version.undo!
    end
  end

  def initialize(constraints)
    @constraints = constraints
  end

  def preview
    @_preview ||= find_post_versions
  end

  def query_gbq(user_id, added_tags, removed_tags, min_version_id, max_version_id)
    GoogleBigQuery::PostVersion.new.find(user_id, added_tags, removed_tags, min_version_id, max_version_id, BIG_QUERY_LIMIT)
  end

  def find_post_versions
    q = PostArchive.where("true")

    if constraints[:user_name]
      constraints[:user_id] = User.find_by_name(constraints[:user_name]).try(:id)
    end

    if constraints[:user_id]
      q = q.where("post_versions.updater_id = ?", constraints[:user_id])
    end

    if constraints[:added_tags] || constraints[:removed_tags]
      hash = CityHash.hash64("#{constraints[:added_tags]} #{constraints{removed_tags}} #{constraints[:min_version_id]} #{constraints[:max_version_id]}").to_s(36)
      sub_ids = Cache.get("br/fpv/#{hash}", 300) do
        query_gbq(constraints[:user_id], constraints[:added_tags], constraints[:removed_tags], constraints[:min_version_id], constraints[:max_version_id])
      end

      if sub_ids.size >= BIG_QUERY_LIMIT
        raise ConstraintTooGeneralError.new
      end

      q = q.where("post_versions.id in (?)", sub_ids)
    end

    if constraints[:min_version_id].present?
      q = q.where("post_versions.id >= ?", constraints[:min_version_id])
    end

    if constraints[:max_version_id].present?
      q = q.where("post_versions.id <= ?", constraints[:max_version_id])
    end

    q
  end
end
