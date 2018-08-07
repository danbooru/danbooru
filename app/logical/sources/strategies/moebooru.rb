module Sources
  module Strategies
    class Moebooru < Base
      DOMAINS = /(?:[^.]+\.)?yande\.re|konachan\.com/

      def self.match?(*urls)
        urls.compact.any? { |x| x.match?(DOMAINS) }
      end

      def site_name
        URI.parse(url).host
      end

      def image_url
        if url =~ %r{\A(https?://(?:#{DOMAINS}))/jpeg/([a-f0-9]+(?:/.*)?)\.jpg\Z}
          return $1 + "/image/" + $2 + ".png"
        end

        return url
      end

      def page_url
        return url
      end

      def profile_url
        return url
      end

      def artist_name
        return ""
      end
    end
  end
end
