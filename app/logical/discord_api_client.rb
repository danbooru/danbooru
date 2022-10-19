# frozen_string_literal: true

# A Discord API Client.
#
# @see https://discord.com/developers/docs/intro
class DiscordApiClient
  extend Memoist

  BASE_URL = "https://discord.com/api/v8"

  # https://discord.com/developers/docs/resources/webhook#execute-webhook
  # Actual limit is 2000; use 1950 for headroom.
  MAX_MESSAGE_LENGTH = 1950

  attr_reader :application_id, :bot_token, :http

  def initialize(application_id: Danbooru.config.discord_application_client_id, bot_token: Danbooru.config.discord_bot_token, http: Danbooru::Http.external)
    @application_id = application_id
    @bot_token = bot_token
    @http = http
  end

  # https://discord.com/developers/docs/interactions/slash-commands#registering-a-command
  # https://discord.com/developers/docs/interactions/slash-commands#create-global-application-command
  # https://discord.com/developers/docs/interactions/slash-commands#create-guild-application-command
  def register_slash_command(name:, description:, options: [], guild_id: nil)
    json = {
      name: name,
      description: description,
      options: options
    }

    if guild_id.present?
      post("/applications/#{application_id}/guilds/#{guild_id}/commands", json)
    else
      post("/applications/#{application_id}/commands", json)
    end
  end

  # https://discord.com/developers/docs/interactions/slash-commands#create-followup-message
  def create_followup_message(interaction_token, allowed_mentions: { parse: [] }, **options)
    post("/webhooks/#{application_id}/#{interaction_token}", {
      allowed_mentions: allowed_mentions,
      **options
    })
  end

  # https://discord.com/developers/docs/resources/channel#get-channel
  def get_channel(channel_id, **options)
    get("/channels/#{channel_id}", **options)
  end

  def get_channel_messages(channel_id, limit: 50, **options)
    get("/channels/#{channel_id}/messages", params: { limit: limit }, **options)
  end

  # https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
  def trigger_typing_indicator(channel_id)
    post("/channels/#{channel_id}/typing")
  end

  # https://discord.com/developers/docs/resources/user#get-current-user
  def get_current_user(**options)
    get("/users/@me", **options)
  end

  def get(url, cache: nil, **options)
    if cache
      client.cache(cache).get("#{BASE_URL}/#{url}", **options).parse
    else
      client.get("#{BASE_URL}/#{url}", **options).parse
    end
  end

  def post(url, data = {})
    client.post("#{BASE_URL}/#{url}", json: data).parse
  end

  def http_headers
    {
      "User-Agent": "#{Danbooru.config.canonical_app_name} (#{Danbooru.config.source_code_url}, 1.0)",
      "Authorization": "Bot #{bot_token}"
    }
  end

  def client
    http.headers(http_headers)
  end

  memoize :client, :http_headers
end
