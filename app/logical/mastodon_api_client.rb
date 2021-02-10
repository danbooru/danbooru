class MastodonApiClient
  extend Memoist
  attr_reader :json

  def initialize(site_name, id)
    @site_name = site_name

    return if access_token.blank?

    begin
      @json = JSON.parse(access_token.get("/api/v1/statuses/#{id}").body)
    rescue StandardError
      @json = {}
    end
  end

  def profile_url
    json.dig("account", "url")
  end

  def account_name
    json.dig("account", "username")
  end

  def display_name
    json.dig("account", "display_name")
  end

  def account_id
    json.dig("account", "id")
  end

  def image_url
    image_urls.first
  end

  def image_urls
    json["media_attachments"].to_a.map {|x| x["url"]}
  end

  def tags
    json["tags"].to_a.map { |tag| [tag["name"], tag["url"]] }
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

  def fetch_access_token
    Cache.get("#{@site_name}-token") do
      result = client.client_credentials.get_token
      result.token
    end
  end

  def access_token
    return if client.blank?
    OAuth2::AccessToken.new(client, fetch_access_token)
  end

  def client
    case @site_name
    when "pawoo.net"
      client_id = Danbooru.config.pawoo_client_id
      client_secret = Danbooru.config.pawoo_client_secret
    when "baraag.net"
      client_id = Danbooru.config.baraag_client_id
      client_secret = Danbooru.config.baraag_client_secret
    end

    return unless client_id && client_secret

    OAuth2::Client.new(client_id, client_secret, :site => "https://#{@site_name}")
  end

  memoize :client
end
