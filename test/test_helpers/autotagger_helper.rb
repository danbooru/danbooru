module AutotaggerHelper
  def mock_autotagger_evaluate(tags, http: Danbooru::Http.any_instance)
    tags.keys.each { |name| create(:tag, name: name) }

    Danbooru.config.stubs(:autotagger_url).returns("http://localhost:5000")
    body = [{ filename: "test.jpg", tags: tags }]

    response = HTTP::Response.new(status: 200, body: body.to_json, version: "1.1", request: nil, headers: { "Content-Type": "application/json" })
    http.stubs(:post).with("http://localhost:5000/evaluate", anything).returns(response)
  end
end
