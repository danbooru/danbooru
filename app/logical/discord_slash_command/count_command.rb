# frozen_string_literal: true

class DiscordSlashCommand
  class CountCommand < DiscordSlashCommand
    self.name = "count"
    self.description = "Do a tag search and return the number of results"
    self.options = [{
      name: "tags",
      description: "The tags to search",
      required: true,
      type: ApplicationCommandOptionType::String
    }]

    def call
      tags = params[:tags]
      count = PostQuery.normalize(tags).fast_count(timeout: 9_000, estimate_count: false, skip_cache: true)

      respond_with("`#{tags}`: #{count} posts")
    end
  end
end
