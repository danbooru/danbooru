# frozen_string_literal: true

# @see Source::URL::Cohost
module Source
  class Extractor
    class Cohost < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        else
          post["blocks"].to_a.filter_map { |block| block.dig("attachment", "fileURL") }
        end
      end

      def display_name
        # Display name can be blank (example: https://cohost.org/fish)
        post.dig("postingProject", "displayName").presence
      end

      def username
        post.dig("postingProject", "handle")
      end

      def profile_url
        "https://cohost.org/#{username}" if username.present?
      end

      def artist_commentary_title
        post["headline"]
      end

      def artist_commentary_desc
        post["blocks"].to_a.map do |block|
          case block["type"]
          in "ask"
            if block.dig("ask", "askingProject", "handle").present?
              asker = block.dig("ask", "askingProject", "handle")
            elsif block.dig("ask", "loggedIn")
              asker = "Anonymous User"
            else
              asker = "Anonymous Guest"
            end

            <<~EOS
              > #{asker} asked:
              >
              > #{block.dig("ask", "content")}
            EOS
          in "markdown"
            block.dig("markdown", "content").to_s
          else
            ""
          end
        end.join("\n\n")
      end

      def dtext_artist_commentary_desc
        markdown = artist_commentary_desc

        # Delete <ul> tags because Kramdown doesn't parse Markdown inside of them.
        markdown.gsub!(%r{</?ul.*?>}, "\n\n")

        # Put block-level HTML tags on a line by themselves because Kramdown only recognizes them at the start of a line.
        markdown.gsub!(%r{(</?(?:details|summary|div|figure).*?>)}, "\n\\1\n")

        # Add two spaces to the end of lines to make Kramdown treat newlines as hard linebreaks.
        markdown.gsub!("\n", "  \n")

        html = Kramdown::Document.new(markdown, parse_block_html: true, auto_ids: false, header_offset: 3, smart_quotes: %w[apos apos quot quot]).to_html
        DText.from_html(html, base_url: "https://cohost.org") do |element|
          # Convert external images embedded in the commentary to `"[image]":url` links
          element["alt"] = "[image]" if element.name == "img"
        end
      end

      def tags
        post["tags"].to_a.map do |tag|
          [tag, "https://cohost.org/rc/tagged/#{Danbooru::URL.escape(tag)}"]
        end
      end

      memoize def post
        query = api_response["queries"]&.find { |q| q in queryKey: [["posts", "singlePost"], *] }
        query&.dig("state", "data", "post") || {}
      end

      memoize def api_response
        page&.at("script#trpc-dehydrated-state")&.text&.parse_json || {}
      end

      memoize def page
        http.cookies("connect.sid": Danbooru.config.cohost_session_cookie).cache(1.minute).parsed_get(page_url)
      end
    end
  end
end
