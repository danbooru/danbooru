module Sources
  module Strategies
    class Default < Base
      def site_name
        "?"
      end
      
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
      
    protected
      def create_agent
      end
    end
  end
end
