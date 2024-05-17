# frozen_string_literal: true

# @see Source::URL::Anifty
class Source::Extractor
  class Anifty < Source::Extractor
    def image_urls
      if parsed_url.image_url?
        [parsed_url.full_image_url].compact
      else
        [api_response["imageURL"]].compact
      end
    end

    def profile_url
      if username.present?
        "https://anifty.jp/@#{username}"
      else
        parsed_url.profile_url || parsed_referer&.profile_url
      end
    end

    def username
      api_response.dig("creator", "userName") || artist_api_response["userName"] || parsed_url.username || parsed_referer&.username
    end

    def display_name
      api_response.dig("creator", "displayName") || artist_api_response.dig("creatorProfile", "nameEN")
    end

    def other_names
      [display_name, username, api_response.dig("creator", "displayNameJA"), artist_api_response.dig("creatorProfile", "nameJA")].compact_blank.uniq(&:downcase)
    end

    def artist_commentary_title
      api_response["title"] || api_response["titleJA"]
    end

    def artist_commentary_desc
      api_response["description"] || api_response["descriptionJA"]
    end

    def tags
      # anifty marketplace uses XHR requests to filter by tags, so there's no url to get
      api_response["tags"].to_a.map do |tag|
        [tag["name"], "https://anifty.jp/marketplace"]
      end
    end

    def page_url
      if page_url_from_parsed_urls.present?
        page_url_from_parsed_urls
      elsif work_id.present?
        "https://anifty.jp/creations/#{work_id}"
      end
    end

    def page_url_from_parsed_urls
      parsed_url.page_url || parsed_referer&.page_url
    end

    def work_id
      parsed_url.work_id || parsed_referer&.work_id || work_id_from_artist_api
    end

    def work_id_from_artist_api
      # Try to get the work ID from the artist's list of tokens
      return nil unless parsed_url.file.present? && parsed_url.work_type == "creation"
      artist_api_response["createdTokens"].to_a.map do |token|
        if Source::URL.parse(token["imageURL"])&.file == parsed_url.file
          return token["creationID"]
        end
      end
      nil
    end

    def artist_hash
      parsed_url.artist_hash || parsed_referer&.artist_hash
    end

    memoize def api_response
      return {} if work_id.blank?

      http.cache(1.minute).parsed_get("https://asia-northeast1-anifty-59655.cloudfunctions.net/api/v2/creations/#{work_id}") || {}
    end

    memoize def artist_api_response
      return {} if artist_hash.blank?

      http.cache(1.minute).parsed_get("https://asia-northeast1-anifty-59655.cloudfunctions.net/api/users/#{artist_hash}") || {}
    end
  end
end
