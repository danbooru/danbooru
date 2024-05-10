# frozen_string_literal: true

# @see Source::URL::Postype
class Source::Extractor::Postype < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      html = artist_commentary_desc.to_s.parse_html
      html.css("figure img").pluck("src").map { |url| Source::URL.parse(url).try(:full_image_url) || url }
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    # https://fruitsnoir.postype.com/
    blog_url
  end

  def profile_urls
    # https://fruitsnoir.postype.com/
    # https://www.postype.com/profile/@fq7uvp
    [profile_url, profile_page_url].compact_blank
  end

  def artist_name
    page&.at(".post-header .article-author a")&.text
  end

  def tag_name
    Source::URL.parse(profile_page_url)&.username
  end

  def artist_commentary_title
    page&.at("article#post")&.attr("data-post-title")
  end

  def artist_commentary_desc
    api_response.dig("data", "html")
  end

  def dtext_artist_commentary_desc
    return "" if artist_commentary_desc.to_s.parse_html.tap { _1.css("section, script").remove }.text.blank?

    DText.from_html(artist_commentary_desc, base_url: blog_url) do |element|
      case element.name
      in "figure"
        element.name = "p"

      # <a target="_blank" href="https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/14/b74199027c683bb5b66e8a1bb1d5b7b1.png?w=1200&amp;q=90" data-width="751" data-height="553" data-caption="" class="photo" data-full-path="https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/14/b74199027c683bb5b66e8a1bb1d5b7b1.png?w=1200&amp;q=90" style="width: 700px; height: 515.446px; margin-left: 0px;"><img src="https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/14/b74199027c683bb5b66e8a1bb1d5b7b1.png?w=1200&amp;q=90" alt=""></a>
      in "a" if element.children.any? { _1.name == "img" } && element.next&.name == "a" && element.next.children.any? { _1.name == "img" }
        element.after("<br>")

      # <img src="https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/14/b74199027c683bb5b66e8a1bb1d5b7b1.png?w=1200&amp;q=90" alt="">
      in "img"
        element["alt"] = "[image]"

      # <section class="pay pay-purchase">
      in "section" if element.classes.include?("pay")
        element.content = nil

      in "div" if element.classes.include?("membership-only")
        element.content = nil

      else
        nil
      end
    end
  end

  def tags
    page&.css(".tag-list a").to_a.map do |element|
      [element.text, element["href"]]
    end
  end

  def blog_url
    # https://fruitsnoir.postype.com/
    parsed_url.profile_url || parsed_referer&.profile_url || page&.at("a#blog-logo-wrapper")&.attr("href")
  end

  def profile_page_url
    # https://www.postype.com/profile/@fq7uvp
    page&.at(".post-header a.profile-avatar")&.attr("href")
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def http
    super.cookies(PSE3: Danbooru.config.postype_session_cookie).headers(Referer: "https://postype.com")
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  memoize def api_response
    return {} if post_id.blank?

    http.cache(1.minute).parsed_get("https://www.postype.com/api/post/content/#{post_id}") || {}
  end
end
