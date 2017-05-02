module Downloads
  module RewriteStrategies
    class Twitter < Base
      attr_accessor :url, :source

      def initialize(url)
        @url  = url
      end

      def rewrite(url, headers, data = {})
        if url =~ %r!^https?://(?:mobile\.)?twitter\.com!
          url = source.image_url
        elsif url =~ %r{^https?://pbs\.twimg\.com}
          url, headers = rewrite_thumbnails(url, headers, data)
        end

        return [url, headers, data]
      end

    protected
      def rewrite_thumbnails(url, headers, data)
        if url =~ %r{^(https?://pbs\.twimg\.com/media/[^:]+)}
          url = $1 + ":orig"
        end

        return [url, headers]
      end

      # Cache the source data so it gets fetched at most once.
      def source
        @source ||= begin
          source = ::Sources::Strategies::Twitter.new(url)
          source.get

          source
        end
      end
    end
  end
end
