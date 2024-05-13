# frozen_string_literal: true

# @see Source::URL::Misskey
# @see https://misskey-hub.net/docs/api/
class Source::Extractor::Misskey < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      note["files"].to_a.pluck("url")
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    if base_url.present? && username.present? && remote_host.present?
      "#{base_url}/@#{username}@#{remote_host}"
    elsif base_url.present? && username.present?
      "#{base_url}/@#{username}"
    end
  end

  def account_url
    "#{base_url}/users/#{user_id}" if base_url.present? && user_id.present? && remote_host.nil?
  end

  def remote_username_url
    "#{remote_instance_url}/@#{username}" if remote_instance_url.present? && username.present?
  end

  def profile_urls
    [profile_url, account_url, remote_username_url].compact
  end

  def username
    user["username"] || parsed_url.username || parsed_referer&.username
  end

  def tag_name
    username.to_s.downcase.gsub(/\A_+|_+\z/, "").squeeze("_").presence
  end

  def artist_name
    user["name"]&.gsub(/:[a-z0-9@_]+:/i, "")&.normalize_whitespace&.squeeze(" ")&.strip # strip emoji
  end

  def other_names
    [artist_name, username].compact.uniq(&:downcase)
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || user["id"]
  end

  def note_id
    parsed_url.note_id || parsed_referer&.note_id
  end

  def play_id
    parsed_url.play_id || parsed_referer&.play_id
  end

  def artist_commentary_title
    if play.present?
      play["title"]
    end
  end

  def artist_commentary_desc
    if ap_api_response.present?
      [ap_api_response["summary"], ap_api_response["content"], *ap_api_response["attachment"].to_a.pluck("name")].compact.join("<br>")
    elsif note.present?
      [note["cw"], note["text"], *note["files"].to_a.pluck("comment")].compact.join("<br>")
    elsif play.present?
      play["summary"]&.gsub("\n", "<br>")
    end
  end

  def tags
    return [] unless base_url.present?

    note["tags"].to_a.map do |tag|
      [tag, "#{origin_instance_url}/tags/#{tag}"]
    end
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: base_url)
  end

  # The base URL of the current instance.
  memoize def base_url
    # Images are usually hosted on a separate domain, so we only take the base URL from the page URL (if present).
    if parsed_url.page_url?
      parsed_url.site
    elsif parsed_referer&.page_url?
      parsed_referer&.site
    end
  end

  # The base URL of the remote instance, if this note came from a remote instance.
  def remote_instance_url
    "https://#{remote_host}" if remote_host.present?
  end

  # The base URL of the instance this note originally came from.
  def origin_instance_url
    remote_instance_url || base_url
  end

  # The remote instance hostname, if this note came from a remote instance.
  def remote_host
    user["host"]
  end

  memoize def user
    note["user"] || play["user"] || {}
  end

  memoize def note
    return {} unless base_url.present? && note_id.present?

    http.cache(1.minute).parsed_post("#{base_url}/api/notes/show##{note_id}", json: { noteId: note_id }) || {}
  end

  memoize def ap_api_response
    return {} unless base_url.present? && note_id.present?

    http.cache(1.minute).headers(accept: "application/ld+json").parsed_get("#{base_url}/notes/#{note_id}") || {}
  end

  memoize def play
    return {} unless base_url.present? && play_id.present?

    http.cache(1.minute).parsed_post("#{base_url}/api/flash/show", json: { flashId: play_id }) || {}
  end
end
