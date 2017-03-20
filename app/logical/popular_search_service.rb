# queries reportbooru to find popular post searches
class PopularSearchService
  attr_reader :date, :scale

  def initialize(date, scale)
    @date = date
    @scale = scale
  end

  def each_search(limit = 100, &block)
    fetch_data.to_s.scan(/(.+?) (\d+)\.0\n/).slice(0, limit).each(&block)
  end

  def fetch_data
    dates = date.strftime("%Y-%m-%d")

    Cache.get("ps-#{scale}-#{dates}", 1.minute) do
      url = URI.parse("#{Danbooru.config.reportbooru_server}/hits/#{scale}?date=#{dates}")
      response = ""
      Net::HTTP.start(url.host, url.port, :use_ssl => url.is_a?(URI::HTTPS)) do |http|
        http.read_timeout = 1
        http.request_get(url.request_uri) do |res|
          if res.is_a?(Net::HTTPSuccess)
            response = res.body
          end
        end
      end
      response
    end.to_s.force_encoding("utf-8")
  end
end
