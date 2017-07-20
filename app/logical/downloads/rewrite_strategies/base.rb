# This is a collection of strategies for normalizing URLs. Most strategies 
# typically work by parsing and rewriting the URL itself, but some strategies 
# may delegate to Sources::Strategies to obtain a more canonical URL.

module Downloads
  module RewriteStrategies
    class Base
      attr_reader :url

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
      def http_exists?(url, headers)
        res = HTTParty.head(url, Danbooru.config.httparty_options.deep_merge(headers: headers))
        res.success?
      end
    end
  end
end
