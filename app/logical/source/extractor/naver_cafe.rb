# frozen_string_literal: true

# @see Source::URL::NaverCafe
class Source::Extractor::NaverCafe < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      html_artist_commentary_desc&.parse_html&.css("img").to_a.pluck("src").filter_map do |src|
        url = Source::URL.parse(src)

        # exclude stickers (ex: https://storep-phinf.pstatic.net/ogq_57f943581ff20/original_16.png?type=p50_50)
        url.full_image_url if url.is_a?(Source::URL::NaverCafe)
      end
    end
  end

  def profile_url
    member_url || cafe_url
  end

  def profile_urls
    [member_url, cafe_url].compact
  end

  def display_name
    article.dig(:writer, :nick)
  end

  def username
    article.dig(:writer, :id)
  end

  def tags
    api_article[:tags].to_a.map do |tag|
      [tag, "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=#{club_id}&search.tagName=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    article[:subject]
  end

  def artist_commentary_desc
    article&.slice(:contentHtml, :contentElements)&.to_json
  end

  memoize def html_artist_commentary_desc
    content_html = article[:contentHtml].to_s

    # Insert attached images. Ex: https://cafe.naver.com/ca-fe/cafes/29767250/articles/785
    article[:contentElements].to_a.each_with_index do |element, i|
      case element["type"]
      in "IMAGE"
        image_url = element.dig(:json, :image, :url)
        image_url = Source::URL.parse(image_url).try(:full_image_url) || image_url
        element_html = %{<div><a href="#{CGI.escapeHTML(image_url)}"><img src="#{CGI.escapeHTML(image_url)}"></a></div>}
      else
        element_html = ""
      end

      content_html = content_html.gsub("[[[CONTENT-ELEMENT-#{i}]]]", element_html)
    end

    content_html.presence
  end

  def dtext_artist_commentary_desc
    return "" if html_artist_commentary_desc&.parse_html&.text&.normalize_whitespace.blank?

    DText.from_html(html_artist_commentary_desc, base_url: "https://cafe.naver.com") do |element|
      case element.name
      in "a" if element.at("img").present?
        url = element.at("img").attr("src")
        url = Source::URL.parse(url).try(:full_image_url) || url

        element.name = "p"
        element.inner_html = %{<a href="#{url}">[image]</a>}

      in "div" if element.children.any?(&:text?)
        element.name = "p"

      else
        nil
      end
    end
  end

  def member_url
    "https://cafe.naver.com/ca-fe/cafes/#{club_id}/members/#{member_id}" if club_id.present? && member_id.present?
  end

  def cafe_url
    "https://cafe.naver.com/#{club_name}" if club_name.present?
  end

  def member_id
    article.dig(:writer, :memberKey) || parsed_url.member_id || parsed_referer&.member_id
  end

  def club_name
    api_article.dig(:cafe, :url) || parsed_url.club_name || parsed_referer&.club_name
  end

  def club_id
    parsed_url.club_id || parsed_referer&.club_id || page&.at('a[name="myCafeUrlLink"]')&.attr(:href)&.then { |url| Source::URL.parse("https://cafe.naver.com#{url}")&.club_id }
  end

  def article_id
    parsed_url.article_id || parsed_referer&.article_id
  end

  def article
    api_article[:article] || {}
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  memoize def api_article
    api_url = "https://apis.naver.com/cafe-web/cafe-articleapi/v2.1/cafes/#{club_id}/articles/#{article_id}" if club_id.present? && article_id.present?
    http.cache(1.minute).parsed_get(api_url)&.dig(:result) || {}
  end
end
