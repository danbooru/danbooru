# frozen_string_literal: true

# @see Source::URL::ArtStation
class Source::Extractor
  class ArtStation < Source::Extractor
    def match?
      Source::URL::ArtStation === parsed_url
    end

    def image_urls
      if parsed_url.image_url?
        [asset_url(url)]
      else
        image_urls_from_api
      end
    end

    def page_url
      return nil if project_id.blank?

      if artist_name.present?
        "https://#{artist_name}.artstation.com/projects/#{project_id}"
      else
        "https://www.artstation.com/artwork/#{project_id}"
      end
    end

    def profile_url
      return nil if artist_name.blank?
      "https://www.artstation.com/#{artist_name}"
    end

    def artist_name
      artist_name_from_url || api_response.dig(:user, :username)
    end

    def artist_commentary_title
      api_response[:title]
    end

    def artist_commentary_desc
      api_response[:description]
    end

    def dtext_artist_commentary_desc
      ActionView::Base.full_sanitizer.sanitize(artist_commentary_desc)
    end

    def tags
      api_response[:tags].to_a.map do |tag|
        [tag, "https://www.artstation.com/search?q=#{Danbooru::URL.escape(tag)}"]
      end
    end

    def image_urls_from_api
      api_response[:assets].to_a.map do |asset|
        if asset[:asset_type] == "image"
          asset_url(asset[:image_url])
        elsif asset[:asset_type] == "video_clip"
          url = Nokogiri::HTML5.parse(asset[:player_embedded]).at("iframe").attr("src")
          next if url.nil?

          response = http.cache(1.minute).get(url)
          next if response.status != 200

          response.parse.at("video source").attr("src")
        end
      end.compact
    end

    def artist_name_from_url
      parsed_url.username || parsed_referer&.username
    end

    def project_id
      parsed_url.work_id || parsed_referer&.work_id
    end

    def api_response
      return {} if project_id.blank?

      resp = http.cache(1.minute).get("https://www.artstation.com/projects/#{project_id}.json")
      return {} if resp.code != 200

      resp.parse.with_indifferent_access
    end
    memoize :api_response

    def asset_url(url)
      parsed_url = Source::URL.parse(url)

      image_sizes = %w[original 4k large medium small]
      urls = image_sizes.map { |size| parsed_url.full_image_url(size) }

      chosen_url = urls.find { |u| http_exists?(u) }
      chosen_url || url
    end
  end
end
