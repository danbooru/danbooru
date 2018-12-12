# queries reportbooru to find popular post searches
class PopularSearchService
  attr_reader :date

  def self.enabled?
    Danbooru.config.reportbooru_server.present?
  end

  def initialize(date)
    if !PopularSearchService.enabled?
      raise NotImplementedError.new("the Reportbooru service isn't configured. Popular searches are not available.")
    end

    @date = date
  end

  def each_search(limit = 100, &block)
    JSON.parse(fetch_data.to_s).slice(0, limit).each(&block)
  end

  def tags
    JSON.parse(fetch_data.to_s).map {|x| x[0]}
  end

  def fetch_data()
    return [] unless self.class.enabled?
    
    dates = date.strftime("%Y-%m-%d")

    data = Cache.get("ps-day-#{dates}", 1.minute) do
      url = "#{Danbooru.config.reportbooru_server}/post_searches/rank?date=#{dates}"
      response = HTTParty.get(url, Danbooru.config.httparty_options.reverse_merge(timeout: 3))
      if response.success?
        response = response.body
      else
        response = "[]"
      end
      response
    end.to_s.force_encoding("utf-8")

    if data.blank? || data == "[]"
      dates = date.yesterday.strftime("%Y-%m-%d")

      data = Cache.get("ps-day-#{dates}", 1.minute) do
        url = "#{Danbooru.config.reportbooru_server}/post_searches/rank?date=#{dates}"
        response = HTTParty.get(url, Danbooru.config.httparty_options.reverse_merge(timeout: 3))
        if response.success?
          response = response.body
        else
          response = "[]"
        end
        response
      end.to_s.force_encoding("utf-8")
    end

    data

  rescue => e
    Rails.logger.error(e.to_s)
    if defined?(NewRelic)
      NewRelic::Agent.notice_error(e)
    end
    return []
  end
end
