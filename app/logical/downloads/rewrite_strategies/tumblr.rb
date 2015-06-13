module Downloads
  module RewriteStrategies
    class Tumblr < Base
      def rewrite(url, headers, data = {})
        if url =~ %r{^https?://.*tumblr\.com}
          url, headers = rewrite_cdn(url, headers)
          url, headers = rewrite_thumbnails(url, headers)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_thumbnails(url, headers)
        if url =~ %r{^https?://.+\.tumblr\.com/(?:\w+/)?(?:tumblr_)?(\w+_)(\d+)\..+$}
          match = $1
          given_size = $2

          big_1280_url = url.sub(match + given_size, match + "1280")
          if http_exists?(big_1280_url, headers)
            return [big_1280_url, headers]
          end
        end

        return [url, headers]
      end

      def rewrite_cdn(url, headers)
        if url =~ %r{https?://gs1\.wac\.edgecastcdn\.net/8019B6/data\.tumblr\.com/}
          url.sub!("gs1.wac.edgecastcdn.net/8019B6/", "")
        end

        return [url, headers]
      end
    end
  end
end
