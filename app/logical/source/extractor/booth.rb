# frozen_string_literal: true

# @see Source::URL::Booth
class Source::Extractor
  class Booth < Source::Extractor
    def image_urls
      if parsed_url.full_image_url.present?
        [parsed_url.full_image_url]
      elsif parsed_url.candidate_full_image_urls.present?
        [parsed_url.candidate_full_image_urls.find { |url| http_exists?(url) } || url.to_s]
      elsif parsed_url.image_url?
        [parsed_url.to_s]
      else
        api_response["images"].to_a.pluck("original").flat_map do |url|
          Source::Extractor::Booth.new(url).image_urls
        end
      end
    end

    def profile_url
      parsed_url.profile_url || parsed_referer&.profile_url || Source::URL.profile_url(api_response.dig("shop", "url"))
    end

    def username
      api_response.dig("shop", "subdomain")
    end

    def display_name
      api_response.dig("shop", "name")
    end

    def artist_commentary_title
      api_response["name"]
    end

    def artist_commentary_desc
      api_response["description"]
    end

    def dtext_artist_commentary_desc
      DText.from_plaintext(artist_commentary_desc)
    end

    def tags
      api_response["tags"].to_a.map do |tag|
        [tag["name"], tag["url"]]
      end
    end

    memoize def api_response
      http.cache(1.minute).cookies(adult: "t").parsed_get(parsed_url.api_url) || {}
    end
  end
end
