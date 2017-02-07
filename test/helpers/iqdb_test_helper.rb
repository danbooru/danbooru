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

    Danbooru.config.stubs(:iqdbs_auth_key).returns("hunter2")
    Danbooru.config.stubs(:iqdbs_server).returns("http://localhost:3004")
  end

  def mock_iqdb_matches!(post_or_source, matches)
    source = post_or_source.is_a?(Post) ? post_or_source.complete_preview_file_url : post_or_source
    url = "http://localhost:3004/similar?key=hunter2&url=#{CGI.escape source}&ref"
    body = matches.map { |post| { post_id: post.id } }.to_json

    FakeWeb.register_uri(:get, url, body: body)
  end
end
