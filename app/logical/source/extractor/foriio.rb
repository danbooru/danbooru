# frozen_string_literal: true

# @see Source::URL::Foriio
class Source::Extractor::Foriio < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.full_image_url]
    else
      work.dig("data", "images")&.pluck("urls")&.pluck("list").to_a.map do |url|
        Source::URL.parse(url).full_image_url || url
      end
    end
  end

  def profile_url
    "https://www.foriio.com/#{username}" if username.present?
  end

  def profile_urls
    [profile_url, work.dig("data", "author", "profile", "twitter_url")].compact_blank
  end

  def display_name
    work.dig("data", "author", "profile", "name")
  end

  def username
    work.dig("data", "author", "screen_name")
  end

  def artist_commentary_title
    work.dig("data", "title")
  end

  def artist_commentary_desc
    work.dig("data", "description")
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def tags
    []
  end

  def work_id
    parsed_url.work_id || parsed_referer&.work_id
  end

  memoize def work
    page_json.dig("works", work_id.to_s) || {}
  end

  memoize def page_json
    script = page&.css("script").to_a.map(&:text).grep(/window.__PRELOADED_STATE__/).first.to_s
    script[/window.__PRELOADED_STATE__ = (.*);$/, 1]&.parse_json || {}
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end
end
