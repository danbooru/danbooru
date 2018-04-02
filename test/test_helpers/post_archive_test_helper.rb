module PostArchiveTestHelper
  def setup
    super

    mock_post_archive_service!
    start_post_archive_transaction
  end

  def teardown
    super

    rollback_post_archive_transaction
  end

  def mock_post_archive_service!
    mock_sqs_service = Class.new do
      def send_message(msg, *options)
        _, json = msg.split(/\n/)
        json = JSON.parse(json)
        json.delete("created_at")
        json["version"] = 1 + PostArchive.where(post_id: json["post_id"]).count
        prev = PostArchive.where(post_id: json["post_id"]).order("id desc").first
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
          PostArchive.create(json)
        end
      end

      def merge?(prev, json)
        prev && (prev.updater_id == json["updater_id"]) && (prev.updated_at >= 1.hour.ago)
      end
    end

    PostArchive.stubs(:sqs_service).returns(mock_sqs_service.new)
  end

  def start_post_archive_transaction
    PostArchive.connection.begin_transaction joinable: false
  end

  def rollback_post_archive_transaction
    PostArchive.connection.rollback_transaction
  end
end
