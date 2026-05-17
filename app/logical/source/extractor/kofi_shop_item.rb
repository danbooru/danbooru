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
    href = shop_item_page&.at("a.navbar-creator[href]")&.attr(:href)
    Source::URL.parse("https://ko-fi.com#{href}")&.user_id if href.present?
  end

  def profile_id
    user_id
  end

  def shop_item_id
    parsed_url.shop_item_id || parsed_referer&.shop_item_id
  end

  memoize def shop_item_page
    backend_get("/s/#{shop_item_id}") if shop_item_id.present?
  end
end
