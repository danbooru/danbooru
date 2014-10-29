module Sources
  module Strategies
    class Base
      attr_reader :url
      attr_reader :artist_name, :profile_url, :image_url, :tags, :page_count

      def self.url_match?(url)
        false
      end

      def initialize(url)
        @url = url
        @page_count = 1
      end

      # No remote calls are made until this method is called.
      def get
        raise NotImplementedError
      end

      def normalize_for_artist_finder!
        url
      end

      # Subclasses should override this to return a string for a source: search
      # that should find duplicate posts uploaded from URLs functionally
      # equivalent to the given URL.
      #
      # Usually this just means replacing the parts of the URL that can vary
      # with wildcards.
      def normalize_for_dupe_search
        url
      end

      def site_name
        raise NotImplementedError
      end

      def unique_id
        artist_name
      end

      def artist_record
        if artist_name.present?
          Artist.other_names_match(artist_name)
        else
          nil
        end
      end

      def referer_url(template)
        template.params[:ref] || template.params[:url]
      end

    protected
      def agent
        raise NotImplementedError
      end
    end
  end
end
