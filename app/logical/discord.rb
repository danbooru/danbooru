# frozen_string_literal: true

module Discord
  module Events
    def self.respond(name, regex, &block)
      @@messages ||= []
      @@messages << [name, regex]

      define_method(:"do_#{name}") do |event|
        text = event.text.gsub(/```.*```/m, "")
        matches = text.scan(/(?<!`)#{regex}(?!`)/)

        matches.each do |match|
          instance_exec(event, match, &block)
        end

        nil
      end
    end

    def self.respond_to_id(model, shortlink = nil)
      shortlink ||= model.name.to_s.split("::").last.underscore
      respond(:"#{shortlink}_id", /#{shortlink.tr("_", " ")} #[0-9]+/i) do |event, text|
        subject = model.find_by(id: text[/[0-9]+/].to_i)
        subject.send_embed(event.channel) if subject.present?
      end
    end

    respond_to_id BulkUpdateRequest, "bur"
    respond_to_id Comment
    respond_to_id ForumPost, "forum"
    respond_to_id ForumTopic, "topic"
    # respond_to_id MediaAsset, "asset"
    respond_to_id Post
    respond_to_id User

    respond(:wiki_link, /\[\[ [^\]]+ \]\]/x) do |event, text|
      title = text[/[^\[\]]+/].gsub(/\s/, "_")

      event.channel.start_typing

      wiki_page = WikiPage.find_by(title:)

      if wiki_page.present?
        wiki_page.send_embed(event.channel)
      else
        image = if event.channel.nsfw?
          Post.anon_tag_match(title).order(score: :desc).limit(1)
        else
          Post.anon_tag_match("#{title} rating:g").order(score: :desc).limit(1)
        end.first&.discord_image(event.channel)

        if image.present?
          event.channel.send_embed do |embed|
            embed.title = title.tr("_", " ")
            embed.url = Routes.new_wiki_page_url(wiki_page: { title: })
            embed.image = image

            embed.description = "No wiki page found for this tag."
          end
        end
      end
    end

    respond(:search_link, /{{ [^\}]+ }}/x) do |event, text|
      search = text[/[^{}]+/]

      event.channel.start_typing
      posts = Post.anon_tag_match(search).limit(3)

      posts.each do |post|
        post.send_embed(event.channel)
      end
    end

    def do_convert_post_links(event, *args)
      post_ids = []

      message = event.message.content.gsub(%r{\b(?!https?:\/\/(?:\w+\.)?aibooru\.(?:online|ovh|download)\/posts\/\d+\/\w+)https?:\/\/(?:\w+\.)?aibooru\.(?:online|ovh|download)\/posts\/(\d+)\b[^[:space:]]*}i) do |link|
        post_ids << $1.to_i
        link = link.gsub(/\A<+(.+)>+\z/, "\\1")
        "<#{link}>"
      end

      posts = Post.where(id: post_ids)

      if posts.present?
        event.message.delete
        event.send_message("#{event.author.display_name} posted: #{message}", false, nil, nil, false)

        posts.each do |post|
          post.send_embed(event.channel)
        end
      end
    end

    def do_eval(event, *args)
      return unless event.user.id == event.bot.bot_application.owner.id

      code = args.join(" ")
      result = instance_eval(code)
      event << "```\n#{result.inspect}```"
    end

    def do_sql(event, *args)
      return unless event.user.id == event.bot.bot_application.owner.id

      event.channel.start_typing

      sql = args.join(" ")
      result = ActiveRecord::Base.connection.execute(sql)
      table = Terminal::Table.new(headings: result.fields, rows: result.map(&:values).take(10)).to_s
      rows = table.split("\n")
      num = (1950.0 / rows[0].length.to_f).floor
      table = rows.take(num).join("\n")

      more = if num < rows.count
        "\n[#{rows.count - num} rows omitted]"
      else
        ""
      end

      event << "```\n#{table}#{more}\n```"
    end

    def do_count(event, *args)
      event.channel.start_typing

      query = PostQuery.normalize(args.join(" "))
      count = query.fast_count
      if count.present?
        event.send_message("Post count for [`#{query}`](<#{Routes.posts_url(tags: query)}>): #{count}", false, nil, nil, false)
      else
        event << "Error fetching count"
      end
    end

    def do_pendingburs(event, *args)
      burs = BulkUpdateRequest.pending.order(created_at: :asc).includes(:user, forum_post: [:votes]).take(10)
      if burs.present?
        rows = burs.map do |bur|
          ["BUR ##{bur.id}", bur.user.pretty_name, bur.forum_topic.title, bur.forum_post.formatted_votes, bur.expires_at.strftime("%F")]
        end
        table = Terminal::Table.new(headings: ["ID", "User", "Title", "Votes", "Expires"], rows: rows)
        event << "```\n#{table}\n```"
      else
        event << "No pending BURs."
      end
    end
  end

  class Bot
    include Discord::Events

    attr_reader :initiate_shutdown

    def initialize(bot_token = Danbooru.config.discord_bot_token, client_id = Danbooru.config.discord_application_client_id, guild_id = Danbooru.config.discord_guild_id)
      @guild_id = guild_id
      @bot = Discordrb::Commands::CommandBot.new(
        name: "AIBooru",
        token: bot_token,
        client_id: client_id,
        prefix: "!",
      )

      register_commands
    end

    def register_commands
      @bot.message(contains: %r!https?:\/\/(?:\w+\.)?aibooru\.(?:online|ovh|download)\/posts\/\d+!i, &method(:do_convert_post_links))
      @bot.command(:eval, &method(:do_eval))
      @bot.command(:count, &method(:do_count))
      @bot.command(:sql, &method(:do_sql))
      @bot.command(:pendingburs, &method(:do_pendingburs))

      @@messages.each do |name, regex|
        @bot.message(contains: regex, &method(:"do_#{name}"))
      end
    end

    def run
      @bot.run(:async)

      loop do
        shutdown! if initiate_shutdown
        sleep 1
      end
    end
  end
end
