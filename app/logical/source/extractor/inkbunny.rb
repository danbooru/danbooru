# frozen_string_literal: true

# @see Source::URL::Inkbunny
# @see https://wiki.inkbunny.net/wiki/API
class Source::Extractor::Inkbunny < Source::Extractor
  def self.enabled?
    Danbooru.config.inkbunny_session.present?
  end

  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      submission[:files].to_a.pluck(:file_url_full)
    end
  end

  def username
    submission[:username] || parsed_url.username || parsed_referer&.username
  end

  def profile_url
    "https://inkbunny.net/#{username}" if username.present?
  end

  def user_url
    "https://inkbunny.net/user.php?user_id=#{submission[:user_id]}" if submission.present?
  end

  def profile_urls
    [profile_url, user_url].compact
  end

  def artist_commentary_title
    submission[:title]
  end

  def artist_commentary_desc
    submission[:description_bbcode_parsed]
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://inkbunny.net") do |element|
      if element.name == "table"
        mention = element.at ".widget_userNameSmall"
        if mention.present?
          element.name = "a"
          element[:href] = mention[:href]
          element.content = mention.content
        end
      end
    end&.strip
  end

  def tags
    submission[:keywords].to_a.map do |tag|
      [tag[:keyword_name], "https://inkbunny.net/search_process.php?keyword_id=#{tag[:keyword_id]}"]
    end
  end

  def submission_id
    parsed_url.submission_id || parsed_referer&.submission_id
  end

  def submission
    api_response[:submissions].to_a.first || {}
  end

  memoize def api_response
    return {} unless submission_id.present?

    request("https://inkbunny.net/api_submissions.php", show_description_bbcode_parsed: "yes", submission_ids: submission_id)
  end

  # https://wiki.inkbunny.net/wiki/API#Quick_Start_Guide
  # https://wiki.inkbunny.net/wiki/API#Login
  memoize def session_id
    return nil if Danbooru.config.inkbunny_username.blank? || Danbooru.config.inkbunny_password.blank?

    response = http.parsed_get("https://inkbunny.net/api_login.php", params: { username: Danbooru.config.inkbunny_username, password: Danbooru.config.inkbunny_password })

    if response[:error_code].present?
      DanbooruLogger.info("Inkbunny login failed (#{response[:error_code]} #{response[:error_message]})")
      nil
    else
      response[:sid]
    end
  end

  memoize def cached_session_id
    Cache.get("inkbunny-session-id", 24.hours, skip_nil: true) do
      session_id
    end
  end

  def clear_cached_session_id!
    flush_cache # clear memoized session id
    Cache.delete("inkbunny-session-id")
  end

  def request(url, **params)
    response = http.cache(1.minute).parsed_get(url, params: params.merge(sid: cached_session_id)) || {}

    # https://wiki.inkbunny.net/wiki/API#Error_Codes
    # 2 - Invalid Session ID sent as variable 'sid'.
    # This error will appear if you send a Session ID (sid) that is not valid, has been logged out or has expired.
    if response[:error_code] == 2
      DanbooruLogger.info("Inkbunny session ID stale; logging in again")
      clear_cached_session_id!
      response = http.cache(1.minute).parsed_get(url, params: params.merge(sid: cached_session_id)) || {}
    end

    response
  end
end
