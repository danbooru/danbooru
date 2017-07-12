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

    headers = {
      "Referer" => fake_referer_for(url),
      "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
    }
    response = HTTParty.get(url, Danbooru.config.httparty_options.merge(headers: headers))
    if response.success?
      return response
    else
      raise "HTTP error code: #{response.code} #{response.message}"
    end
  end
end
