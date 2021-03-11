class DiscordApiClient
  extend Memoist

  BASE_URL = "https://discord.com/api/v8"

  attr_reader :application_id, :guild_id, :bot_token, :http

  def initialize(application_id: Danbooru.config.discord_application_client_id, guild_id: Danbooru.config.discord_guild_id, bot_token: Danbooru.config.discord_bot_token, http: Danbooru::Http.new)
    @application_id = application_id
    @guild_id = guild_id
    @bot_token = bot_token
    @http = http
  end

  def register_slash_command(name:, description:, options: [])
    json = {
      name: name,
      description: description,
      options: options
    }

    post("/applications/#{application_id}/guilds/#{guild_id}/commands", json)
  end

  def get_channel(channel_id)
    get("/channels/#{channel_id}")
  end

  def me
    get("/users/@me")
  end

  def get(url)
    client.get("#{BASE_URL}/#{url}").parse
  end

  def post(url, data)
    client.post("#{BASE_URL}/#{url}", json: data).parse
  end

  def client
    headers = {
      "User-Agent": "#{Danbooru.config.canonical_app_name} (#{Danbooru.config.source_code_url}, 1.0)",
      "Authorization": "Bot #{bot_token}"
    }

    http.headers(headers)
  end

  memoize :client
end
