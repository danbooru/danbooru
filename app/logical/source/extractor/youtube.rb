# frozen_string_literal: true

# @see Source::URL::Youtube
class Source::Extractor::Youtube < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif community_post_id.present?
      # A community post with multiple images has "postMultiImageRenderer"; a post with a single image doesn't.
      # Single image: https://www.youtube.com/post/UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf
      # Multiple images: https://www.youtube.com/post/UgkxBkJE1Eu_6S9sADZF5IuK5MPRSWf4VVz3
      attachments = community_post.dig("backstageAttachment", "postMultiImageRenderer", "images") || [community_post["backstageAttachment"]].compact
      attachments.map do |attachment|
        url = attachment.dig("backstageImageRenderer", "image", "thumbnails", 0, "url")
        Source::URL.parse(url).try(:full_image_url) || url
      end.compact
    else
      []
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    handle_url
  end

  def profile_urls
    [handle_url, channel_url].compact
  end

  def artist_name
    community_post.dig("authorText", "runs", 0, "text")
  end

  def tag_name
    handle.to_s.downcase.gsub(/\A_+|_+\z/, "").squeeze("_").presence
  end

  def other_names
    [artist_name, handle].compact_blank.uniq(&:downcase)
  end

  def tags
    []
  end

  def artist_commentary_title
  end

  def artist_commentary_desc
    community_post.dig("contentText", "runs").to_a.pluck("text").join
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def community_post_id
    # parsed_url may be a Source::URL::Google instead of Source::URL::Youtube, which is why we use
    # `parsed_url.try(:post_id)` instead of `parsed_url.post_id` (`try` won't fail if the method doesn't exist).
    #
    # This happens when uploading lh*.googleusercontent.com album cover URLs. *.googleusercontent.com URLs are
    # handled by Source::URL::Google instead of Source::URL::Youtube because they're not used just by Youtube.
    parsed_url.try(:post_id) || parsed_referer.try(:post_id)
  end

  def channel_id
    parsed_url.try(:channel_id) || parsed_referer.try(:channel_id) || community_post.dig("authorEndpoint", "browseEndpoint", "browseId")
  end

  def handle
    # "/@Mirae_Somang" -> "Mirae_Somang"
    parsed_url.try(:handle) || parsed_referer.try(:handle) || community_post.dig("authorEndpoint", "browseEndpoint", "canonicalBaseUrl")&.delete_prefix("/@")
  end

  def channel_url
    "https://www.youtube.com/channel/#{channel_id}" if channel_id.present?
  end

  def handle_url
    "https://www.youtube.com/@#{handle}" if handle.present?
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url) if community_post_id.present?
  end

  memoize def community_post_json
    page&.at('script[text()*="ytInitialData"]')&.text&.slice(/{.*}/)&.parse_json || {}
  end

  memoize def community_post
    community_post_json.dig(
      "contents", "twoColumnBrowseResultsRenderer", "tabs", 0, "tabRenderer", "content", "sectionListRenderer",
      "contents", 0, "itemSectionRenderer", "contents", 0, "backstagePostThreadRenderer", "post", "backstagePostRenderer"
    ) || {}
  end
end
