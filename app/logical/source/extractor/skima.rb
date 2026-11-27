# frozen_string_literal: true

# Pages on skima.jp are scraped from the HTML. Pages on the international site (commission.skima.jp) are fetched from
# its API, because some international commissions aren't visible on skima.jp.
#
# @see Source::URL::Skima
class Source::Extractor::Skima < Source::Extractor
  memoize def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      # If we have the page the sample came from, take the full image from the page instead of guessing its extension.
      page_image = page_image_urls.find { |image_url| Source::URL.parse(image_url).try(:image_id) == parsed_url.image_id } if parsed_url.image_id.present?
      [full_image_url(page_image || url)]
    else
      # Commission pages on skima.jp only link to samples, so we have to guess the full image URL. Images in the same
      # post usually have the same format, so try the previous image's extension first.
      page_image_urls.reduce([]) do |image_urls, image_url|
        image_urls + [full_image_url(image_url, previous_image_url: image_urls.last)]
      end
    end
  end

  # @return [Array<String>] The image URLs linked from the page. These are samples on commission pages, and full images
  #   everywhere else.
  memoize def page_image_urls
    if commission.present?
      commission[:itemResources].to_a.pluck(:original).compact
    elsif dl_product.present?
      dl_product[:dlProductResources].to_a.pluck(:original).compact
    elsif gallery_id.present?
      page&.css(".gallerypage-images a[href]").to_a.pluck("href")
    elsif item_id.present?
      page&.css(".main-image a[href]").to_a.pluck("href")
    elsif dl_product_id.present?
      page&.css("#image_gallery a[href]").to_a.pluck("href")
    else
      []
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://skima.jp/profile?id=#{user_id}" if user_id.present?
  end

  def display_name
    api_user[:nickName] || page&.at(".gallery-head__name .username a, .details .username a")&.text&.strip
  end

  def tags
    page&.css(".tag li a").to_a.map { |a| a.text.strip }.compact_blank.map do |tag|
      [tag, "https://skima.jp/gallery/search?tag=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    commission[:name] || dl_product.dig(:dlProduct, :name) || page&.at(".gallery-item-head h2, .item-name")&.text&.strip
  end

  def artist_commentary_desc
    if api_response.present?
      commission[:description] || dl_product.dig(:dlProduct, :description)
    else
      page&.at(".gallerypage-images ~ p, .item_content")&.inner_html
    end
  end

  def dtext_artist_commentary_desc
    if api_response.present?
      DText.from_plaintext(artist_commentary_desc)
    else
      DText.from_html(artist_commentary_desc, base_url: "https://skima.jp")
    end
  end

  def user_id
    # <a href="/profile/galleries?id=1927">
    # <a href="/profile?id=1927" target="_blank" data-gtm-event="profile">
    page_user_id = page&.at(".gallery-head__name .username a, .details .username a")&.attr("href").to_s[/[?&]id=(\d+)/, 1]

    api_user[:userId]&.to_s || page_user_id || parsed_url.user_id || parsed_referer&.user_id
  end

  def gallery_id
    parsed_url.gallery_id || parsed_referer&.gallery_id
  end

  def item_id
    parsed_url.item_id || parsed_referer&.item_id
  end

  def dl_product_id
    parsed_url.dl_product_id || parsed_referer&.dl_product_id
  end

  def international?
    Source::URL.parse(page_url)&.international? || false
  end

  # Samples have the same hash as the original image, but not always the same extension, so we have to try each one.
  # Full image URLs are returned as is, without any requests.
  #
  # @param image_url [String] The sample or full image URL.
  # @param previous_image_url [String, nil] The previous image in the post. Its extension is tried first.
  # @return [String] The full image URL, or the sample URL if the full image wasn't found.
  def full_image_url(image_url, previous_image_url: nil)
    candidates = Source::URL.parse(image_url).try(:candidate_full_image_urls).to_a
    candidates = candidates.partition { |candidate| File.extname(candidate) == File.extname(previous_image_url) }.flatten if previous_image_url.present?

    candidates.find { |candidate| http_exists?(candidate) } || image_url
  end

  def commission
    api_response[:commission] || {}
  end

  def dl_product
    api_response[:dlProduct] || {}
  end

  def api_user
    commission[:user] || dl_product[:user] || {}
  end

  memoize def api_response
    return {} unless international?

    if item_id.present?
      parsed_get("https://api.commission.skima.jp/commissions/#{item_id}") || {}
    elsif dl_product_id.present?
      parsed_get("https://api.commission.skima.jp/dlProducts/#{dl_product_id}") || {}
    else
      {}
    end
  end

  memoize def page
    parsed_get(page_url) unless international?
  end
end
