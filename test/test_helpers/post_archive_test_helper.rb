module PostArchiveTestHelper
  def mock_post_version_service!
    setup do
      PostVersion.stubs(:sqs_service).returns(MockPostSqsService.new)
    end
  end

  # Mirrors PostVersion.create_from_json in the archives service (https://github.com/danbooru/archives).
  class MockPostSqsService
    def send_message(msg, *_options)
      _, json = msg.split("\n")
      json = JSON.parse(json)
      updated_at = Time.zone.parse(json["updated_at"] || json["created_at"])
      tags = json["tags"].split

      previous = find_previous(json["post_id"], updated_at)
      subject = PostVersion.new(version: 1 + PostVersion.where(post_id: json["post_id"]).maximum(:version).to_i)

      if previous && previous.updater_id == json["updater_id"] && updated_at - previous.updated_at < 1.hour
        subject = previous
        previous = find_previous(previous.post_id, previous.updated_at)
      end

      subject.assign_attributes(
        post_id: json["post_id"],
        tags: tags.join(" "),
        added_tags: tags - (previous&.tag_array || []),
        removed_tags: (previous&.tag_array || []) - tags,
        updater_id: json["updater_id"],
        updated_at: updated_at,
        rating: json["rating"],
        rating_changed: previous.nil? || json["rating"] != previous.rating,
        parent_id: json["parent_id"],
        parent_changed: previous.nil? || json["parent_id"] != previous.parent_id,
        source: json["source"],
        source_changed: previous.nil? || json["source"] != previous.source,
      )
      # XXX change this to `save!` and fix tests that don't set current user.
      subject.save
    end

    def find_previous(post_id, updated_at)
      PostVersion.where(post_id: post_id).where(updated_at: ...updated_at).order(id: :desc).first
    end
  end
end
