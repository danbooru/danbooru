module ReportbooruHelper
  def mock_request(url, method: :get, status: 200, body: nil, http: Danbooru::Http.any_instance, **options)
    response = HTTP::Response.new(status: status, body: body, version: "1.1")
    http.stubs(method).with(url, **options).returns(response)
  end

  def mock_post_search_rankings(date = Date.today, rankings)
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:1234")
    url = "http://localhost:1234/post_searches/rank?date=#{date}"
    mock_request(url, body: rankings.to_json)
  end

  def mock_missed_search_rankings(date = Date.today, rankings)
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:1234")
    url = "http://localhost:1234/missed_searches"
    data = rankings.map { _1.join(" ") }.join("\n")
    mock_request(url, body: data)
  end

  def mock_post_view_rankings(date = Date.today, rankings)
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:1234")
    url = "http://localhost:1234/post_views/rank?date=#{date}"
    mock_request(url, body: rankings.to_json)
  end
end
