class ReportbooruService
  attr_reader :http, :reportbooru_server

  def initialize(http: Danbooru::Http.new, reportbooru_server: Danbooru.config.reportbooru_server)
    @reportbooru_server = reportbooru_server
    @http = http.timeout(1)
  end

  def enabled?
    reportbooru_server.present?
  end

  def missed_search_rankings(expires_in: 1.minutes)
    return [] unless enabled?

    response = http.cache(expires_in).get("#{reportbooru_server}/missed_searches")
    return [] if response.status != 200

    body = response.to_s.force_encoding("utf-8")
    body.lines.map(&:split).map { [_1, _2.to_i] }
  end

  def post_search_rankings(date, expires_in: 1.minutes)
    request("#{reportbooru_server}/post_searches/rank?date=#{date}", expires_in)
  end

  def post_view_rankings(date, expires_in: 1.minutes)
    request("#{reportbooru_server}/post_views/rank?date=#{date}", expires_in)
  end

  def popular_searches(date, limit: 100, expires_in: 1.hour)
    ranking = post_search_rankings(date, expires_in: expires_in)
    ranking = post_search_rankings(date.yesterday, expires_in: expires_in) if ranking.blank?
    ranking.take(limit).map(&:first)
  end

  def popular_posts(date, limit: 100)
    ranking = post_view_rankings(date)
    ranking = post_view_rankings(date.yesterday) if ranking.blank?
    ranking.take(limit).map { |x| Post.find(x[0]) }
  end

  def request(url, expires_in)
    return [] unless enabled?

    response = http.cache(expires_in).get(url)
    return [] if response.status != 200
    JSON.parse(response.to_s.force_encoding("utf-8"))
  end
end
