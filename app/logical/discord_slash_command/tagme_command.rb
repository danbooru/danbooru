# frozen_string_literal: true

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
      name: "confidence",
      description: "The minimum tag confidence level (default: 1%)",
      required: false,
      type: ApplicationCommandOptionType::Integer
    }]

    def call
      confidence = params.fetch(:confidence, 1).to_i / 100.0

      # Use the given URL, if present, or the last message with an attachment, if not.
      if params[:url].present?
        respond_later { tagme(params[:url], confidence) }
      elsif result = get_last_message_with_url
        message, url = result
        respond_later { tagme(url, confidence) }
      else
        respond_with("No image found. Post an image or provide a URL.")
      end
    end

    def tagme(url, confidence, limit: 50, size: 500)
      extractor = Source::Extractor.find(url)
      image_url = extractor.image_urls.first
      file = extractor.download_file!(image_url)

      preview = file.preview(size, size)
      tags = autotagger.evaluate(preview, limit: limit, confidence: confidence).to_a
      tags = tags.sort_by { |tag, confidence| [TagCategory.split_header_list.index(tag.category_name.downcase), -confidence] }.to_h

      return {
        embeds: [{
          description: build_tag_list(tags),
          author: {
            name: "#{Danbooru.config.app_name} Autotagger",
            url: "https://github.com/danbooru/autotagger",
            icon_url: "https://danbooru.donmai.us/images/danbooru-logo-96x96.png",
          },
          image: {
            url: image_url,
          },
        }]
      }
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

    def build_tag_list(tags)
      msg = ""

      tags.each do |tag, confidence|
        msg += "#{(100*confidence).to_i}% [#{tag.name}](#{Routes.posts_url(tags: tag.name)})\n"
        break if msg.size >= DiscordApiClient::MAX_MESSAGE_LENGTH
      end

      msg
    end

    def http
      @http ||= Danbooru::Http.timeout(15)
    end

    def autotagger
      @autotagger ||= AutotaggerClient.new(http: http)
    end
  end
end
