module Downloads
  module Strategies
    class DeviantArt < Base
      def rewrite(url, headers)
        if url =~ /https?:\/\/(?:\w+\.)?deviantart\.(?:com|net)/
          url, headers = rewrite_html_pages(url, headers)
          url, headers = rewrite_thumbnails(url, headers)
        end

        return [url, headers]
      end

    protected
      def rewrite_html_pages(url, headers)
        if url =~ %r{^http://\w+\.deviantart\.com/art/\w+}
          source = ::Sources::Strategies::DeviantArt.new(url)
          source.get
          return [source.image_url, headers]
        else
          return [url, headers]
        end
      end

      def rewrite_thumbnails(url, headers)
        if url =~ %r{^(http://\w+.deviantart.net/\w+/)200H/}
          match = $1
          url.sub!(match + "200H/", match)
        end

        return [url, headers]
      end
    end
  end
end
