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
    Post.stubs(:iqdb_enabled?).returns(true)

    Danbooru.config.stubs(:iqdbs_server).returns("http://localhost:3004")
  end

  def mock_iqdb_matches(matches)
    Danbooru.config.stubs(:iqdbs_server).returns("http://localhost:3004")
    response = HTTP::Response.new(status: 200, body: matches.to_json, headers: { "Content-Type": "application/json" }, version: "1.1")
    HTTP::Client.any_instance.stubs(:post).returns(response)
  end
end
