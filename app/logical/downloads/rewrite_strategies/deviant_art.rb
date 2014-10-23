module Downloads
  module RewriteStrategies
    class DeviantArt < Base
      def rewrite(url, headers, data = {})
        if url =~ /https?:\/\/(?:.+?\.)?deviantart\.(?:com|net)/
          url, headers = rewrite_html_pages(url, headers)
          url, headers = rewrite_thumbnails(url, headers)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_html_pages(url, headers)
        if url =~ %r{^https?://.+?\.deviantart\.com/art/}
          source = ::Sources::Strategies::DeviantArt.new(url)
          source.get
          return [source.image_url, headers]
        else
          return [url, headers]
        end
      end

      def rewrite_thumbnails(url, headers)
        if url =~ %r{^(https?://.+?\.deviantart\.net/.+?/)200H/}
          match = $1
          url.sub!(match + "200H/", match)
        elsif url =~ %r{^(https?://.+?\.deviantart\.net/.+?/)PRE/}
          match = $1
          url.sub!(match + "PRE/", match)
        end

        return [url, headers]
      end
    end
  end
end
