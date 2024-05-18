# frozen_string_literal: true

# @see Source::URL::Pinterest
class Source::Extractor::Pinterest < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.candidate_full_image_urls.find { |url| http_exists?(url) } || parsed_url.to_s]
    else
      image_urls_from_api
    end
  end

  def image_urls_from_api
    [api_response.dig("images", "orig", "url")].compact_blank
  end

  def profile_url
    "https://www.pinterest.com/#{username}/" if username.present?
  end

  def profile_urls
    [profile_url, domain_url].compact_blank.uniq
  end

  def display_name
    api_response.dig("native_creator", "full_name")
  end

  def username
    api_response.dig("native_creator", "username")
  end

  def artist_commentary_title
    api_response["title"].presence || api_response.dig("rich_metadata", "title")
  end

  def artist_commentary_desc
    api_response["description"].presence || api_response.dig("rich_metadata", "description")
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def tags
    []
  end

  def domain_url
    api_response.dig("native_creator", "domain_url")
  end

  def pin_id
    parsed_url.pin_id || parsed_referer&.pin_id
  end

  memoize def api_response
    return {} unless pin_id.present?

    # curl -v "https://www.pinterest.com/resource/PinResource/get/?data=%7B%22options%22:%7B%22id%22:%22551409548145105776%22,%22field_set_key%22:%22detailed%22%7D%7D"
    options = { options: { id: pin_id, field_set_key: "detailed" } }
    json = http.cache(1.minute).parsed_get("https://www.pinterest.com/resource/PinResource/get/", params: { data: options.to_json })
    json&.dig("resource_response", "data") || {}
  end
end
