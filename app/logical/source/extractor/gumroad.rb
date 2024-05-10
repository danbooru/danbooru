# frozen_string_literal: true

# @see Source::URL::Gumroad
class Source::Extractor
  class Gumroad < Source::Extractor
    def image_urls
      if parsed_url.full_image_url.present?
        [parsed_url.full_image_url]
      elsif api_response["product"].present? # product
        api_response.dig("product", "covers").pluck("original_url")
      elsif artist_commentary_desc.present? # post
        urls = artist_commentary_desc.to_s.parse_html.css("img").pluck("src")
        urls.select { |url| Source::URL::Gumroad.parse(url)&.image_url? }
      end
    end

    def page_url
      parsed_url.page_url || parsed_referer&.page_url
    end

    def profile_url
      if api_response.dig("product", "seller", "profile_url").present? # product
        Source::URL.profile_url(api_response.dig("product", "seller", "profile_url"))
      elsif api_response.dig("creator_profile", "subdomain").present? # post
        "https://#{api_response.dig("creator_profile", "subdomain")}"
      end
    end

    def artist_name
      api_response.dig("product", "seller", "name") || api_response.dig("creator_profile", "name")
    end

    def other_names
      [artist_name].compact_blank
    end

    def artist_commentary_title
      api_response.dig("product", "name")&.strip
    end

    def artist_commentary_desc
      api_response.dig("product", "description_html")&.strip || api_response["message"]&.strip
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc, base_url: "https://www.gumroad.com")&.strip
    end

    memoize def page
      http.cache(1.minute).parsed_get(page_url)
    end

    memoize def api_response
      page&.at("script.js-react-on-rails-component")&.text&.parse_json || {}
    end
  end
end
