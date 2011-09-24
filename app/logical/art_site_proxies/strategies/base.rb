module ArtSiteProxies
  module Strategies
    class Base
      attr_reader :url, :agent
      
      def initialize(url)
        @url = url
        @agent = create_agent
      end
      
      def artist_name
        raise NotImplementedError
      end
      
      def tags
        raise NotImplementedError
      end
      
      def profile_url
        raise NotImplementedError
      end
      
      def image_url
        raise NotImplementedError
      end
      
    protected
      def create_agent
        raise NotImplementedError
      end
    end
  end
end
