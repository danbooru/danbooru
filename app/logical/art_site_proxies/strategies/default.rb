module ArtSiteProxies
  module Strategies
    class Default < Base
      def artist_name
        "?"
      end
      
      def profile_url
        url
      end
      
      def image_url
        url
      end
      
      def tags
        []
      end
    end
  end
end
