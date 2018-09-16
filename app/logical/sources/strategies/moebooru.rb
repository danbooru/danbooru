module Sources
  module Strategies
    class Moebooru < Base
      BASE_URL = %r!\Ahttps?://(?:[^.]+\.)?(?<domain>yande\.re|konachan\.com)!i

      def self.match?(*urls)
        urls.compact.any? { |x| x.match?(BASE_URL) }
      end

      def site_name
        urls.map { |url| url[BASE_URL, :domain] }.compact.first
      end

      def image_url
        if url =~ %r{\A(?<base>#{BASE_URL})/jpeg/(?<md5>\h+(?:/.*)?)\.jpg\Z}
          return $~[:base] + "/image/" + $~[:md5] + ".png"
        end

        return url
      end

      def image_urls
        [image_url]
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
