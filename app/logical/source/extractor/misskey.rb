# frozen_string_literal: true

# @see Source::URL::Misskey
# @see https://misskey-hub.net/docs/api/
class Source::Extractor::Misskey < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      api_response.dig("files").to_a.pluck("url")
    end
  end

  def page_url
    "#{base_url}/notes/#{note_id}" if base_url.present? && note_id.present?
  end

  def profile_url
    "#{base_url}/@#{username}" if base_url.present? && username.present?
  end

  def account_url
    "#{base_url}/users/#{user_id}" if base_url.present? && user_id.present?
  end

  def profile_urls
    [profile_url, account_url].compact
  end

  def username
    api_response.dig("user", "username") || parsed_url.username || parsed_referer&.username
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
    return [] unless base_url.present?

    api_response.dig("tags").to_a.map do |tag|
      [tag, "#{base_url}/tags/#{tag}"]
    end
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: base_url)
  end

  memoize def base_url
    # Images are usually hosted on a separate domain, so we only take the base URL from the page URL (if present).
    if parsed_url.page_url?
      parsed_url.site
    elsif parsed_referer&.page_url?
      parsed_referer&.site
    end
  end

  memoize def api_response
    return {} unless base_url.present? && note_id.present?

    http.cache(1.minute).parsed_post("#{base_url}/api/notes/show##{note_id}", json: { noteId: note_id }) || {}
  end

  memoize def ap_api_response
    return {} unless base_url.present? && note_id.present?

    http.cache(1.minute).headers(accept: "application/ld+json").parsed_get("#{base_url}/notes/#{note_id}") || {}
  end
end
