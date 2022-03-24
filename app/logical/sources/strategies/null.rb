# frozen_string_literal: true

module Sources
  module Strategies
    class Null < Base
      def image_urls
        [url]
      end

      def page_url
        nil
      end

      def artists
        ArtistFinder.find_artists(url)
      end
    end
  end
end
