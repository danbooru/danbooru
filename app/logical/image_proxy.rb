class ImageProxy
  def self.needs_proxy?(url)
    fake_referer_for(url).present?
  end

  def self.fake_referer_for(url)
    Sources::Site.new(url).strategy.try(:fake_referer)
  end

  def self.get_image(url)
    if url.blank?
      raise "Must specify url"
    end

    if !needs_proxy?(url)
      raise "Proxy not allowed for this site"
    end

    uri = URI.parse(url)
    headers = {
      "Referer" => fake_referer_for(url),
      "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
    }

    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.is_a?(URI::HTTPS)) do |http|
      resp = http.request_get(uri.request_uri, headers)
      if resp.is_a?(Net::HTTPSuccess)
        return resp
      else
        raise "HTTP error code: #{resp.code} #{resp.message}"
      end
    end
  end
end