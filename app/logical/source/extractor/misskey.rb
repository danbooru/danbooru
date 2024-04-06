# frozen_string_literal: true

# @see Source::URL::Misskey
# @see https://misskey-hub.net/docs/api/
class Source::Extractor::Misskey < Source::Extractor
  def match?
    Source::URL::Misskey === parsed_url
  end

  def domain
    site_name.downcase
  end

  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      api_response.dig("files").to_a.pluck("url")
    end
  end

  def page_url
    if note_id.present?
      "https://#{domain}/notes/#{note_id}"
    end
  end

  def profile_url
    "https://#{domain}/@#{username}" if username.present?
  end

  def account_url
    "https://#{domain}/users/#{user_id}" if user_id.present?
  end

  def profile_urls
    [profile_url, account_url].compact
  end

  def username
    api_response.dig("user", "username") || username_from_url
  end

  def username_from_url
    parsed_url.username || parsed_referer&.username
  end

  def tag_name
    username
  end

  def artist_name
    api_response.dig("user", "name").presence
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || api_response.dig("user", "id")
  end

  def note_id
    parsed_url.note_id || parsed_referer&.note_id
  end

  def artist_commentary_desc
    if ap_api_response.present?
      [ap_api_response["summary"], ap_api_response["content"]]
    elsif api_response.present?
      [api_response["cw"], api_response["text"]]
    else
      []
    end.compact.join("<br>")
  end

  def tags
    api_response.dig("tags").to_a.map do |tag|
      [tag, "https://#{domain}/tags/#{tag}"]
    end
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://#{domain}")&.strip
  end

  memoize def api_response
    return {} unless note_id.present?

    http.cache(1.minute).parsed_post("https://#{domain}/api/notes/show##{note_id}", json: { noteId: note_id }) || {}
  end

  memoize def ap_api_response
    return {} unless note_id.present?

    http.cache(1.minute).headers(accept: "application/ld+json").parsed_get("https://#{domain}/notes/#{note_id}") || {}
  end

end
