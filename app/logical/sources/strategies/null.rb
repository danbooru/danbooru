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

      def canonical_url
        image_url
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

      def unique_id
        url
      end
    end
  end
end
