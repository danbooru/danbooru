# frozen_string_literal: true

# @see Source::URL::Bluesky
class Source::Extractor::Bluesky < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.full_image_url]
    else
      image_urls_from_api
    end
  end

  def image_urls_from_api
    embed = api_response&.dig("thread", "post", "record", "embed").to_h

    if embed["$type"] == "app.bsky.embed.recordWithMedia"
      embed = embed["media"].to_h
    end

    images = if embed["$type"] == "app.bsky.embed.images"
      embed["images"]
    end.to_a

    images.map do |image|
      image_cid = image.dig("image", "ref", "$link") || image.dig("image", "cid")
      "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=#{user_did}&cid=#{image_cid}"
    end
  end

  def page_url
    "#{account_url || profile_url}/post/#{post_id}" if post_id.present?
  end

  def profile_url
    "https://bsky.app/profile/#{user_handle}" if user_handle.present?
  end

  def account_url
    "https://bsky.app/profile/#{user_did}" if user_did.present?
  end

  def profile_urls
    [profile_url, account_url].compact
  end

  def username
    # ixy.bsky.social -> ixy
    user_handle.to_s.split(".").first
  end

  def display_name
    api_response&.dig("thread", "post", "author", "displayName")
  end

  def user_handle
    user_handle_from_api || user_handle_from_url
  end

  def user_handle_from_api
    api_response&.dig("thread", "post", "author", "handle")
  end

  def user_handle_from_url
    parsed_url.user_handle || parsed_referer&.user_handle
  end

  def user_did
    user_did_from_api || user_did_from_url
  end

  def user_did_from_url
    parsed_url.user_did || parsed_referer&.user_did
  end

  # https://www.docs.bsky.app/docs/api/com-atproto-identity-resolve-handle
  memoize def user_did_from_api
    return unless user_handle_from_url.present?

    response = http.cache(1.minute).parsed_get(
      "https://bsky.social/xrpc/com.atproto.identity.resolveHandle",
      params: { handle: user_handle_from_url }
    ) || {}
    response["did"]
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def artist_commentary_desc
    api_response&.dig("thread", "post", "record", "text")
  end

  def tags
    api_response&.dig("thread", "post", "record", "facets").to_a.pluck("features").flatten.select do |f|
      f["$type"] == "app.bsky.richtext.facet#tag"
    end.pluck("tag").map do |tag|
      [tag, "https://bsky.app/search"]
    end
  end

  # https://www.docs.bsky.app/docs/api/app-bsky-feed-get-post-thread
  memoize def api_response
    return {} unless post_id.present?

    request(
      "https://bsky.social/xrpc/app.bsky.feed.getPostThread",
      uri: "at://#{user_did}/app.bsky.feed.post/#{post_id}",
      depth: 0,
      parentHeight: 0,
    )
  end

  # https://www.docs.bsky.app/docs/api/com-atproto-server-create-session
  memoize def access_token
    return nil if Danbooru.config.bluesky_identifier.blank? || Danbooru.config.bluesky_password.blank?

    response = http.parsed_post(
      "https://bsky.social/xrpc/com.atproto.server.createSession",
      json: { identifier: Danbooru.config.bluesky_identifier, password: Danbooru.config.bluesky_password }
    ).to_h

    if response["error"].present?
      DanbooruLogger.info("Bluesky login failed (#{response["message"]} #{response["message"]})")
      nil
    else
      response["accessJwt"]
    end
  end

  memoize def cached_access_token
    Cache.get("bluesky-access-token", 1.hours, skip_nil: true) do
      access_token
    end
  end

  def clear_cached_access_token!
    flush_cache # clear memoized access token
    Cache.delete("bluesky-access-token")
  end

  def request(url, **params)
    response = http.cache(1.minute).headers(Authorization: "Bearer #{cached_access_token}").get(url, params: params).parse

    if response["error"].in?(%w[InvalidToken ExpiredToken])
      DanbooruLogger.info("Bluesky access token stale; logging in again")
      clear_cached_access_token!
      response = http.cache(1.minute).headers(Authorization: "Bearer #{cached_access_token}").get(url, params: params).parse
    end

    response
  end
end
