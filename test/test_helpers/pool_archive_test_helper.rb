module PoolArchiveTestHelper
  def mock_pool_version_service!
    setup do
      PoolVersion.stubs(:sqs_service).returns(MockPoolSqsService.new)
    end
  end

  # Mirrors PoolVersion.create_from_json in the archives service (https://github.com/danbooru/archives).
  class MockPoolSqsService
    def send_message(msg, *_options)
      _, json = msg.split("\n")
      json = JSON.parse(json)
      updated_at = Time.zone.parse(json["updated_at"] || json["created_at"])

      previous = find_previous(json["pool_id"], updated_at)
      subject = PoolVersion.new(version: 1 + PoolVersion.where(pool_id: json["pool_id"]).maximum(:version).to_i)

      if previous && previous.updater_id == json["updater_id"] && updated_at - previous.updated_at < 1.hour
        subject = previous
        previous = find_previous(previous.pool_id, previous.updated_at)
      end

      subject.update!(
        **json.symbolize_keys,
        updated_at: updated_at,
        added_post_ids: json["post_ids"] - (previous&.post_ids || []),
        removed_post_ids: (previous&.post_ids || []) - json["post_ids"],
        description_changed: previous.nil? || json["description"] != previous.description,
        name_changed: previous.nil? || json["name"] != previous.name,
      )
    end

    def find_previous(pool_id, updated_at)
      PoolVersion.where(pool_id: pool_id).where(updated_at: ...updated_at).order(id: :desc).first
    end
  end
end
