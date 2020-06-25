class ImageProxy
  class Error < StandardError; end

  def self.needs_proxy?(url)
    fake_referer_for(url).present?
  end

  def self.fake_referer_for(url)
    Sources::Strategies.find(url).headers["Referer"]
  end

  def self.get_image(url)
    raise Error, "URL not present" unless url.present?
    raise Error, "Proxy not allowed for this url (url=#{url})" unless needs_proxy?(url)

    referer = fake_referer_for(url)
    response = Danbooru::Http.timeout(30).headers(Referer: referer).get(url)
    raise Error, "Couldn't proxy image (code=#{response.status}, url=#{url})" unless response.status.success?

    response
  end
end
