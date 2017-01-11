class PostArchive < ActiveRecord::Base
  def self.enabled?
    Danbooru.config.aws_sqs_archives_url.present?
  end

  establish_connection "archive_#{Rails.env}".to_sym if enabled?
  self.table_name = "post_versions"

  def self.calculate_version(post_id, updated_at)
    1 + PostVersion.where("post_id = ? and updated_at <= ?", post_id, updated_at).count
  end

  def self.export(version_id = 0)
    PostVersion.where("id > version_id").find_each do |version|
      previous = version.previous
      tags = version.tags.scan(/\S+/)

      if previous
        added_tags = tags - previous.tags
        removed_tags = previous.tags - tags
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
        created_at: version.created_at,
        updated_at: version.updated_at,
        version: calculate_version(version.post_id, version.updated_at),
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
