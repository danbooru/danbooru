class BulkRevert
  attr_reader :constraints

  def initialize(constraints)
    @constraints = constraints
  end

  def preview
    @_preview ||= find_post_versions
  end

  def find_post_versions
    q = PostVersion.where("true")

    if constraints[:user_name]
      constraints[:user_id] = User.find_by_name(constraints[:user_name]).try(:id)
    end

    if constraints[:user_id]
      q = q.where("post_versions.updater_id = ?", constraints[:user_id])

      if constraints[:added_tags] || constraints[:removed_tags]
        hash = CityHash.hash64("#{constraints[:added_tags]} #{constraints{removed_tags}}").to_s(36)
        sub_ids = Cache.get("br/fpv/#{hash}", 300) do
          sub_ids = GoogleBigQuery::PostVersion.new.find(constraints[:user_id], constraints[:added_tags], constraints[:removed_tags])
        end
        q = q.where("post_versions.id in (?)", sub_ids)
      end
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
