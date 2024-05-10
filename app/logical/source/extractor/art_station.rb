# frozen_string_literal: true

# @see Source::URL::ArtStation
class Source::Extractor
  class ArtStation < Source::Extractor
    def image_urls
      if parsed_url.image_url?
        [asset_url(url)]
      else
        image_urls_from_api
      end
    end

    def page_url
      if tag_name.present? && project_id.present?
        "https://#{tag_name}.artstation.com/projects/#{project_id}"
      elsif project_id.present?
        "https://www.artstation.com/artwork/#{project_id}"
      end
    end

    def profile_url
      "https://www.artstation.com/#{tag_name}" if tag_name.present?
    end

    def artist_name
      api_response.dig(:user, :full_name)
    end

    def tag_name
      api_response.dig(:user, :username) || parsed_url.username || parsed_referer&.username
    end

    def artist_commentary_title
      api_response[:title]
    end

    def artist_commentary_desc
      api_response[:description]
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc, base_url: "https://www.artstation.com")&.strip
    end

    def tags
      api_response[:tags].to_a.map do |tag|
        [tag, "https://www.artstation.com/search?q=#{Danbooru::URL.escape(tag)}"]
      end
    end

    def image_urls_from_api
      api_response[:assets].to_a.filter_map do |asset|
        if asset[:asset_type] == "image"
          asset_url(asset[:image_url])
        elsif asset[:asset_type] == "video_clip"
          url = asset[:player_embedded].to_s.parse_html.at("iframe")&.attr("src")
          page = http.cache(1.minute).parsed_get(url)
          page&.at("video source")&.attr("src")
        end
      end
    end

    def project_id
      parsed_url.work_id || parsed_referer&.work_id
    end

    def api_url
      "https://www.artstation.com/projects/#{project_id}.json" if project_id.present?
    end

    def http
      super.headers("User-Agent": "Mozilla/5.0 (compatible; Discordbot/2.0; +https://discordapp.com)")
    end

    memoize def api_response
      http.cache(1.minute).parsed_get(api_url) || {}
    end

    def asset_url(url)
      parsed_url = Source::URL.parse(url)

      image_sizes = %w[original 4k large medium small]
      urls = image_sizes.map { |size| parsed_url.full_image_url(size) }

      chosen_url = urls.find { |u| http_exists?(u) }
      chosen_url || url
    end
  end
end
