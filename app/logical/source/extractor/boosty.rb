# frozen_string_literal: true

# @see Source::URL::Boosty
class Source::Extractor::Boosty < Source::Extractor
  # Style codes used in the text ranges of a post: [code, offset, length].
  RANGE_TAGS = { 0 => "b", 2 => "i", 4 => "u" }.freeze

  # Direct mp4 qualities of a video, best first. The other player URLs are HLS/DASH streams.
  VIDEO_QUALITIES = %w[ultra_hd quad_hd full_hd high medium low lowest tiny].freeze

  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    else
      api_response[:data].to_a.filter_map { |item| media_url(item) }
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://boosty.to/#{username}" if username.present?
  end

  def username
    blog_name || api_response.dig(:user, :blogUrl)
  end

  def display_name
    api_response.dig(:user, :name)
  end

  def published_at
    Time.at(api_response[:publishTime]).utc if api_response[:publishTime].present?
  end

  def updated_at
    Time.at(api_response[:updatedAt]).utc if api_response[:updatedAt].present?
  end

  def tags
    api_response[:tags].to_a.map { |tag| [tag[:title], "https://boosty.to/#{username}?postsTagsIds=#{tag[:id]}"] }
  end

  def artist_commentary_title
    api_response[:title]
  end

  # Items are grouped into paragraphs ending at BLOCK_END.
  def artist_commentary_desc
    paragraphs = api_response[:data].to_a.slice_after { |item| item[:modificator] == "BLOCK_END" }

    paragraphs.map { |paragraph| paragraph.map { |item| item_to_html(item) }.join }.join("<br>")
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://boosty.to")
  end

  def media_url(item)
    case item[:type]
    in "image"
      "https://images.boosty.to/image/#{item[:id]}"
    # The URLs are signed and expire, so they change on every request.
    in "ok_video"
      item[:playerUrls].to_a.select { |player| player[:url].present? && player[:type].in?(VIDEO_QUALITIES) }.min_by { |player| VIDEO_QUALITIES.index(player[:type]) }&.dig(:url)
    else
      nil
    end
  end

  def blog_name
    parsed_url.username || parsed_referer&.username
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def item_to_html(item)
    case item[:type]
    # { "type": "text", "content": "[\"Some text\",\"unstyled\",[[0,0,4]]]" }
    in "text"
      content_to_html(item[:content])

    # { "type": "link", "url": "https://example.com", "content": "[\"Link text\",\"unstyled\",[]]" }
    in "link"
      %{<a href="#{CGI.escapeHTML(item[:url])}">#{content_to_html(item[:content])}</a>}

    # { "type": "file", "url": "https://cdn.boosty.to/file/...", "title": "Universe plugin.rar" }
    # { "type": "image", "id": "04b6ada2-...", "url": "https://images.boosty.to/image/04b6ada2-...?change_time=1769678227" }
    # { "type": "ok_video", "title": "Some video", "playerUrls": [{ "type": "high", "url": "https://vd584.okcdn.ru/..." }] }
    else
      url = media_url(item) || item[:url].presence
      %{<a href="#{CGI.escapeHTML(url)}">#{CGI.escapeHTML(item[:title].presence || url)}</a><br>} if url.present?
    end
  end

  # Ranges are [style code, offset, length] in UTF-16 code units, so an emoji takes up two cells.
  def content_to_html(content)
    text, _style, ranges = JSON.parse(content.presence || '[""]')
    cells = text.each_char.flat_map { |char| [CGI.escapeHTML(char).gsub("\n", "<br>"), *("" if char.ord > 0xFFFF)] }

    # Wrap the first and last cell of each range in its tag.
    ranges.to_a.sort.each do |code, offset, length|
      next if RANGE_TAGS[code].nil? || length.zero? || offset >= cells.size

      last = [offset + length, cells.size].min - 1
      cells[offset] = "<#{RANGE_TAGS[code]}>#{cells[offset]}"
      cells[last] = "#{cells[last]}</#{RANGE_TAGS[code]}>"
    end

    cells.join
  end

  memoize def api_response
    return {} if blog_name.blank? || post_id.blank?

    parsed_get("https://api.boosty.to/v1/blog/#{blog_name}/post/#{post_id}") || {}
  end
end
