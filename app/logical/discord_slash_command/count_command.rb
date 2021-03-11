class DiscordSlashCommand
  class CountCommand < DiscordSlashCommand
    def name
      "count"
    end

    def description
      "Do a tag search and return the number of results"
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
      count = query.fast_count(estimate_count: true, skip_cache: true)

      respond_with("`#{tags}`: #{count} posts")
    end
  end
end
