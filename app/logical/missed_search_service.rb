# queries reportbooru to find missed post searches
class MissedSearchService
  def self.enabled?
    Danbooru.config.reportbooru_server.present?
  end

  def initialize
    if !MissedSearchService.enabled?
      raise NotImplementedError.new("the Reportbooru service isn't configured. Missed searches are not available.")
    end
  end

  def each_search(&block)
    fetch_data.scan(/(.+?) (\d+)\.0\n/).each(&block)
  end

  def fetch_data
    Cache.get("ms", 1.minute) do
      url = URI.parse("#{Danbooru.config.reportbooru_server}/missed_searches")
      response = HTTParty.get(url, Danbooru.config.httparty_options.reverse_merge(timeout: 6))
      if response.success?
        response = response.body
      else
        response = ""
      end
      response.force_encoding("utf-8")
    end
  end
end
