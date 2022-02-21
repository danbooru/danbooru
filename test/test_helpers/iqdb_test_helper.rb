module IqdbTestHelper
  def mock_iqdb_matches(matches)
    Danbooru.config.stubs(:iqdb_url).returns("http://localhost:5588")
    response = HTTP::Response.new(status: 200, body: matches.to_json, headers: { "Content-Type": "application/json" }, version: "1.1", request: nil)
    HTTP::Client.any_instance.stubs(:post).returns(response)
  end
end
