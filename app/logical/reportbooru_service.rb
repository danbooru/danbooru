class ReportbooruService
  attr_reader :http, :reportbooru_server

  def initialize(http: Danbooru::Http.new, reportbooru_server: Danbooru.config.reportbooru_server)
    @reportbooru_server = reportbooru_server
    @http = http
  end

  def enabled?
    reportbooru_server.present?
  end

  def missed_search_rankings(expires_in: 1.minutes)
    raise NotImplementedError, "Reportbooru not configured, missed searches not available." unless enabled?

    response = http.cache(expires_in).get("#{reportbooru_server}/missed_searches")
    return [] if response.status != 200

    body = response.to_s.force_encoding("utf-8")
    body.lines.map(&:split).map { [_1, _2.to_i] }
  end

  def post_search_rankings(date = Date.today, expires_in: 1.minutes)
    raise NotImplementedError, "Reportbooru not configured, popular searches not available." unless enabled?

    response = http.cache(expires_in).get("#{reportbooru_server}/post_searches/rank?date=#{date}")
    return [] if response.status != 200
    JSON.parse(response.to_s.force_encoding("utf-8"))
  end

  def post_view_rankings(date = Date.today, expires_in: 1.minutes)
    raise NotImplementedError, "Reportbooru not configured, post views not available." unless enabled?

    response = http.get("#{reportbooru_server}/post_views/rank?date=#{date}")
    return [] if response.status != 200
    JSON.parse(response.to_s.force_encoding("utf-8"))
  end

  def popular_searches(date = Date.today, limit: 100)
    ranking = post_search_rankings(date)
    ranking = post_search_rankings(date.yesterday) if ranking.blank?
    ranking.take(limit).map(&:first)
  end

  def popular_posts(date = Date.today, limit: 100)
    ranking = post_view_rankings(date)
    ranking.take(limit).map { |x| Post.find(x[0]) }
  end
end
