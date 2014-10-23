module Downloads
  module RewriteStrategies
    class Base
      def initialize(url = nil)
        @url = url
      end

      def self.strategies
        [Pixiv, NicoSeiga, Twitpic, DeviantArt, Tumblr, Moebooru]
      end

      def rewrite(url, headers, data = {})
        return [url, headers, data]
      end

    protected
      def http_exists?(url, headers)
        exists = false
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request_head(uri.request_uri, headers) do |res|
            if res.is_a?(Net::HTTPSuccess)
              exists = true
            end
          end
        end
        exists
      end
    end
  end
end
