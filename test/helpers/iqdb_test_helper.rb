module IqdbTestHelper
  def mock_iqdb_service!
    mock_sqs_service = Class.new do
      def initialize
        @commands = []
      end

      def commands
        @commands
      end

      def send_message(msg)
        @commands << msg.split(/\n/).first
      end
    end

    service = mock_sqs_service.new
    Post.stubs(:iqdb_sqs_service).returns(service)
  end
end
