module Downloads
  module RewriteStrategies
    class Twitter < Base
      def rewrite(url, headers, data = {})
        if url =~ %r!^https?://(?:mobile\.)?twitter\.com!
          url, headers = rewrite_image_url(url, headers)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_image_url(url, headers)
        # example: http://twitter.com/status
        url = url.sub(%r!^https?://twitter\.com!, "http://mobile.twitter.com")

        if url =~ %r!^https?://mobile\.twitter\.com/\w+/status/\d+!
          source = ::Sources::Strategies::Twitter.new(url)
          source.get
          url = source.image_url
        end

        return [url, headers]
      end
    end
  end
end
