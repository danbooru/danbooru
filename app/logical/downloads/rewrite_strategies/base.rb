# This is a collection of strategies for normalizing URLs. Most strategies 
# typically work by parsing and rewriting the URL itself, but some strategies 
# may delegate to Sources::Strategies to obtain a more canonical URL.

module Downloads
  module RewriteStrategies
    class Base
      def initialize(url = nil)
        @url = url
      end

      def self.strategies
        [Downloads::RewriteStrategies::Pixiv, Downloads::RewriteStrategies::NicoSeiga, Downloads::RewriteStrategies::ArtStation, Downloads::RewriteStrategies::Twitpic, Downloads::RewriteStrategies::DeviantArt, Downloads::RewriteStrategies::Tumblr, Downloads::RewriteStrategies::Moebooru, Downloads::RewriteStrategies::Twitter, Downloads::RewriteStrategies::Nijie, Downloads::RewriteStrategies::Pawoo]
      end

      def rewrite(url, headers, data = {})
        return [url, headers, data]
      end

    protected
      def http_head_request(url, headers)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          http.use_ssl = true
        end
        http.request_head(uri.request_uri, headers) do |res|
          return res
        end
      end

      def http_exists?(url, headers)
        exists = false
        res = http_head_request(url, headers)
        if res.is_a?(Net::HTTPSuccess)
          exists = true
        end
        exists
      end
    end
  end
end
