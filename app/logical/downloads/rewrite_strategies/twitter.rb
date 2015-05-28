module Downloads
  module RewriteStrategies
    class Twitter < Base
      def rewrite(url, headers, data = {})
        if url =~ %r!^https?://(?:mobile\.)?twitter\.com!
          url, headers = rewrite_status_page(url, headers)
        elsif url =~ %r{^https?://pbs\.twimg\.com}
          url, headers = rewrite_thumbnails(url, headers)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_status_page(url, headers)
        source = ::Sources::Strategies::Twitter.new(url)
        source.get
        url = source.image_url
        return [url, headers]
      end

      def rewrite_thumbnails(url, headers)
        if url =~ %r{^(https?://pbs\.twimg\.com/media/[^:]+)}
          url = $1 + ":orig"
        end

        return [url, headers]
      end
    end
  end
end
