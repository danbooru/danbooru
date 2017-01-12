class PostArchive < ActiveRecord::Base
  def self.enabled?
    Danbooru.config.aws_sqs_archives_url.present?
  end

  establish_connection "archive_#{Rails.env}".to_sym if enabled?
  self.table_name = "post_versions"

  def self.calculate_version(post_id, updated_at, version_id)
    if updated_at.to_i == Time.zone.parse("2007-03-14T19:38:12Z").to_i
      # Old post versions which didn't have updated_at set correctly
      1 + PostVersion.where("post_id = ? and updated_at = ? and id < ?", post_id, updated_at, version_id).count
    else
      1 + PostVersion.where("post_id = ? and updated_at < ?", post_id, updated_at).count
    end
  end

  def self.export(version_id = 0)
    PostVersion.where("id > ?", version_id).find_each do |version|
      previous = version.previous
      tags = version.tags.scan(/\S+/)

      if previous
        prev_tags = previous.tags.scan(/\S+/)
        added_tags = tags - previous.tags.scan(/\S+/)
        removed_tags = previous.tags.scan(/\S+/) - tags
      else
        added_tags = tags
        removed_tags = []
      end

      rating_changed = previous.nil? || version.rating != previous.try(:rating)
      parent_changed = previous.nil? || version.parent_id != previous.try(:parent_id)
      source_changed = previous.nil? || version.source != previous.try(:source)
      create(
        post_id: version.post_id,
        tags: version.tags,
        added_tags: added_tags,
        removed_tags: removed_tags,
        updater_id: version.updater_id,
        updater_ip_addr: version.updater_ip_addr.to_s,
        updated_at: version.updated_at,
        version: calculate_version(version.post_id, version.updated_at, version.id),
        rating: version.rating,
        rating_changed: rating_changed,
        parent_id: version.parent_id,
        parent_changed: parent_changed,
        source: version.source,
        source_changed: source_changed
      )
      puts "inserted #{version.id}"
    end
  end
end
