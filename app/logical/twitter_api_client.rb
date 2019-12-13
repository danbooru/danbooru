class TwitterApiClient
  extend Memoist

  attr_reader :api_key, :api_secret

  def initialize(api_key, api_secret)
    @api_key, @api_secret = api_key, api_secret
  end

  def bearer_token(token_expiry = 24.hours)
    http = Danbooru::Http.basic_auth(user: api_key, pass: api_secret)
    response = http.cache(token_expiry).post("https://api.twitter.com/oauth2/token", form: { grant_type: :client_credentials })
    response.parse["access_token"]
  end

  def client
    Danbooru::Http.auth("Bearer #{bearer_token}")
  end

  def status(id, cache: 1.minute)
    response = client.cache(cache).get("https://api.twitter.com/1.1/statuses/show.json?id=#{id}&tweet_mode=extended")
    response.parse.with_indifferent_access
  end

  memoize :bearer_token, :client
end
