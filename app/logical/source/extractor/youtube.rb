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
      attachment = community_post["backstageAttachment"]
      attachments = attachment&.dig("postMultiImageRenderer", "images") || [attachment].compact
      attachments.filter_map do |attachment|
        url = attachment.dig("backstageImageRenderer", "image", "thumbnails", 0, "url")
        Source::URL.parse(url).try(:full_image_url) || url
      end
    else
      []
    end
  end

  def profile_url
    handle_url
  end

  def profile_urls
    [handle_url, channel_url].compact
  end

  def display_name
    community_post.dig("authorText", "runs", 0, "text") || video_owner.dig("title", "runs", 0, "text")
  end

  def username
    handle
  end

  def tags
    post_commands = community_post.dig(:contentText, :runs).to_a.pluck(:navigationEndpoint)
    video_commands = video_description[:commandRuns].to_a.map { |run| run.dig(:onTap, :innertubeCommand) }

    (post_commands + video_commands).compact.filter_map do |command|
      url = command.dig(:commandMetadata, :webCommandMetadata, :url)&.then { |u| Danbooru::URL.unescape(u) }
      next unless url&.starts_with?("/hashtag/")

      [url.delete_prefix("/hashtag/"), "https://www.youtube.com#{url}"]
    end
  end

  def artist_commentary_title
    video_primary_info.dig(:title, :runs)&.pluck(:text)&.join
  end

  def artist_commentary_desc
    community_post[:contentText]&.to_json || video_commentary_desc
  end

  def dtext_artist_commentary_desc
    html = community_post.present? ? html_artist_commentary_desc : video_commentary_desc
    DText.from_html(html, base_url: "https://www.youtube.com")
  end

  # The description is plain text, with links given as UTF-16 offsets into the text:
  #
  #   "content": "Twitter :   / sechihyeo  \n#bluesechi",
  #   "commandRuns": [{ "startIndex": 10, "length": 15, "onTap": { "innertubeCommand": {...} } }, ...]
  def video_commentary_desc
    return if video_description[:content].nil?

    text = video_description[:content].encode("UTF-16LE")
    runs = video_description[:commandRuns].to_a.sort_by { |run| run[:startIndex].to_i }
    html = +""
    pos = 0

    runs.each do |run|
      start, length = run[:startIndex].to_i, run[:length].to_i
      next if start < pos || length <= 0

      html << video_text_to_html(text.byteslice(pos * 2, (start - pos) * 2))
      link_text = video_text_to_html(text.byteslice(start * 2, length * 2))
      html << video_link_to_html(run.dig(:onTap, :innertubeCommand), link_text)
      pos = start + length
    end

    html << video_text_to_html(text.byteslice((pos * 2)..))
  end

  def video_text_to_html(utf16_text)
    # Remove the U+202A and U+202C bidi marks around mentions ("\u202A@vensen5150\u202C").
    text = utf16_text.to_s.encode("UTF-8", invalid: :replace, undef: :replace).delete("\u202A\u202C")
    CGI.escapeHTML(text).gsub("\r\n", "\n").delete("\r").gsub("\n", "<br>")
  end

  def video_link_to_html(command, link_text)
    url = command&.dig(:commandMetadata, :webCommandMetadata, :url).to_s

    if url.starts_with?("/")
      # Remove the random tracking param from video links ("/watch?v=EpEO2bBtYds&pp=0gcJCR0AztywvtLA").
      target = Danbooru::URL.parse("https://www.youtube.com#{Danbooru::URL.unescape(url)}")&.without_params(:pp).to_s
      %{<a href="#{CGI.escapeHTML(target)}">#{link_text}</a>}
    elsif url.starts_with?("https://www.youtube.com/redirect")
      # https://www.youtube.com/redirect?event=video_description&redir_token=...&q=https%3A%2F%2Fx.com%2Filekkim
      target = CGI.escapeHTML(Danbooru::URL.parse(url)&.params&.dig(:q).to_s)

      if target.match?(%r{\Ahttps?://})
        %{<a href="#{target}">#{target}</a>}
      else
        link_text
      end
    else
      link_text
    end
  end

  def html_artist_commentary_desc
    community_post.dig(:contentText, :runs).to_a.map do |run|
      text = CGI.escapeHTML(run[:text].to_s).gsub("\r\n", "\n").delete("\r").normalize_whitespace.gsub("\n", "<br>")
      url = run.dig(:navigationEndpoint, :commandMetadata, :webCommandMetadata, :url)

      if url&.starts_with?("/")
        url = Danbooru::URL.unescape(url)
        %{<a href="https://www.youtube.com#{CGI.escapeHTML(url)}">#{text}</a>}
      elsif url&.starts_with?("https://www.youtube.com/redirect")
        %{<a href="#{text}">#{text}</a>}
      else
        "<span>#{text}</span>"
      end
    end.join
  end

  def community_post_id
    # parsed_url may be a Source::URL::Google instead of Source::URL::Youtube, which is why we use
    # `parsed_url.try(:post_id)` instead of `parsed_url.post_id` (`try` won't fail if the method doesn't exist).
    #
    # This happens when uploading lh*.googleusercontent.com album cover URLs. *.googleusercontent.com URLs are
    # handled by Source::URL::Google instead of Source::URL::Youtube because they're not used just by Youtube.
    parsed_url.try(:post_id) || parsed_referer.try(:post_id)
  end

  def video_id
    parsed_url.try(:video_id) || parsed_referer.try(:video_id)
  end

  def channel_id
    parsed_url.try(:channel_id) || parsed_referer.try(:channel_id) || author_endpoint["browseId"]
  end

  def handle
    # "/@Mirae_Somang" -> "Mirae_Somang"
    parsed_url.try(:handle) || parsed_referer.try(:handle) || author_endpoint["canonicalBaseUrl"]&.delete_prefix("/@")
  end

  # { "browseId": "UCl8FRguXVySAHDnKdqn3QOg", "canonicalBaseUrl": "/@ilekkim" }
  def author_endpoint
    post_author = community_post.dig("authorEndpoint", "browseEndpoint")
    video_author = video_owner.dig("navigationEndpoint", "browseEndpoint")
    post_author || video_author || {}
  end

  def channel_url
    "https://www.youtube.com/channel/#{channel_id}" if channel_id.present?
  end

  def handle_url
    "https://www.youtube.com/@#{handle}" if handle.present?
  end

  # YouTube auto-translates titles and descriptions into the page's language. It doesn't translate into Lao (`hl=lo`),
  # so requesting the page in Lao gives the original text.
  memoize def page
    http.cache(1.minute).parsed_get(page_url, params: { hl: "lo" }) if community_post_id.present? || video_id.present?
  end

  memoize def community_post_json
    page&.at('script[text()*="ytInitialData"]')&.text&.slice(/{.*}/)&.parse_json || {}
  end

  memoize def community_post
    community_post_json.dig(
      "contents", "twoColumnBrowseResultsRenderer", "tabs", 0, "tabRenderer", "content", "sectionListRenderer",
      "contents", 0, "itemSectionRenderer", "contents", 0,
      "backstagePostThreadRenderer", "post", "backstagePostRenderer",
    ) || {}
  end

  def video_contents
    community_post_json.dig("contents", "twoColumnWatchNextResults", "results", "results", "contents").to_a
  end

  def video_primary_info
    video_contents.pluck("videoPrimaryInfoRenderer").compact.first || {}
  end

  def video_secondary_info
    video_contents.pluck("videoSecondaryInfoRenderer").compact.first || {}
  end

  def video_description
    video_secondary_info["attributedDescription"] || {}
  end

  def video_owner
    video_secondary_info.dig("owner", "videoOwnerRenderer") || {}
  end
end
