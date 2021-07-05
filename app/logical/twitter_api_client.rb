# A simple Twitter API client that can authenticate to Twitter and fetch tweets by ID.
# @see https://developer.twitter.com/en/docs/getting-started
class TwitterApiClient
  extend Memoist

  attr_reader :api_key, :api_secret

  # Create a Twitter API client
  # @param api_key [String] the Twitter API key
  # @param api_secret [String] the Twitter API secret
  def initialize(api_key, api_secret)
    @api_key, @api_secret = api_key, api_secret
  end

  # Authenticate to Twitter with an API key and secret and receive a bearer token in response.
  # @param token_expiry [Integer] the number of seconds to cache the token
  # @return [String] the Twitter bearer token
  # @see https://developer.twitter.com/en/docs/authentication/api-reference/token
  def bearer_token(token_expiry = 24.hours)
    http = Danbooru::Http.basic_auth(user: api_key, pass: api_secret)
    response = http.cache(token_expiry).post("https://api.twitter.com/oauth2/token", form: { grant_type: :client_credentials })
    response.parse["access_token"]
  end

  # @return [Danbooru::Http] the HTTP client to connect to Twitter with
  def client
    Danbooru::Http.auth("Bearer #{bearer_token}")
  end

  # Fetch a tweet by id.
  # @param id [Integer] the Twitter tweet id
  # @param cache [Integer] the number of seconds to cache the response
  # @return [Object] the tweet
  # @see https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-show-id
  def status(id, cache: 1.minute)
    response = client.cache(cache).get("https://api.twitter.com/1.1/statuses/show.json?id=#{id}&tweet_mode=extended")
    response.parse.with_indifferent_access
  end

  memoize :bearer_token, :client
end
