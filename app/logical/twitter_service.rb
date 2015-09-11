class TwitterService
  def client
    raise "Twitter API keys not set" if Danbooru.config.twitter_api_key.nil?

    @client ||= begin
      rest_client = Twitter::REST::Client.new do |config|
        config.consumer_key = Danbooru.config.twitter_api_key
        config.consumer_secret = Danbooru.config.twitter_api_secret
        if bearer_token = Cache.get("twitter-api-token")
          config.bearer_token = bearer_token
        end
      end

      Cache.put("twitter-api-token", rest_client.bearer_token)

      rest_client
    end
  end

  def image_urls(tweet_url)
    tweet_url =~ %r{/status/(\d+)}
    twitter_id = $1
    attrs = client.status(twitter_id).attrs
    urls = []
    attrs[:entities][:media].each do |obj|
      urls << obj[:media_url] + ":orig"
    end
    attrs[:extended_entities][:media].each do |obj|
      if obj[:video_info]
        largest = obj[:video_info][:variants].select {|x| x[:url] =~ /\.mp4$/}.max_by {|x| x[:bitrate]}
        urls.clear
        urls << largest[:url] if largest
      else
        urls << obj[:media_url] + ":orig"
      end
    end
    urls.uniq
  rescue
    []
  end
end
