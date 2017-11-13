class PostViewCountService
  def self.enabled?
    Danbooru.config.reportbooru_server.present?
  end

  def initialize
    if !PostViewCountService.enabled?
      raise NotImplementedError.new("the Reportbooru service isn't configured. Missed searches are not available.")
    end
  end

  def fetch_count(post_id)
    url = URI.parse("#{Danbooru.config.reportbooru_server}/post_views/#{post_id}")
    response = HTTParty.get(url, Danbooru.config.httparty_options.reverse_merge(timeout: 6))
    if response.success?
      return JSON.parse(response.body)
    else
      return nil
    end
  end

  def fetch_rank(date = Date.today)
    url = URI.parse("#{Danbooru.config.reportbooru_server}/post_views/rank?date=#{date}")
    response = HTTParty.get(url, Danbooru.config.httparty_options.reverse_merge(timeout: 6))
    if response.success?
      return JSON.parse(response.body)
    else
      return nil
    end
  rescue JSON::ParserError
    nil
  end

  def popular_posts(date = Date.today)
    ranking = fetch_rank(date) || []
    ranking.slice(0, 50).map {|x| Post.find(x[0])}
  end
end
