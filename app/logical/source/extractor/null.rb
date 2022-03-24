# frozen_string_literal: true

module Source
  class Extractor
    class Null < Source::Extractor
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
