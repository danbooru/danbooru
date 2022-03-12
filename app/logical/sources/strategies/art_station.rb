# frozen_string_literal: true

# @see Source::URL::ArtStation
module Sources::Strategies
  class ArtStation < Base
    def match?
      Source::URL::ArtStation === parsed_url
    end

    def image_urls
      @image_urls ||= image_urls_sub.map { |asset| asset_url(asset, :largest) }
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
        [tag, "https://www.artstation.com/search?q=" + CGI.escape(tag)]
      end
    end

    def normalize_for_source
      return if project_id.blank?

      if artist_name_from_url.present?
        "https://#{artist_name_from_url}.artstation.com/projects/#{project_id}"
      else
        "https://www.artstation.com/artwork/#{project_id}"
      end
    end

    def image_urls_sub
      if parsed_url.image_url?
        [url]
      else
        api_response[:assets].to_a.select { |asset| asset[:asset_type] == "image" }.pluck(:image_url)
      end
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

    def asset_url(url, size)
      parsed_url = Source::URL.parse(url)

      image_sizes = %w[original 4k large medium small]
      urls = image_sizes.map { |size| parsed_url.full_image_url(size) }
      urls = urls.reverse if size == :smallest

      chosen_url = urls.find { |url| http_exists?(url) }
      chosen_url || url
    end
  end
end
