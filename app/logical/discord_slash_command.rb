class DiscordSlashCommand
  class WebhookVerificationError < StandardError; end

  COMMANDS = {
    count: DiscordSlashCommand::CountCommand,
    posts: DiscordSlashCommand::PostsCommand,
    random: DiscordSlashCommand::RandomCommand,
    time: DiscordSlashCommand::TimeCommand,
    wiki: DiscordSlashCommand::WikiCommand,
  }

  # https://discord.com/developers/docs/interactions/slash-commands#interaction-interactiontype
  module InteractionType
    Ping = 1
    ApplicationCommand = 2
  end

  # https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoptiontype
  module ApplicationCommandOptionType
    String = 3
    Integer = 4
  end

  attr_reader :data, :discord

  # `data` is the the interaction data sent to us by Discord for the command.
  # https://discord.com/developers/docs/interactions/slash-commands#interaction
  def initialize(data: {}, discord: DiscordApiClient.new)
    @data = data
    @discord = discord
  end

  # The name of the slash command.
  def name
    raise NotImplementedError
  end

  # A description of the slash command.
  def description
    raise NotImplementedError
  end

  # The parameters of the slash command.
  # https://discord.com/developers/docs/interactions/slash-commands#applicationcommandoption
  def options
    []
  end

  # Should return the response to the command.
  def call
    # respond_with("message")
    raise NotImplementedError
  end

  concerning :HelperMethods do
    # The parameters passed to the command. A hash.
    def params
      @params ||= data.dig(:data, :options).to_a.map do |opt|
        [opt[:name], opt[:value]]
      end.to_h.with_indifferent_access
    end

    # https://discord.com/developers/docs/interactions/slash-commands#responding-to-an-interaction
    # https://discord.com/developers/docs/interactions/slash-commands#interaction-response
    def respond_with(content = nil, type: 4, posts: [], **options)
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

    def channel
      discord.get_channel(data[:channel_id], cache: 1.minute)
    end

    # Register the command with the Discord API (replacing it if it already exists).
    # https://discord.com/developers/docs/interactions/slash-commands#registering-a-command
    def register_slash_command
      discord.register_slash_command(name: name, description: description, options: options)
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
          { type: InteractionType::Ping }
        when InteractionType::ApplicationCommand
          name = data.dig(:data, :name)
          klass = COMMANDS.fetch(name&.to_sym)
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
        JSON.parse(body).with_indifferent_access
      rescue Ed25519::VerifyError
        raise WebhookVerificationError
      end
    end
  end
end
