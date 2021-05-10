module PostArchiveTestHelper
  def mock_post_version_service!
    setup do
      PostVersion.stubs(:sqs_service).returns(MockPostSqsService.new)
      PostVersion.establish_connection(PostVersion.database_url)
      PostVersion.connection.begin_transaction joinable: false
    end

    teardown do
      PostVersion.connection.rollback_transaction
    end
  end

  class MockPostSqsService
    def send_message(msg, *options)
      _, json = msg.split(/\n/)
      json = JSON.parse(json)
      json.delete("created_at")
      json["version"] = 1 + PostVersion.where(post_id: json["post_id"]).count
      prev = PostVersion.where(post_id: json["post_id"]).order("id desc").first
      if prev
        json["added_tags"] = json["tags"].scan(/\S+/) - prev.tags.scan(/\S+/)
        json["removed_tags"] = prev.tags.scan(/\S+/) - json["tags"].scan(/\S+/)
      else
        json["added_tags"] = json["tags"].scan(/\S+/)
      end
      json["parent_changed"] = (prev.nil? || json.key?("parent_id") && prev.parent_id != json["parent_id"])
      json["source_changed"] = (prev.nil? || json.key?("source") && prev.source != json["source"])
      json["rating_changed"] = (prev.nil? || json.key?("rating") && prev.rating != json["rating"])
      if merge?(prev, json)
        prev.update_columns(json)
      else
        # XXX change this to `create!` and fix tests that don't set current user.
        PostVersion.create(json)
      end
    end

    def merge?(prev, json)
      prev && (prev.updater_id == json["updater_id"]) && (prev.updated_at >= 1.hour.ago)
    end
  end
end
