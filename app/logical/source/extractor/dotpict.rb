# frozen_string_literal: true

# @see Source::URL::Dotpict
class Source::Extractor::Dotpict < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.candidate_full_image_urls.present?
      [parsed_url.candidate_full_image_urls.find { |url| http_exists?(url) } || url.to_s]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      [api_response.dig("data", "work", "image_url")].compact
    end
  end

  def profile_url
    "https://dotpict.net/users/#{user_id}" if user_id.present?
  end

  def profile_urls
    [profile_url, account_url].compact_blank.uniq
  end

  def display_name
    api_response.dig("data", "work", "user", "name")&.strip
  end

  def username
    api_response.dig("data", "work", "user", "account").presence
  end

  def artist_commentary_title
    api_response.dig("data", "work", "title")
  end

  def artist_commentary_desc
    api_response.dig("data", "work", "text")
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def tags
    api_response.dig("data", "work", "tags").to_a.map do |tag|
      [tag, "https://dotpict.net/search/works/tag/#{Danbooru::URL.escape(tag)}"]
    end
  end

  def account_url
    # https://dotpict.net/@ycsawampfp
    api_response.dig("data", "work", "user", "share_url")
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || api_response.dig("data", "work", "user", "id")
  end

  def work_id
    parsed_url.work_id || parsed_referer&.work_id
  end

  memoize def api_response
    # curl "https://api.dotpicko.net/works/4814277/detail" | jq
    http.cache(1.minute).parsed_get("https://api.dotpicko.net/works/#{work_id}/detail") || {}
  end
end
