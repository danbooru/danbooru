module Sources
  module Strategies
    class Tinami < Base
      def site_name
        "Tinami"
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
