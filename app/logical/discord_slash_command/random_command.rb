class DiscordSlashCommand
  class RandomCommand < DiscordSlashCommand
    def name
      "random"
    end

    def description
      "Show a random post"
    end

    def options
      [
        {
          name: "tags",
          description: "The tags to search",
          type: ApplicationCommandOptionType::String
        },
        {
          name: "limit",
          description: "The number of posts to show (max 10)",
          type: ApplicationCommandOptionType::Integer
        }
      ]
    end

    def call
      tags = params[:tags]
      limit = params.fetch(:limit, 1).clamp(1, 10)
      posts = Post.user_tag_match(tags, User.anonymous).random(limit)

      respond_with(posts: posts)
    end
  end
end
