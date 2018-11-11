class TwitterService
  class Error < Exception ; end
  extend Memoist

  def enabled?
    Danbooru.config.twitter_api_key.present? && Danbooru.config.twitter_api_secret.present?
  end

  def client
    raise Error, "Twitter API keys not set" if !enabled?

    rest_client = ::Twitter::REST::Client.new do |config|
      config.consumer_key = Danbooru.config.twitter_api_key
      config.consumer_secret = Danbooru.config.twitter_api_secret
      if bearer_token = Cache.get("twitter-api-token")
        config.bearer_token = bearer_token
      end
    end

    Cache.put("twitter-api-token", rest_client.bearer_token)

    rest_client
  end
  memoize :client

  def status(id, options = {})
    Cache.get("twitterapi:#{id}", 60) do
      client.status(id, options)      
    end
  end

  def extract_urls_for_status(tweet)
    tweet.media.map do |obj|
      if obj.is_a?(Twitter::Media::Photo)
        obj.media_url_https.to_s + ":orig"
      elsif obj.is_a?(Twitter::Media::Video)
        video = obj.video_info.variants.select do |x|
          x.content_type == "video/mp4"
        end.max_by {|y| y.bitrate}
        if video
          video.url.to_s
        end
      end
    end.compact.uniq
  end

  def extract_og_image_from_page(url)
    resp = HTTParty.get(url, Danbooru.config.httparty_options)
    if resp.success?
      doc = Nokogiri::HTML(resp.body)
      images = doc.css("meta[property='og:image']")
      return images.first.attr("content").sub(":large", ":orig")
    end
  end

  def extract_urls_for_card(attrs)
    urls = attrs.urls.map {|x| x.expanded_url}
    url = urls.reject {|x| x.host == "twitter.com"}.first
    if url.nil?
      url = urls.first
    end
    [extract_og_image_from_page(url)].compact
  end

  def image_urls(tweet)
    if tweet.media.any?
      extract_urls_for_status(tweet)
    elsif tweet.urls.any?
      extract_urls_for_card(tweet)
    else
      []
    end
  end
end
