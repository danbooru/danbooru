module IqdbTestHelper
  def mock_iqdb_enable!
    Danbooru.config.stubs(:iqdb_url).returns("http://localhost:5588")
  end

  def mock_iqdb_matches(matches)
    mock_iqdb_enable!
    response = HTTP::Response.new(status: 200, body: matches.to_json, headers: { "Content-Type": "application/json" }, version: "1.1", request: nil)
    HTTP::Client.any_instance.stubs(:post).returns(response)
  end

  def mock_iqdb_remove_post!(post)
    mock_iqdb_enable!
    response = HTTP::Response.new(status: 200, body: "{}", headers: { "Content-Type": "application/json" }, version: "1.1", request: nil)
    HTTP::Client.any_instance.stubs(:delete).returns(response)
  end
end
