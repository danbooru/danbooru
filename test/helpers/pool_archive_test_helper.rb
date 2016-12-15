module PoolArchiveTestHelper
  def mock_pool_archive_service!
    mock_sqs_service = Class.new do
      def send_message(msg)
        _, json = msg.split(/\n/)
        json = JSON.parse(json)
        prev = PoolArchive.where(pool_id: json["pool_id"]).order("id desc").first
        if prev && prev.updater_ip_addr.to_s == json["updater_ip_addr"]
          prev.update_columns(json)
        else
          PoolArchive.create(json)
        end
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
