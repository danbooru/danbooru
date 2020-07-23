class PawooApiClient
  extend Memoist

  PROFILE1 = %r!\Ahttps?://pawoo\.net/web/accounts/(\d+)!
  PROFILE2 = %r!\Ahttps?://pawoo\.net/@([^/]+)!
  STATUS1 = %r!\Ahttps?://pawoo\.net/web/statuses/(\d+)!
  STATUS2 = %r!\Ahttps?://pawoo\.net/@.+?/([^/]+)!

  class MissingConfigurationError < StandardError; end

  class Account
    attr_reader :json

    def self.is_match?(url)
      if url =~ PROFILE1
        return $1
      end

      if url =~ PROFILE2
        return $1
      end

      false
    end

    def initialize(json)
      @json = json
    end

    def profile_url
      json["url"]
    end

    def account_name
      json["username"]
    end

    def image_url
      nil
    end

    def image_urls
      []
    end

    def tags
      []
    end

    def commentary
      nil
    end

    def to_h
      json
    end
  end

  class Status
    attr_reader :json

    def self.is_match?(url)
      if url =~ STATUS1
        return $1
      end

      if url =~ STATUS2
        return $1
      end

      false
    end

    def initialize(json)
      @json = json
    end

    def profile_url
      json["account"]["url"]
    end

    def account_name
      json["account"]["username"]
    end

    def image_url
      image_urls.first
    end

    def image_urls
      json["media_attachments"].map {|x| x["url"]}
    end

    def tags
      json["tags"].map { |tag| [tag["name"], tag["url"]] }
    end

    def commentary
      commentary = ""
      commentary << "<p>#{json["spoiler_text"]}</p>" if json["spoiler_text"].present?
      commentary << json["content"]
      commentary
    end

    def to_h
      json
    end
  end

  def get(url)
    if id = Status.is_match?(url)
      begin
        data = JSON.parse(access_token.get("/api/v1/statuses/#{id}").body)
      rescue
        data = {
          "account" => {},
          "media_attachments" => [],
          "tags" => [],
          "content" => "",
        }
      end
      return Status.new(data)
    end

    if id = Account.is_match?(url)
      begin
        data = JSON.parse(access_token.get("/api/v1/accounts/#{id}").body)
      rescue
        data = {}
      end
      Account.new(data)
    end
  end

  private

  def fetch_access_token
    raise MissingConfigurationError, "missing pawoo client id" if Danbooru.config.pawoo_client_id.nil?
    raise MissingConfigurationError, "missing pawoo client secret" if Danbooru.config.pawoo_client_secret.nil?

    Cache.get("pawoo-token") do
      result = client.client_credentials.get_token
      result.token
    end
  end

  def access_token
    OAuth2::AccessToken.new(client, fetch_access_token)
  end

  def client
    OAuth2::Client.new(Danbooru.config.pawoo_client_id, Danbooru.config.pawoo_client_secret, :site => "https://pawoo.net")
  end

  memoize :client
end
