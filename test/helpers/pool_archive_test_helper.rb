module PoolArchiveTestHelper
  def mock_pool_archive_service!
    mock_sqs_service = Class.new do
      def send_message(msg)
        _, json = msg.split(/\n/)
        json = JSON.parse(json)
        prev = PoolArchive.where(pool_id: json["pool_id"]).order("id desc").first
        if merge?(prev, json)
          prev.update_columns(json)
        else
          PoolArchive.create(json)
        end
      end

      def merge?(prev, json)
        prev && (prev.updater_id == json["updater_id"]) && (prev.updated_at >= 1.hour.ago)
      end
    end

    PoolArchive.stubs(:sqs_service).returns(mock_sqs_service.new)
  end

  def start_pool_archive_transaction
    PoolArchive.connection.begin_transaction joinable: false
  end

  def rollback_pool_archive_transaction
    PoolArchive.connection.rollback_transaction
  end
end
