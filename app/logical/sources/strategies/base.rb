module Sources
  module Strategies
    class Base
      attr_reader :url
      
      def self.url_match?(url)
        false
      end
      
      def initialize(url)
        @url = url
      end
      
      def get
        raise NotImplementedError
      end
      
      def site_name
        raise NotImplementedError
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
      
      def artist_alias
        nil
      end
      
      def unique_id
        artist_name
      end
      
      def artist_record
        Artist.other_names_match(artist_name)
      end
      
    protected
      def agent
        raise NotImplementedError
      end
    end
  end
end
