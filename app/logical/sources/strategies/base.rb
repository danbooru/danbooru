module Sources
  module Strategies
    class Base
      attr_reader :url
      attr_reader :artist_name, :profile_url, :image_url, :tags
      
      def self.url_match?(url)
        false
      end
      
      def initialize(url)
        @url = url
      end
      
      # No remote calls are made until this method is called.
      def get
        raise NotImplementedError
      end
      
      def site_name
        raise NotImplementedError
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
