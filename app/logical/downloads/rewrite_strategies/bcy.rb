module Downloads
  module RewriteStrategies
    class BCY < Base
      attr_reader :url

      def rewrite(url, headers, data = {})
        return [url, headers, data] unless source.class.url_match?(url)
        data[:artist_commentary_title] = source.artist_commentary_title
        data[:artist_commentary_desc] = source.artist_commentary_desc
        return [source.image_url, headers, data]
      end

      def source
        @source ||= Sources::Strategies::BCY.new(url)
      end
    end
  end
end
