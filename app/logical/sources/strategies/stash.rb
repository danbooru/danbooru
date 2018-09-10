module Sources
  module Strategies
    class Stash < DeviantArt
      STASH = %r{\Ahttps?://sta\.sh/(?<post_id>[0-9a-zA-Z]+)}i

      def self.match?(*urls)
        urls.compact.any? { |x| x =~ STASH }
      end

      def site_name
        "Sta.sh"
      end

      def canonical_url
        page_url
      end

      def page_url
        "https://sta.sh/#{stash_id}"
      end

      def api_url
        page_url
      end

      def self.stash_id_from_url(url)
       if url =~ STASH
         $~[:post_id].downcase
       else
         nil
       end
     end

      def stash_id
        [url, referer_url].map{ |x| self.class.stash_id_from_url(x) }.compact.first
      end
    end
  end
end
