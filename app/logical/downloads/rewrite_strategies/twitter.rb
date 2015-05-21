module Downloads
  module RewriteStrategies
    class Twitter < Base
      def rewrite(url, headers, data = {})
        if url =~ %r!^https?://(?:mobile\.)?twitter\.com!
          url, headers = rewrite_status_page(url, headers, data)
        elsif url =~ %r{^https?://pbs\.twimg\.com}
          url, headers = rewrite_thumbnails(url, headers, data)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_status_page(url, headers, data)
        source = build_source(url)
        url = source.image_url
        data[:artist_commentary_desc] = source.artist_commentary_desc
        return [url, headers, data]
      end

      def rewrite_thumbnails(url, headers, data)
        if url =~ %r{^(https?://pbs\.twimg\.com/media/[^:]+)}
          url = $1 + ":orig"
        end

        return [url, headers]
      end

      def build_source(url)
        ::Sources::Strategies::Twitter.new(url).tap do |x|
          x.get
        end
      end
    end
  end
end
