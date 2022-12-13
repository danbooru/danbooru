# frozen_string_literal: true

# @see https://picdig.net/
# @see Source::URL::Picdig
module Source
  class Extractor
    class Picdig < Source::Extractor
      def match?
        Source::URL::Picdig === parsed_url
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.to_s]
        else
          image_urls_from_commentary
        end
      end

      def image_urls_from_commentary
          html = Nokogiri::HTML5.fragment(artist_commentary_desc)
          html.css("img").map { |img| img[:src] }
      end

      def page_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def profile_url
        parsed_url.profile_url || parsed_referer&.profile_url
      end

      def profile_urls
        [
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
        return {} if api_url.blank?

        response = http.cache(1.minute).get(api_url)
        return {} unless response.status == 200

        response.parse.with_indifferent_access.dig(:data, :project)
      end
    end
  end
end
