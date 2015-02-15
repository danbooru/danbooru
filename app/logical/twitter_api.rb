class TwitterApi
  def client
    api_token = Cache.get("twitter-api-token")
    hoge = Twitter::Rest::Client.new do |config|
      config.consumer_key = Danbooru.config.twiter_api_key
      config.consumer_secret = Danbooru.config.twitter_api_secret
      config.bearer_token = api_token if api_token
    end
    Cache.put("twitter-api-token", hoge.bearer_token)
    hoge
  end
end
