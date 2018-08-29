module Sources
  module Strategies
    class Null < Base
      def self.match?(*urls)
        true
      end

      def image_urls
        [url]
      end

      def page_url
        url
      end

      def artist_name
        nil
      end

      def normalized_for_artist_finder?
        true
      end

      def normalizable_for_artist_finder?
        false
      end

      def normalize_for_artist_finder
        url
      end

      def site_name
        URI.parse(url).hostname || "N/A"
      rescue
        "N/A"
      end

      def unique_id
        url
      end

      def rewrite(url, headers, data)
        return [url, headers, data]
      end
    end
  end
end
