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
        source = ::Sources::Strategies::Twitter.new(url)
        source.get
        url = source.image_url
        return [url, headers]
      end
    end
  end
end
