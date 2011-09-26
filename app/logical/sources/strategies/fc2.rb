module Sources
  module Strategies
    class Fc2 < Base
      def site_name
        "FC2"
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
