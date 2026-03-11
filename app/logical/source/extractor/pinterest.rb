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
    api_response["title"].presence || api_response.dig("rich_metadata", "title").presence || page_pin_data["unauthOnPageTitle"].presence || page_pin_data["closeupUnifiedTitle"].presence
  end

  def artist_commentary_desc
    api_response["description"].presence || api_response.dig("rich_metadata", "description").presence || page_pin_data["unauthOnPageDescription"].presence
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def published_at
    Time.parse(api_response["created_at"]).utc if !parsed_url.image_url? && api_response["created_at"].present?
  end

  def tags
    api_response["hashtags"].to_a.filter_map do |hashtag|
      [hashtag.delete_prefix("#"), "https://www.pinterest.com/search/pins/?q=#{Danbooru::URL.escape(hashtag)}"]
    end
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
    headers = { "X-Pinterest-PWS-Handler": "www/[username].js" }
    json = http.cache(1.minute).headers(headers).parsed_get("https://www.pinterest.com/resource/PinResource/get/", params: { data: options.to_json })
    json&.dig("resource_response", "data") || {}
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  memoize def page_pin_data
    # Example: window.__PWS_RELAY_REGISTER_COMPLETED_REQUEST__("...", {"data": {...}});
    script = page&.at('script[data-relay-completed-request="true"]:contains("__PWS_RELAY_REGISTER_COMPLETED_REQUEST__")')
    payload = script&.text.to_s[/window\.__PWS_RELAY_REGISTER_COMPLETED_REQUEST__\([^,]+,\s*(\{.*\})\);\s*\z/m, 1]
    payload&.parse_json&.dig("data", "v3GetPinQueryv2", "data") || {}
  end
end
