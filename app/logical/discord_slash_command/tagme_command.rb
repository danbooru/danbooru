class DiscordSlashCommand
  class TagmeCommand < DiscordSlashCommand
    self.name = "tagme"
    self.description = "Automatically tag an image"
    self.options = [{
      name: "url",
      description: "The URL of the image to tag",
      required: false,
      type: ApplicationCommandOptionType::String
    }, {
      name: "table",
      description: "Format the output as a table",
      required: false,
      type: ApplicationCommandOptionType::Boolean
    }]

    def call
      table = params.fetch(:table, false)

      # Use the given URL, if present, or the last message with an attachment, if not.
      if params[:url].present?
        respond_later { tagme(params[:url], table: table) }
      elsif result = get_last_message_with_url
        message, url = result
        respond_later { tagme(url, table: table) }
      else
        respond_with("No image found. Post an image or provide a URL.")
      end
    end

    def tagme(url, table: false)
      tags = get_tags(url)

      if table
        build_tag_table(tags)
      else
        build_tag_list(tags)
      end
    end

    def get_last_message_with_url(limit: 10)
      messages = get_channel_messages(limit: limit)

      messages.each do |message|
        if message["attachments"].present?
          url = message["attachments"].first["url"]
        # else
        #  url = message["content"].scan(%r!https?://[^ ]+!i).first
        end

        return [message, url] if url.present?
      end

      nil
    end

    def get_tags(url, size: 500, minimum_confidence: 0.5)
      response, file = http.download_media(url)
      preview = file.preview(size, size)
      tags = deep_danbooru.tags!(preview).to_a
      tags = tags.reject { |tag, confidence| confidence < minimum_confidence }
      tags = tags.sort_by { |tag, confidence| [tag.general? ? 1 : 0, tag.name] }.to_h
      tags
    end

    def build_tag_table(tags)
      table = Terminal::Table.new
      table.headings = ["Tag", "Count", "Confidence"]

      tags.each do |tag, confidence|
        table << [tag.name, tag.post_count, "%.f%%" % (100 * confidence)]
        break if table.to_s.size >= DiscordApiClient::MAX_MESSAGE_LENGTH
      end

      "```\n#{table}\n```"
    end

    def build_tag_list(tags)
      msg = ""

      tags.keys.each do |tag|
        msg << "[#{tag.name}](#{Routes.posts_url(tags: tag.name)}) "
        break if msg.size >= DiscordApiClient::MAX_MESSAGE_LENGTH
      end

      msg
    end

    def http
      @http ||= Danbooru::Http.timeout(15)
    end

    def deep_danbooru
      @deep_danbooru ||= DeepDanbooruClient.new(http: http)
    end
  end
end
