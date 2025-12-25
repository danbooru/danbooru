# frozen_string_literal: true

# The parent class for a Discord slash command. Each slash command handled by
# Danbooru is a subclass of this class. Subclasses should set the {#name},
# {#description}, and {#options} class attributes defining the slash command's
# parameters, then implement the {#call} method to return a response to the
# command.
#
# The lifecycle of a Discord slash command is this:
#
# * First we register the command with Discord with an API call ({DiscordApiClient#register_slash_command}).
# * Then whenever someone uses the command, Discord sends us a HTTP request to
#   https://danbooru.donmai.us/webhooks/receive.
# * We validate the request really came from Discord, then return the
#   command's response.
#
# @abstract
# @see DiscordApiClient
# @see WebhooksController#receive
# @see https://discord.com/developers/docs/interactions/slash-commands
class DiscordSlashCommand
  class WebhookVerificationError < StandardError; end

  # https://discord.com/developers/docs/interactions/slash-commands#interaction-interactiontype
  module InteractionType
    Ping = 1
    ApplicationCommand = 2
  end

  # https://discord.com/developers/docs/interactions/slash-commands#interaction-response-interactionresponsetype
  module InteractionResponseType
    Pong = 1
    ChannelMessageWithSource = 4
    DeferredChannelMessageWithSource = 5
  end

  # https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoptiontype
  module ApplicationCommandOptionType
    String = 3
    Integer = 4
    Boolean = 5
  end

  # The name of the slash command.
  class_attribute :name

  # A description of the slash command.
  class_attribute :description

  # The parameters of the slash command.
  # https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoption
  class_attribute :options, default: []

  attr_reader :data, :discord

  # `data` is the the interaction data sent to us by Discord for the command.
  # https://discord.com/developers/docs/interactions/slash-commands#interaction
  def initialize(data: {}, discord: DiscordApiClient.new)
    @data = data
    @discord = discord
  end

  # Should return the response to the command.
  def call
    # respond_with("message")
    raise NotImplementedError
  end

  concerning :HelperMethods do
    # @return [Hash] The parameters passed to the slash command by the Discord user.
    def params
      @params ||= data.dig(:data, :options).to_a.map do |opt|
        [opt[:name], opt[:value]]
      end.to_h.with_indifferent_access
    end

    # https://discord.com/developers/docs/interactions/slash-commands#responding-to-an-interaction
    # https://discord.com/developers/docs/interactions/slash-commands#interaction-response
    def respond_with(content = nil, type: InteractionResponseType::ChannelMessageWithSource, posts: [], **options)
      if posts.present?
        embeds = posts.map { |post| DiscordSlashCommand::PostEmbed.new(post, self).to_h }
        options[:embeds] = embeds
      end

      {
        type: type,
        data: {
          content: content,
          **options
        }
      }
    end

    # Post a response to the command later, after it's ready.
    # https://discord.com/developers/docs/interactions/slash-commands#interaction-response
    def respond_later(&block)
      create_deferred_followup(&block)
      trigger_typing_indicator
      respond_with(type: InteractionResponseType::DeferredChannelMessageWithSource)
    end

    def create_deferred_followup(&block)
      Thread.new do
        params = block.call
        create_followup_message(**params)
      rescue StandardError => e
        create_followup_message(content: "`Error: #{e.message}`")
      end
    end

    def get_channel_messages(**options)
      discord.get_channel_messages(data[:channel_id], **options)
    end

    def trigger_typing_indicator
      discord.trigger_typing_indicator(data[:channel_id])
    end

    def create_followup_message(**options)
      discord.create_followup_message(data[:token], **options)
    end

    def channel
      discord.get_channel(data[:channel_id], cache: 1.minute)
    end

    class_methods do
      # Register all commands with Discord.
      def register_slash_commands!
        slash_commands.values.each(&:register_slash_command!)
      end

      # Register the command with Discord (replacing it if it already exists).
      # https://discord.com/developers/docs/interactions/slash-commands#registering-a-command
      def register_slash_command!(discord: DiscordApiClient.new, guild_id: Danbooru.config.discord_guild_id)
        discord.register_slash_command(name: name, description: description, options: options, guild_id: guild_id)
      end

      def slash_commands
        {
          count: DiscordSlashCommand::CountCommand,
          posts: DiscordSlashCommand::PostsCommand,
          random: DiscordSlashCommand::RandomCommand,
          tagme: DiscordSlashCommand::TagmeCommand,
          time: DiscordSlashCommand::TimeCommand,
          wiki: DiscordSlashCommand::WikiCommand,
        }
      end
    end
  end

  concerning :WebhookMethods do
    class_methods do
      # Called when we receive a command from Discord. Instantiates a
      # DiscordSlashCommand and calls the `call` method.
      # https://discord.com/developers/docs/interactions/slash-commands#interaction
      def receive_webhook(request)
        data = verify_request!(request)

        case data[:type]
        when InteractionType::Ping
          { type: InteractionResponseType::Pong }
        when InteractionType::ApplicationCommand
          name = data.dig(:data, :name)
          klass = slash_commands.fetch(name&.to_sym)
          klass.new(data: data).call
        else
          raise NotImplementedError, "unknown Discord interaction type #{data[:type]}"
        end
      end

      # https://discord.com/developers/docs/interactions/slash-commands#security-and-authorization
      def verify_request!(request, public_key: Danbooru.config.discord_application_public_key)
        timestamp = request.headers["X-Signature-Timestamp"].to_s
        signature = request.headers["X-Signature-Ed25519"].to_s
        signature_bytes = [signature].pack("H*")

        body = request.body.read
        message = timestamp + body

        public_key_bytes = [public_key].pack("H*")
        verify_key = Ed25519::VerifyKey.new(public_key_bytes)

        verify_key.verify(signature_bytes, message)
        body.parse_json || {}
      rescue Ed25519::VerifyError
        raise WebhookVerificationError
      end
    end
  end
end
