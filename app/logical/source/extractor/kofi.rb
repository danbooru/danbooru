# frozen_string_literal: true

# @see Source::URL::Kofi
class Source::Extractor::Kofi < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      []
    end
  end

  def profile_url
    username_url || user_id_url
  end

  def profile_urls
    [username_url, user_id_url].compact
  end

  def username_url
    "https://ko-fi.com/#{username}" if username.present?
  end

  def user_id_url
    "https://ko-fi.com/#{user_id}" if user_id.present?
  end

  def display_name
    profile_page&.at(".kfds-text-limit-profilename-mobile span")&.text
  end

  def username
    parsed_url.username || parsed_referer&.username || profile_page&.at('link[rel="canonical"]')&.attr(:href)&.then { |url| Source::URL.parse(url)&.username }
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || profile_page&.at('a[href^="/home/reportpage"]')&.attr(:href)&.delete_prefix("/home/reportpage?pageid=")
  end

  def tags
    []
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://ko-fi.com")
  end

  def profile_id
    parsed_url.username || parsed_referer&.username || parsed_url.user_id || parsed_referer&.user_id
  end

  memoize def profile_page
    http.cache(1.minute).parsed_get("https://ko-fi.com/#{profile_id}") if profile_id.present?
  end
end
