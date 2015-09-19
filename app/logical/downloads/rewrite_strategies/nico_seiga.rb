module Downloads
  module RewriteStrategies
    class NicoSeiga < Base
      attr_accessor :url, :source

      def initialize(url)
        @url  = url
      end

      def rewrite(url, headers, data = {})
        if url =~ %r{https?://lohas\.nicoseiga\.jp} || url =~ %r{https?://seiga\.nicovideo\.jp}
          url, headers = rewrite_headers(url, headers)
          url, headers = rewrite_html_pages(url, headers)
          url, headers = rewrite_thumbnails(url, headers)
          url, headers = rewrite_view_big_pages(url, headers)
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
          return [source.image_url, headers]
        else
          return [url, headers]
        end
      end

      def rewrite_thumbnails(url, headers)
        if url =~ %r{/thumb/\d+}
          return [source.image_url, headers]
        end

        return [url, headers]
      end

      def rewrite_view_big_pages(url, headers)
        # example: http://lohas.nicoseiga.jp/o/40aeedd2848a7780b6046747e75b3566b423a10c/1436307639/5026559

        if url =~ %r{http://lohas\.nicoseiga\.jp/o/}
          return [source.image_url, headers]
        else
          return [url, headers]
        end
      end

      # Cache the source data so it gets fetched at most once.
      def source
        @source ||= begin
          source = ::Sources::Strategies::NicoSeiga.new(url)
          source.get

          source
        end
      end
    end
  end
end
