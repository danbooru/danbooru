# frozen_string_literal: true

# @see Source::Extractor::Kofi
class Source::Extractor::KofiShopItem < Source::Extractor::Kofi
  def image_urls
    super.presence || shop_item_page&.css("img.kfds-c-carousel-product-img").to_a.pluck(:src)
  end

  def artist_commentary_title
    shop_item_page&.at(".shop-item-title")&.text
  end

  def artist_commentary_desc
    shop_item_page&.at(".kfds-c-product-detail-res-width")&.to_html&.gsub("\n", "<br>")
  end

  def user_id
    shop_item_page&.at('a[href^="/home/reportpage"]')&.attr(:href)&.delete_prefix("/home/reportpage?pageid=")
  end

  def profile_id
    user_id
  end

  def shop_item_id
    parsed_url.shop_item_id || parsed_referer&.shop_item_id
  end

  memoize def shop_item_page
    # Use Ko-fi's backend IP to bypass Cloudflare protection on the https://ko-fi.com/s/:id endpoint.
    url = "https://104.45.231.79/s/#{shop_item_id}" if shop_item_id.present?
    http.with_legacy_ssl.headers(Host: "ko-fi.com").cache(1.minute).parsed_get(url)
  end
end
