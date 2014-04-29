module Downloads
  module Strategies
    class Base
      def self.strategies
        [Pixiv, NicoSeiga, Twitpic, DeviantArt, Tumblr]
      end

      def rewrite(url, headers)
        return [url, headers]
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
