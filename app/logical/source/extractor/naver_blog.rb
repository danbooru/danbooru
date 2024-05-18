# frozen_string_literal: true

# @see Source::URL::NaverBlog
class Source::Extractor::NaverBlog < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      properties["attachimagepathandidinfo"]&.parse_json.to_a.pluck("path").map do |path|
        "http://blogfiles.naver.net#{path}"
      end
    end
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def display_name
    page&.at('meta[property="naverblog:nickname"]')&.attr("content")
  end

  def username
    parsed_url.username || parsed_referer&.username
  end

  def tags
    tags = page&.css(".post_tag a").to_a.map do |element|
      tag = element.text.delete_prefix("#")
      [tag, "https://m.blog.naver.com/BlogTagView.naver?tagName=#{Danbooru::URL.escape(tag)}"]
    end

    category = page&.at(".lst_m .td.tit .ell")&.text
    if username.present? && category.present?
      tags += [[category, "https://blog.naver.com/PostList.naver?blogId=#{Danbooru::URL.escape(username)}&categoryName=#{Danbooru::URL.escape(category)}"]]
    end

    tags
  end

  def artist_commentary_title
    properties["title"]
  end

  def artist_commentary_desc
    page&.at("#viewTypeSelector")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: profile_url) do |element|
      case element.name

      # Remove header and footer. Example: https://m.blog.naver.com/sungho5080/220871847587
      in "div" if element["class"]&.match?(/ssp-adcontent|documentTitle/)
        element.content = nil

      # Replace embedded cards with bare links.
      # Examples: https://blog.naver.com/sjhsh352/223378243886, https://blog.naver.com/goam2/221647025085
      in "div" if element.classes.intersect?(%w[se-section-oglink _oglink])
        href = element.at("a.se-oglink-info, .txt > a")&.attr("href")
        element.name = "p"
        element.inner_html = %{<a href="#{href}">#{href}</a>}

      # Fix paragraphs containing image links
      in "div" if element.classes.intersect?(%w[se-module se_image])
        element.name = "p"

      # Fix image links.
      in "a" if element.at("img").present?
        url = element.at("img").attr("src")
        element.content = "[image]"
        element["href"] = Source::URL.parse(url).try(:full_image_url) || url

      # Fix image links. Example: https://blog.naver.com/goam2/221647025085
      in "span" if element["thumburl"].present?
        url = element["thumburl"]
        element.name = "a"
        element.content = "[image]"
        element["href"] = Source::URL.parse(url).try(:full_image_url) || url

      # Render table embeds as quotes. Example: https://m.blog.naver.com/goam2/221647025085
      in "table"
        element.name = "blockquote"

      # Remove buttons under image slider. Example: https://blog.naver.com/sjhsh352/223378243886
      in "button"
        element.content = nil

      else
        nil
      end
    end
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  memoize def properties
    page&.css("#_post_property, #_photo_view_property, #_floating_menu_property").to_a.map(&:to_h).reduce(&:merge) || {}
  end

  memoize def page
    http.cache(1.minute).parsed_get("https://m.blog.naver.com/#{username}/#{post_id}") if username.present? && post_id.present?
  end
end
