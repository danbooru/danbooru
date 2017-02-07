module ReportbooruHelper
  def mock_popular_search_service!
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:3003")
    FakeWeb.register_uri(:get, "http://localhost:3003/hits/month?date=#{Date.today}", body: "kantai_collection 1000.0\ntouhou 500.0")
    FakeWeb.register_uri(:get, "http://localhost:3003/hits/day?date=#{Date.today}", body: "kantai_collection 1000.0\ntouhou 500.0")
  end

  def mock_missed_search_service!
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:3003")
    FakeWeb.register_uri(:get, "http://localhost:3003/missed_searches", body: "kantai_collection 1000.0\ntouhou 500.0")
  end
end
