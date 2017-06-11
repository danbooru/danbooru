module Downloads
  module RewriteStrategies
    class Pawoo < Base
      def rewrite(url, headers, data = {})
        if Sources::Strategies::Pawoo.url_match?(url)
          source = Sources::Strategies::Pawoo.new(url)
          source.get
          url = source.image_url
        elsif url =~ %r!\Ahttps?://img\.pawoo\.net/media_attachments/files/(\d+/\d+/\d+)/small/([a-z0-9]+\.\w+)\z!i
          url = "https://img.pawoo.net/media_attachments/files/#{$1}/original/#{$2}"
        end

        return [url, headers, data]
      end
    end
  end
end
