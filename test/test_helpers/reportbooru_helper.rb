module ReportbooruHelper
  def mock_popular_search_service!
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:3003")
    stub_request(:get, "http://localhost:3003/hits/month?date=#{Date.today}").to_return(body: "kantai_collection 1000.0\ntouhou 500.0")
    stub_request(:get, "http://localhost:3003/hits/day?date=#{Date.today}").to_return(body: "kantai_collection 1000.0\ntouhou 500.0")
  end

  def mock_missed_search_service!
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:3003")
    stub_request(:get, "http://localhost:3003/missed_searches").to_return(body: "kantai_collection 1000.0\ntouhou 500.0")
  end
end
