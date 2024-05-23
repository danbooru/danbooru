# frozen_string_literal: true

# @see Source::URL::Skland
class Source::Extractor::Skland < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif article.dig(:item, :videoListSlice).present?
      article.dig(:item, :videoListSlice).to_a.map do |video|
        video_url = video[:resolutions]&.max_by { _1[:size].to_i }&.dig(:playURL)
        Source::URL.parse(video_url).try(:full_image_url) || video_url
      end
    else
      article.dig(:item, :imageListSlice).to_a.pluck(:url).map do |url|
        Source::URL.parse(url).try(:full_image_url) || url
      end
    end
  end

  def display_name
    article.dig(:user, :nickname)
  end

  def tags
    article[:tags].to_a.map do |tag|
      [tag[:name], "https://skland.com"]
    end
  end

  def artist_commentary_title
    article.dig(:item, :title)
  end

  def artist_commentary_desc
    return nil unless article.dig(:item, :format).present?

    { format: article.dig(:item, :format)&.parse_json, **article[:item]&.slice(:caption, :textSlice, :imageListSlice) }.to_json
  end

  def dtext_artist_commentary_desc
    DText.from_html(html_artist_commentary_desc, base_url: "https://www.skland.com")
  end

  def html_artist_commentary_desc
    format = article.dig(:item, :format)&.parse_json || {}

    format[:data].to_a.map do |item|
      case item[:type]
      # { "type": "paragraph", "contents": [{ "foregroundColor": "#222222", "type": "text", "contentId": "1", "bold": false, "underline": 0, "italic": false }] }
      in "paragraph"
        contents = item[:contents].to_a.map { |content| content_to_html(content) }.join
        "<p>#{contents}</p>" if contents.present?

      # {"type": "image", "width": 2408, "height": 1080, "size": 1001063, "imageId": "0"}
      in "image"
        "" # XXX ignored

      else
        ""
      end
    end.join
  end

  def content_to_html(content)
    case content[:type]
    # { "foregroundColor": "#222222", "type": "text", "contentId": "1", "bold": false, "underline": 0, "italic": false }
    in "text"
      id = content[:contentId]

      text = CGI.escapeHTML(text_slices[id].to_s)
      text = "<b>#{text}</b>" if content[:bold]
      text = "<i>#{text}</i>" if content[:italic]
      text = "<u>#{text}</u>" if content[:underline].to_i > 0
      text

    # { "type": "emoji", "id": "amiya-1__amiya_wuwu" }
    in "emoji"
      ":#{content[:id]}:"

    else
      ""
    end
  end

  memoize def text_slices
    # [{"id":"1","c":"絮雨买外敷#2243"},{"id":"2","c":"去年开的号，号上没几个好友"}]
    # => {"1":"絮雨买外敷#2243","2":"去年开的号，号上没几个好友"}
    article.dig(:item, :textSlice).to_h { |slice| [slice[:id], slice[:c]] }
  end

  def article_id
    parsed_url.article_id || parsed_referer&.article_id
  end

  memoize def article
    api_response.dig(:data, :list, 0) || {}
  end

  memoize def api_response
    api_url = "https://zonai.skland.com/h5/v1/item/list?ids=#{article_id}" if article_id.present?
    http.headers(platform: "3").cache(1.minute).parsed_get(api_url) || {}
  end
end
