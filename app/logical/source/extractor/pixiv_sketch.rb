# frozen_string_literal: true

# @see Source::URL::PixivSketch
module Source
  class Extractor
    class PixivSketch < Source::Extractor
      def match?
        Source::URL::PixivSketch === parsed_url
      end

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
        "https://sketch.pixiv.net/@#{artist_name}" if artist_name.present?
      end

      def artist_name
        api_response.dig("data", "user", "unique_name")
      end

      def other_names
        [artist_name, display_name].compact
      end

      def profile_urls
        [profile_url, pixiv_profile_url].compact
      end

      def artist_commentary_desc
        api_response.dig("data", "text")
      end

      def tags
        api_response.dig("data", "tags").to_a.map do |tag|
          [tag, "https://sketch.pixiv.net/tags/#{tag}"]
        end
      end

      def display_name
        api_response.dig("data", "user", "name")
      end

      def pixiv_profile_url
        "https://www.pixiv.net/users/#{pixiv_user_id}" if pixiv_user_id.present?
      end

      def pixiv_user_id
        api_response.dig("data", "user", "pixiv_user_id")
      end

      # curl https://sketch.pixiv.net/api/items/5835314698645024323.json | jq
      def api_response
        return {} if api_url.blank?

        response = http.cache(1.minute).get(api_url)
        return {} if response.status == 404

        response.parse
      end

      def page_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def api_url
        parsed_url.api_url || parsed_referer&.api_url
      end

      memoize :api_response
    end
  end
end
