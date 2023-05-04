# frozen_string_literal: true

# @see Source::URL::Booth
class Source::Extractor
  class Booth < Source::Extractor
    def match?
      Source::URL::Booth === parsed_url
    end

    def image_urls
      if parsed_url.full_image_url?
        [parsed_url.to_s]
      elsif parsed_url.image_url?
        [find_right_extension(parsed_url)]
      else
        api_response["images"].to_a.pluck("original").map { |url| find_right_extension(Source::URL.parse(url)) }
      end
    end

    def profile_url
      parsed_url.profile_url || parsed_referer&.profile_url || Source::URL.profile_url(api_response.dig("shop", "url"))
    end

    def tag_name
      api_response.dig("shop", "subdomain")
    end

    def artist_name
      api_response.dig("shop", "name")
    end

    def artist_commentary_title
      api_response["name"]
    end

    def artist_commentary_desc
      api_response["description"]
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc).strip
    end

    def tags
      api_response["tags"].to_a.map do |tag|
        [tag["name"], tag["url"]]
      end
    end

    def page_url
      parsed_url.page_url || parsed_referer&.page_url
    end

    memoize def api_response
      http.cache(1.minute).cookies(adult: "t").parsed_get(parsed_url.api_url) || {}
    end

    def find_right_extension(parsed_url)
      extensions = %w[png jpg jpeg]
      candidates = extensions.map { |ext| parsed_url.full_image_url_for(ext) }

      chosen_url = candidates.find { |candidate| http_exists?(candidate) }
      chosen_url || parsed_url.to_s
    end
  end
end
