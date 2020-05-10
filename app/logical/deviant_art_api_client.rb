# Authentication is via OAuth2 with the client credentials grant. Register a
# new app at https://www.deviantart.com/developers/ to obtain a client_id and
# client_secret. The app doesn't need to be published.
#
# API requests must send a user agent and must use gzip compression, otherwise
# 403 errors will be returned.
#
# API calls operate on UUIDs. The deviation ID in the URL is not the UUID. UUIDs
# are obtained by scraping the HTML page for the <meta property="da:appurl"> element.
#
# * https://www.deviantart.com/developers/
# * https://www.deviantart.com/developers/authentication
# * https://www.deviantart.com/developers/errors
# * https://www.deviantart.com/developers/http/v1/20160316

class DeviantArtApiClient
  class Error < StandardError; end
  BASE_URL = "https://www.deviantart.com/api/v1/oauth2/"

  attr_reader :client_id, :client_secret

  def initialize(client_id, client_secret)
    @client_id, @client_secret = client_id, client_secret
  end

  # https://www.deviantart.com/developers/http/v1/20160316/deviation_single/bcc296bdf3b5e40636825a942a514816
  def deviation(uuid)
    request("deviation/#{uuid}")
  end

  # https://www.deviantart.com/developers/http/v1/20160316/deviation_download/bed6982b88949bdb08b52cd6763fcafd
  def download(uuid, mature_content: "1")
    request("deviation/download/#{uuid}", mature_content: mature_content)
  end

  # https://www.deviantart.com/developers/http/v1/20160316/deviation_metadata/7824fc14d6fba6acbacca1cf38c24158
  def metadata(*uuids, mature_content: "1", ext_submission: "1", ext_camera: "1", ext_stats: "1")
    params = {
      deviationids: uuids.flatten,
      mature_content: mature_content,
      ext_submission: ext_submission,
      ext_camera: ext_camera,
      ext_stats: ext_stats
    }

    request("deviation/metadata", **params)
  end

  def request(url, **params)
    params = { access_token: access_token.token, **params }

    url = URI.join(BASE_URL, url).to_s
    response = Danbooru::Http.cache(1.minute).get(url, params: params)
    response.parse.with_indifferent_access
  end

  def oauth
    OAuth2::Client.new(client_id, client_secret, site: "https://www.deviantart.com", token_url: "/oauth2/token")
  end

  def access_token
    @access_token = oauth.client_credentials.get_token if @access_token.nil? || @access_token.expired?
    @access_token
  end

  def access_token=(hash)
    @access_token = OAuth2::AccessToken.from_hash(oauth, hash)
  end
end
