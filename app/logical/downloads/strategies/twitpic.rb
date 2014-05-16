module Downloads
  module Strategies
    class Twitpic < Base
      def rewrite(url, headers)
        if url =~ %r{https?://twitpic\.com} || url =~ %r{^https?://d3j5vwomefv46c\.cloudfront\.net}
          url, headers = rewrite_html_pages(url, headers)
          url, headers = rewrite_thumbnails(url, headers)
        end

        return [url, headers]
      end

    protected
      def rewrite_html_pages(url, headers)
        # example: http://twitpic.com/cpprns

        if url =~ %r{https?://twitpic\.com/([a-z0-9]+)$}
          id = $1
          url = "http://twitpic.com/show/full/#{id}"
          return [url, headers]
        else
          return [url, headers]
        end
      end

      def rewrite_thumbnails(url, headers)
        if url =~ %r{^https?://d3j5vwomefv46c\.cloudfront\.net/photos/thumb/(\d+\..+)$}
          match = $1
          url.sub!("/thumb/" + match, "/large/" + match)
        end

        return [url, headers]
      end
    end
  end
end
