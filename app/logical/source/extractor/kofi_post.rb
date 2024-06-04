# frozen_string_literal: true

# @see Source::Extractor::Kofi
class Source::Extractor::KofiPost < Source::Extractor::Kofi
  def image_urls
    if super.present?
      super
    else
      featured_image = post_page&.at(".article-featured-image img")&.attr(:src)
      article_images = artist_commentary_desc&.parse_html&.css("img").to_a.pluck(:src)

      [featured_image, *article_images].compact
    end
  end

  def display_name
    post_page&.at(".post-profile-text-container name a")&.text
  end

  def artist_commentary_title
    post_page&.at(".article-title h1")&.text
  end

  def artist_commentary_desc
    post_page&.css('script[text()*="shadowDom"]')&.text&.slice(%r{'<div class="fr-view article-body">(.*)</div>';}, 1)
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://ko-fi.com") do |element|
      if element.name == "img"
        element.name = "p"
        element.inner_html = %{<a href="#{CGI.escapeHTML(element[:src])}">[image]</a>}
      end
    end
  end

  def user_id
    post_page&.at(".post-profile-text-container name a")&.attr(:href)&.delete_prefix("/")
  end

  def profile_id
    user_id
  end

  def slug
    parsed_url.slug || parsed_referer&.slug
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  memoize def post_page
    # Use Ko-fi's backend IP to bypass Cloudflare protection.
    url = "https://104.45.231.79/post/#{slug}-#{post_id}" if slug.present? && post_id.present?
    http.with_legacy_ssl.headers(Host: "ko-fi.com").cache(1.minute).parsed_get(url)
  end
end
