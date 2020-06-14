class PostViewCountService
  attr_reader :http, :reportbooru_server

  def initialize(http: Danbooru::Http.new, reportbooru_server: Danbooru.config.reportbooru_server)
    @reportbooru_server = reportbooru_server
    @http = http
  end

  def enabled?
    reportbooru_server.present?
  end

  def fetch_rank(date = Date.today)
    raise NotImplementedError, "Reportbooru not configured, post views not available." unless enabled?

    response = http.get("#{reportbooru_server}/post_views/rank?date=#{date}")
    return [] if response.status != 200
    JSON.parse(response.to_s)
  end

  def popular_posts(date = Date.today)
    ranking = fetch_rank(date)
    ranking.slice(0, 50).map {|x| Post.find(x[0])}
  end
end
