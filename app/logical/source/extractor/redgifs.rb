# frozen_string_literal: true

# @see Source::URL::Redgifs
class Source::Extractor::Redgifs < Source::Extractor
  def image_urls
    # If this is a sample image or an expired image URL, get a better image URL from the API.
    if parsed_url.image_url? && image_urls_from_api.present?
      image_url = image_urls_from_api.find { |url| Source::URL.parse(url)&.try(:gif_id) == gif_id }
      [image_url].compact
    # If this is a single page from an image gallery, then get just that image rather than the whole gallery.
    # Ex: https://www.redgifs.com/watch/jauntyhandmadepoodle
    elsif gif_id.present? && !cover_gif?
      image_url = image_urls_from_api.find { |url| Source::URL.parse(url)&.try(:gif_id) == gif_id }
      [image_url].compact
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      image_urls_from_api
    end
  end

  memoize def image_urls_from_api
    gifs = gallery_id.present? ? gallery[:gifs].to_a : [gif].compact_blank

    gifs.map do |gif|
      Source::URL.parse(gif.dig(:urls, :hd)).file_url
    end
  end

  def page_url
    if cover_gif.present?
      "https://www.redgifs.com/watch/#{cover_gif[:id]}"
    else
      parsed_url.page_url || parsed_referer&.page_url
    end
  end

  def profile_url
    "https://www.redgifs.com/users/#{username}" if username.present?
  end

  def display_name
    user["name"]
  end

  def username
    parsed_url.username || parsed_referer&.username || user[:username]
  end

  def tags
    tags = gif[:tags].to_a | cover_gif[:tags].to_a
    tags = tags.map do |tag|
      [tag, "https://www.redgifs.com/gifs/#{Danbooru::URL.escape(tag.downcase.tr(" ", "-"))}"]
    end

    niches = gif[:niches].to_a | cover_gif[:niches].to_a
    niches = niches.map do |niche|
      [niche, "https://www.redgifs.com/niches/#{Danbooru::URL.escape(niche)}"]
    end

    [*tags, *niches]
  end

  def artist_commentary_title
  end

  def artist_commentary_desc
    cover_gif[:description] || gif[:description]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def gif_id
    parsed_url.gif_id || parsed_referer&.gif_id
  end

  def gallery_id
    gif[:gallery]
  end

  def gif
    api_gif[:gif] || {}
  end

  def user
    api_gif[:user] || {}
  end

  # True if this is the first post in the gallery. False if this is not the first post, or if this is not part of a gallery.
  def cover_gif?
    gallery_id.present? && gif_id == cover_gif[:id]
  end

  # The cover gif is the first post in the gallery, if this post is part of a gallery. The cover post contains the commentary and tags for the gallery.
  def cover_gif
    gallery[:gifs]&.first || {}
  end

  memoize def gallery
    return {} unless gallery_id.present?

    request("https://api.redgifs.com/v2/gallery/#{gallery_id}") || {}
  end

  memoize def api_gif
    return {} unless gif_id.present?

    # https://api.redgifs.com/docs/index.html#operations-gifs-watch_v2
    request("https://api.redgifs.com/v2/gifs/#{gif_id}", views: "yes", users: "yes", niches: "yes") || {}
  end

  def request(url, **params)
    response = http.headers(Authorization: "Bearer #{cached_bearer_token}").cache(1.minute).get(url, params:)

    if response.status.code == 401
      clear_cached_bearer_token!
      response = http.headers(Authorization: "Bearer #{cached_bearer_token}").cache(1.minute).get(url, params:)
    end

    response.parse
  end

  def clear_cached_bearer_token!
    flush_cache # clear memoized bearer token
    Cache.delete("redgifs-bearer-token")
  end

  memoize def cached_bearer_token
    Cache.get("redgifs-bearer-token", 20.hours, skip_nil: true) do
      bearer_token
    end
  end

  def bearer_token
    # This token is tied to your IP and user agent and lasts for 24 hours. Requesting too many tokens may get you IP banned.
    # https://github.com/Redgifs/api/wiki/Temporary-tokens
    http.parsed_get("https://api.redgifs.com/v2/auth/temporary")&.dig(:token)
  end
end
