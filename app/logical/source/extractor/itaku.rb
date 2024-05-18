# frozen_string_literal: true

# @see Source::URL::Itaku
class Source::Extractor::Itaku < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.candidate_full_image_urls.to_a.find { |url| http_exists?(url) } || url]
    else
      [api_response.dig("video", "video") || api_response["image"]].compact
    end
  end

  def profile_url
    "https://itaku.ee/#{username}" if username.present?
  end

  def display_name
    api_response["owner_displayname"]
  end

  def username
    api_response["owner_username"]
  end

  def artist_commentary_title
    api_response["title"]
  end

  def artist_commentary_desc
    api_response["description"]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def tags
    api_response["tags"].to_a.pluck("name").map do |tag|
      [tag, "https://itaku.ee/home/images?tags=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def image_id
    parsed_url.image_id || parsed_referer&.image_id
  end

  memoize def api_response
    return {} unless image_id.present?

    # curl https://itaku.ee/api/galleries/images/576357/ | jq
    http.cache(1.minute).parsed_get("https://itaku.ee/api/galleries/images/#{image_id}/") || {}
  end
end
