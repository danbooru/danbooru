# frozen_string_literal: true

class DiscordSlashCommand
  class RandomCommand < DiscordSlashCommand
    self.name = "random"
    self.description = "Show a random post"
    self.options = [
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

    def call
      tags = params[:tags]
      limit = params.fetch(:limit, 1).clamp(1, 10)
      posts = Post.user_tag_match(tags, User.anonymous, tag_limit: nil).random(limit)

      respond_with(posts: posts)
    end
  end
end
