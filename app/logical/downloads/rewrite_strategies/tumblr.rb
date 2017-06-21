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
        if url =~ %r{^https?://.+\.tumblr\.com/(?:\w+/)?(?:tumblr_)?(\w+_)(\d+)(\..+)$}
          match = $1
          given_size = $2
          file_ext = $3

          big_1280_url = url.sub(match + given_size, match + "1280")
          if file_ext == ".gif"
            res = http_head_request(big_1280_url, headers)
            # Sometimes the 1280 version of a gif is actually a static jpeg. We don't want that so we only use the 1280 version if it really is a gif.
            if res.is_a?(Net::HTTPSuccess) && res["content-type"] == "image/gif"
              return [big_1280_url, headers]
            end
          else
            if http_exists?(big_1280_url, headers)
              return [big_1280_url, headers]
            end
          end
        end

        return [url, headers]
      end

      # https://gs1.wac.edgecastcdn.net/8019B6/data.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
      # => http://data.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
      def rewrite_cdn(url, headers)
        url.sub!(%r!\Ahttps?://gs1\.wac\.edgecastcdn\.net/8019B6/data\.tumblr\.com!i, "http://data.tumblr.com")
        return [url, headers]
      end
    end
  end
end
