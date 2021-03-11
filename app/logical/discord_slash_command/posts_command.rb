class DiscordSlashCommand
  class PostsCommand < DiscordSlashCommand
    extend Memoist

    def name
      "posts"
    end

    def description
      "Do a tag search"
    end

    def options
      [{
        name: "tags",
        description: "The tags to search",
        required: true,
        type: ApplicationCommandOptionType::String
      }]
    end

    def call
      tags = params[:tags]
      query = PostQueryBuilder.new(tags, User.anonymous).normalized_query

      limit = query.find_metatag(:limit) || 3
      limit = limit.to_i.clamp(1, 10)
      posts = query.build.paginate(1, limit: limit)
      embeds = posts.map { |post| post_embed(post) }

      respond_with(embeds: embeds)
    end

    def post_embed(post)
      {
        title: post.dtext_shortlink,
        url: Routes.url_for(post),
        timestamp: post.created_at.iso8601,
        color: post_embed_color(post),
        footer: post_embed_footer(post),
        image: {
          width: post.image_width,
          height: post.image_height,
          url: post_embed_image(post),
        },
      }
    end

    def post_embed_image(post, blur: 50)
      if is_censored?(post)
        nil
      elsif post.file_ext.match?(/jpe?g|png|gif/)
        post.file_url
      else
        post.preview_file_url
      end
    end

    def post_embed_color(post)
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

    def post_embed_footer(post)
      dimensions = "#{post.image_width}x#{post.image_height}"
      file_size = post.file_size.to_s(:human_size, precision: 4)
      text = "Rating: #{post.rating.upcase} | #{dimensions} (#{file_size} #{post.file_ext})"

      { text: text }
    end

    def is_censored?(post)
      post.rating != "s" && !is_nsfw_channel?
    end

    def is_nsfw_channel?
      discord.get_channel(data[:channel_id]).fetch("nsfw")
    end

    memoize :is_nsfw_channel?
  end
end
