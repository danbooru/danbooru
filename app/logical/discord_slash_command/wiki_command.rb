# frozen_string_literal: true

class DiscordSlashCommand
  class WikiCommand < DiscordSlashCommand
    extend Memoist

    self.name = "wiki"
    self.description = "Show a wiki page"
    self.options = [
      {
        name: "name",
        description: "The name of the wiki page",
        required: true,
        type: ApplicationCommandOptionType::String
      },
    ]

    def call
      if wiki_page.nil?
        respond_with("`#{params[:name]}` doesn't have a wiki.")
      else
        respond_with(
          embeds: [{
            description: DText.new(wiki_page.body).to_markdown.truncate(500),
            title: wiki_page.pretty_title,
            url: Routes.url_for(wiki_page),
            **example_embed,
          }]
        )
      end
    end

    def wiki_page
      WikiPage.titled(params[:name]).first
    end

    def tag
      wiki_page&.tag
    end

    def example_post
      return nil if tag.nil? || tag.empty?

      if tag.artist?
        search = "#{tag.name} is:sfw"
      elsif tag.copyright?
        search = "#{tag.name} is:sfw everyone copytags:<5 -parody -crossover"
      elsif tag.character?
        search = "#{tag.name} is:sfw solo chartags:<5"
      else # meta or general
        search = "#{tag.name} is:sfw -animated -6+girls -comic"
      end

      Post.system_tag_match(search).limit(500).sort_by(&:score).last
    end

    def example_embed
      return {} if example_post.nil? || example_image_url.nil?

      {
        image: {
          url: example_image_url,
        },
        author: {
          name: example_post.dtext_shortlink,
          url: Routes.url_for(example_post),
        }
      }
    end

    def example_image_url
      DiscordSlashCommand::PostEmbed.new(example_post, self).embed_image_url
    end

    memoize :wiki_page, :tag, :example_post, :example_embed, :example_image_url
  end
end
