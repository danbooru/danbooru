# frozen_string_literal: true

# @see Source::URL::PixivSketch
module Source
  class Extractor
    class PixivSketch < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          image_urls_from_api
        end
      end

      def image_urls_from_api
        api_response.dig("data", "media").to_a.pluck("photo").pluck("original").pluck("url2x")
      end

      def profile_url
        "https://sketch.pixiv.net/@#{username}" if username.present?
      end

      def display_name
        api_response.dig("data", "user", "name")
      end

      def username
        api_response.dig("data", "user", "unique_name") || parsed_url.username || parsed_referer&.username
      end

      def profile_urls
        [profile_url, pixiv_profile_url].compact
      end

      def artist_commentary_desc
        api_response.dig("data", "text")
      end

      def dtext_artist_commentary_desc
        dtext = api_response.dig("data", "text_fragments").to_a.map do |fragment|
          case fragment["type"]
          when "tag"
            %{"#{fragment["body"].gsub('"', "&quot;")}":[https://sketch.pixiv.net/tags/#{Danbooru::URL.escape(fragment["normalized_body"])}]}
          else
            DText.escape(fragment["normalized_body"])
          end
        end.join

        DText.normalize_whitespace(dtext)
      end

      def tags
        api_response.dig("data", "tags").to_a.map do |tag|
          [tag, "https://sketch.pixiv.net/tags/#{Danbooru::URL.escape(tag)}"]
        end
      end

      def pixiv_profile_url
        "https://www.pixiv.net/users/#{pixiv_user_id}" if pixiv_user_id.present?
      end

      def pixiv_user_id
        api_response.dig("data", "user", "pixiv_user_id")
      end

      # curl https://sketch.pixiv.net/api/items/5835314698645024323.json | jq
      memoize def api_response
        http.cache(1.minute).parsed_get(api_url) || {}
      end

      def api_url
        parsed_url.api_url || parsed_referer&.api_url
      end
    end
  end
end
