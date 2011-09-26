module Sources
  module Strategies
    class NicoSeiga < Base
      def site_name
        "Nico Seiga"
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
