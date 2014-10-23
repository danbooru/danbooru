module Downloads
  module RewriteStrategies
    class NicoSeiga < Base
      def rewrite(url, headers, data = {})
        if url =~ %r{https?://lohas\.nicoseiga\.jp} || url =~ %r{https?://seiga\.nicovideo\.jp}
          url, headers = rewrite_headers(url, headers)
          url, headers = rewrite_html_pages(url, headers)
          url, headers = rewrite_thumbnails(url, headers)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_headers(url, headers)
        headers["Referer"] = "http://seiga.nicovideo.jp"
        return [url, headers]
      end

      def rewrite_html_pages(url, headers)
        # example: http://seiga.nicovideo.jp/seiga/im1389842

        if url =~ %r{https?://seiga\.nicovideo\.jp/seiga/im\d+}
          source = ::Sources::Strategies::NicoSeiga.new(url)
          source.get
          return [source.image_url, headers]
        else
          return [url, headers]
        end
      end

      def rewrite_thumbnails(url, headers)
        if url =~ %r{/thumb/\d+}
          source = ::Sources::Strategies::NicoSeiga.new(url)
          source.get
          return [source.image_url, headers]
        end

        return [url, headers]
      end
    end
  end
end
