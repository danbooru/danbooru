# frozen_string_literal: true

# @see Source::URL::Civitai
class Source::Extractor
  class Civitai < Source::Extractor
    def match?
      Source::URL::Civitai === parsed_url
    end

    def image_urls
      if image_uuid.present? && width.present? && image_name.present?
        ["https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/#{image_uuid}/original=true"]
      else
        []
      end
    end

    def page_url
      "https://civitai.com/images/#{image_id}" if image_id.present?
    end

    def artist_name
      user_json["username"]
    end

    def profile_url
      "https://civitai.com/user/#{artist_name}" if artist_name.present?
    end

    memoize def html_response
      return nil unless page_url.present?
      response = http.cache(1.minute).get(page_url)

      return nil unless response.status == 200
      response.parse
    end

    memoize def next_data
      JSON.parse(html_response&.at("#__NEXT_DATA__") || "{}").dig("props", "pageProps", "trpcState", "json") || {}
    end

    def image_id
      parsed_url&.image_id || parsed_referer&.image_id
    end

    def image_uuid
      next_data.dig("queries", 0, "state", "data", "url")
    end

    def image_name
      next_data.dig("queries", 0, "state", "data", "name")
    end

    def image_metadata
      next_data.dig("queries", 0, "state", "data", "meta").to_h
    end

    def user_json
      next_data.dig("queries", 0, "state", "data", "user").to_h
    end

    def width
      next_data.dig("queries", 0, "state", "data", "width")
    end
  end
end
