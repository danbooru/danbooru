module Downloads
  module RewriteStrategies
    class Nijie < Base
      attr_accessor :url, :source

      def initialize(url)
        @url  = url
      end

      def rewrite(url, headers, data = {})
        if url =~ %r{https?://nijie\.info\/view\.php.+id=\d+}
          url, headers = rewrite_html_pages(url, headers)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_html_pages(url, headers)
        # example: http://nijie.info/view.php?id=151126

        if url =~ %r{https?://nijie\.info\/view\.php.+id=\d+}
          return [source.image_url, headers]
        else
          return [url, headers]
        end
      end

      # Cache the source data so it gets fetched at most once.
      def source
        @source ||= begin
          source = ::Sources::Strategies::Nijie.new(url)
          source.get

          source
        end
      end
    end
  end
end
