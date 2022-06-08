# frozen_string_literal: true

class DiscordSlashCommand
  class PostEmbed
    attr_reader :post, :command

    def initialize(post, command)
      @post = post
      @command = command
    end

    def to_h
      {
        title: post.dtext_shortlink,
        url: Routes.url_for(post),
        timestamp: post.created_at.iso8601,
        color: embed_color,
        footer: embed_footer,
        image: {
          width: post.image_width,
          height: post.image_height,
          url: embed_image_url,
        },
      }
    end

    def embed_image_url
      if is_censored?
        nil
      elsif post.file_ext.match?(/jpe?g|png|gif/)
        post.media_asset.variant("original").file_url
      else
        post.media_asset.variant("360x360").file_url
      end
    end

    def embed_color
      if post.is_flagged?
        0xC41C19
      elsif post.is_pending?
        0x0000FF
      elsif post.parent_id.present?
        0xC0C000
      elsif post.has_active_children?
        0x00FF00
      elsif post.is_deleted?
        0xFFFFFF
      else
        nil
      end
    end

    def embed_footer
      dimensions = "#{post.image_width}x#{post.image_height}"
      file_size = post.file_size.to_formatted_s(:human_size, precision: 4)
      text = "#{post.fav_count} ❤ | Rating: #{post.rating.upcase} | #{dimensions} (#{file_size} #{post.file_ext})"

      { text: text }
    end

    def censored_tags
      ["guro", "bestiality"]
    end

    def is_censored?
      (post.rating != 'g' && !is_nsfw_channel?) || !post.visible?(User.anonymous) || censored_tags.any? { |tag| tag.in?(post.tag_array) }
    end

    def is_nsfw_channel?
      command.channel.fetch("nsfw", false)
    end
  end
end
