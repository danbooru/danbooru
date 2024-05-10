# frozen_string_literal: true

# @see https://picdig.net/
# @see Source::URL::Picdig
module Source
  class Extractor
    class Picdig < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.to_s]
        else
          artist_commentary_desc.to_s.parse_html.css("img").pluck("src")
        end
      end

      def page_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def profile_url
        parsed_url.profile_url || parsed_referer&.profile_url
      end

      def profile_urls
        [
          profile_url,
          api_response.dig(:user, :homepage_url),
          api_response.dig(:user, :twitter_url),
          api_response.dig(:user, :instagram_url),
          api_response.dig(:user, :facebook_url),
          api_response.dig(:user, :youtube_url),
        ].compact_blank
      end

      def tag_name
        username
      end

      def artist_name
        api_response.dig(:user, :name)
      end

      def artist_commentary_title
        api_response[:title]
      end

      def artist_commentary_desc
        api_response[:content]
      end

      def tags
        api_response[:project_tags].to_a.map do |tag|
          [tag[:name], "https://picdig.net/projects?search_tag=#{Danbooru::URL.escape(tag[:name])}"]
        end
      end

      def username
        parsed_url.username || parsed_referer&.username
      end

      def api_url
        parsed_url.api_page_url || parsed_referer&.api_page_url
      end

      memoize def api_response
        http.cache(1.minute).parsed_get(api_url)&.dig(:data, :project) || {}
      end
    end
  end
end
