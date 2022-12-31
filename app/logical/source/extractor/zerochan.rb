# frozen_string_literal: true

# @see Source::URL::Zerochan
module Source
  class Extractor
    class Zerochan < Source::Extractor
      def match?
        Source::URL::Zerochan === parsed_url
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          [api_response[:full]].compact
        end
      end

      def page_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def tags
        api_response[:tags].to_a.map do |tag|
          [tag, "https://www.zerochan.net/#{CGI.escape(tag)}"]
        end
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      memoize def api_response
        return {} if work_id.blank?

        response = http.cache(1.minute).get("https://www.zerochan.net/#{work_id}?json")
        return {} unless response.status == 200

        JSON.parse(response.to_s).with_indifferent_access
      end
    end
  end
end
