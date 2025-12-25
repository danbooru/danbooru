# frozen_string_literal: true

# @see Source::URL::Zerochan
module Source
  class Extractor
    class Zerochan < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          [api_response[:full]].compact
        end
      end

      def tags
        api_response[:tags].to_a.map do |tag|
          [tag, "https://www.zerochan.net/#{CGI.escape(tag)}"]
        end
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def api_url
        "https://www.zerochan.net/#{work_id}?json" if work_id.present?
      end

      memoize def api_response
        parsed_get(api_url) || {}
      end

      def http
        super.cookies(z_id: credentials[:user_id], z_hash: credentials[:session_cookie])
      end
    end
  end
end
