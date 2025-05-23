# frozen_string_literal: true

# @see Source::URL::Reddit
module Source
  class Extractor
    class Reddit < Source::Extractor
      def image_urls
        if parsed_url&.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        elsif post_data.present?
          # images += [data.dig("media", "content")].compact unless crosspost? || data.dig("media", "type") == "embed"
          return [external_image] if external_image.present?
          return [] if crosspost?

          images = []

          if post_data.include?("preview") && post_data["is_reddit_media_domain"]
            images += post_data.dig("preview", "images")&.pluck("source")&.pluck("url").to_a
          elsif post_data.include?("media_metadata")
            images += ordered_gallery_images
          end

          images.compact.uniq.map { |url| Source::URL.parse(url)&.full_image_url || url }.compact
        else
          []
        end
      end

      def ordered_gallery_images
        gallery_images = post_data["media_metadata"]
        gallery_order = post_data.dig("gallery_data", "items").to_a.pluck("media_id")

        return gallery_images.to_h.values.pluck("s").pluck("u") unless gallery_order.present?

        gallery_images.to_h.values_at(*gallery_order).compact.pluck("s").pluck("u")
      end

      def external_image
        if post_data["post_hint"] == "image" && !post_data["is_reddit_media_domain"]
          Source::URL.parse(post_data["url"])&.full_image_url
        end
      end

      def profile_url
        "https://www.reddit.com/user/#{username}" if username.present?
      end

      def page_url
        return parsed_url.page_url unless post_data.present?

        if user_post?
          "https://www.reddit.com#{post_data["permalink"].sub(%r{^/r/u_}, "/user/")}"
        else
          "https://www.reddit.com#{post_data["permalink"]}"
        end
      end

      def tags
        return [] unless subreddit.present?

        flair = post_data["link_flair_text"]

        return [] unless flair.is_a?(String)

        [[flair, %{https://www.reddit.com/#{subreddit}/?f=flair_name:"#{Danbooru::URL.escape(flair)}"}]]

        # post_data["link_flair_text"].to_a.pluck("text").compact_blank.uniq.map do |flair|
        #   [flair, %{https://www.reddit.com/r/#{subreddit}/?f=flair_name:"#{Danbooru::URL.escape(flair)}"}]
        # end
      end

      def username
        username = post_data["author"] || parsed_url.username || parsed_referer&.username
        username unless username == "[deleted]"
      end

      def display_name
        username
      end

      def artist_commentary_title
        post_data["title"]
      end

      def artist_commentary_desc
        post_data["selftext"]
      end

      def dtext_artist_commentary_desc
        DText.from_html(html_artist_commentary_desc, base_url: "https://www.reddit.com") do |element|
          case element.name
          in "a"
            # Format embedded images properly
            if element[:href]
              parsed_href = Source::URL.parse(element[:href])

              if parsed_href && parsed_href.class != Source::URL::Null && image_urls.include?(parsed_href.full_image_url)
                element.content = "[image]"
                element[:href] = parsed_href.full_image_url
              end
            end
          in "span"
            # Transform spoiler tags
            if element.classes.include?("md-spoiler-text")
              element.name = "inline-spoiler"
            end
          else
            nil
          end
        end
      end

      def html_artist_commentary_desc
        CGI.unescapeHTML(post_data["selftext_html"].to_s)
      end

      def crosspost?
        post_data["crosspost_parent"].present?
      end

      def work_id
        if share_url.present?
          redirect_url = http.redirect_url(share_url)
          Source::URL.parse(redirect_url)&.work_id
        else
          parsed_url.work_id || parsed_referer&.work_id
        end
      end

      def share_url
        parsed_urls.find(&:share_id)
      end

      def find_comment(id, parent_comments: comments)
        parent_comments.to_a.each do |reply|
          return reply["data"] if reply.dig("data", "id") == id

          next if reply.dig("data", "replies").is_a?(String)

          candidate = find_comment(id, parent_comments: reply.dig("data", "replies", "data", "children"))
          return candidate if candidate
        end

        nil
      end

      def user_post?
        post_data["subreddit_name_prefixed"].to_s.starts_with?("u/")
      end

      def subreddit
        post_data["subreddit_name_prefixed"]
      end

      def api_url
        "https://www.reddit.com/comments/#{work_id}.json" if work_id.present?
      end

      memoize def api_response
        http.cache(1.minute).parsed_get(api_url)
      end

      def banned?
        api_response.blank? || (api_response.try("error") == 404 && api_response["reason"] == "banned")
      end

      memoize def post_data
        api_response&.dig(0, "data", "children", 0, "data").to_h
      end

      memoize def comments
        api_response&.dig(1, "data", "children").to_a
      end
    end
  end
end
