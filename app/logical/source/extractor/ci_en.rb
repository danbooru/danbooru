# frozen_string_literal: true

# @see Source::URL::CiEn
class Source::Extractor::CiEn < Source::Extractor
  def self.enabled?
    Danbooru.config.ci_en_session_cookie.present?
  end

  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      urls = []

      og_url = Source::URL.parse(page&.css("meta[property='og:image']")&.attr("content").to_s)
      if og_url.image_type != "attachment"
        urls << og_url.to_s
      end

      urls += page&.css(".l-creatorPage-main article vue-l-image, .l-creatorPage-main article vue-file-player").map do |node|
        case node.name
        when "vue-l-image"
          node["data-raw"]
        when "vue-file-player"
          Addressable::URI.heuristic_parse(node["base-path"]).join("video-web.mp4").tap do |uri|
            uri.query = node["auth-key"]
          end.to_s
        end
      end.compact.uniq

      urls
    end
  end

  def tag_name
    "cien_#{artist_id}" if artist_id.present?
  end

  def artist_id
    parsed_url.creator_id || parsed_referer&.creator_id
  end

  def artist_name
    page&.css(".c-accountInfo .e-userName")&.text&.strip
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def artist_commentary_title
    page&.css(".l-creatorPage-main .article-title")&.to_html
  end

  def artist_commentary_desc
    page&.dup&.css(".l-creatorPage-main article")&.tap do |article|
      article.css(".article-title").remove
      article.css(".articleContents").remove
      article.css("vue-file-player").remove
      article.css(".file-player-image-wrapper").remove
      article.css(".c-rewardBox").remove
    end&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://ci-en.net")
  end

  def tags
    page&.css(".l-creatorPage-main .c-hashTagList .c-hashTagList-item a").to_a.map do |tag|
      [tag.text.strip.delete_prefix("#"), tag.attr("href")]
    end
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  def http
    # Same cookie works for both all-ages and R18 sites
    super.cookies(
      ci_en_session: Danbooru.config.ci_en_session_cookie,
      accepted_rating: "r18g",
    )
  end
end
