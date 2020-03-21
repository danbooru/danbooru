module PoolArchiveTestHelper
  def mock_pool_version_service!
    setup do
      PoolVersion.stubs(:sqs_service).returns(MockPoolSqsService.new)
      PoolVersion.establish_connection(PoolVersion.database_url)
      PoolVersion.connection.begin_transaction joinable: false
    end

    teardown do
      PoolVersion.connection.rollback_transaction
    end
  end

  class MockPoolSqsService
    def send_message(msg, *options)
      _, json = msg.split(/\n/)
      json = JSON.parse(json)
      prev = PoolVersion.where(pool_id: json["pool_id"]).order("id desc").first
      if merge?(prev, json)
        prev.update_columns(json)
      else
        PoolVersion.create!(json)
      end
    end

    def merge?(prev, json)
      prev && (prev.updater_id == json["updater_id"]) && (prev.updated_at >= 1.hour.ago)
    end
  end
end
