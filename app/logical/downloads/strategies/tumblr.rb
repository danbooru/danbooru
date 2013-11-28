module Downloads
  module Strategies
    class Tumblr < Base
      def rewrite(url, headers)
        if url =~ %r{^http?://(?:(?:\d+\.)\w+\.)?tumblr\.com}
          url, headers = rewrite_thumbnails(url, headers)
        end

        return [url, headers]
      end

    protected
      def rewrite_thumbnails(url, headers)
        if url =~ %r{^http?://.+\.tumblr\.com/(?:\w+/)?(?:tumblr_)?(\w+_)(250|400|500)\..+$}
          match = $1
          size = $2
          big_url = url.sub(match + size, match + "1280")
          if http_exists?(big_url, headers)
            url = big_url
          end
        end

        return [url, headers]
      end
    end
  end
end
