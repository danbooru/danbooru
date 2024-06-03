# frozen_string_literal: true

# @see Source::Extractor::Kofi
class Source::Extractor::KofiGalleryItem < Source::Extractor::Kofi
  def image_urls
    if super.present?
      super
    elsif gallery_page&.at("#gallery-item-view .label-hires a").present?
      [gallery_page&.at("#gallery-item-view .label-hires a")&.attr(:href)].compact
    else
      gallery_page&.css('.gallery-item-main img[id^="hires"]').to_a.pluck(:src)
    end
  end

  def display_name
    gallery_page&.at(".gallery-item-profile name")&.text
  end

  def user_id
    gallery_page&.at(".gallery-item-thumb a")&.attr(:href)&.delete_prefix("/")
  end

  def artist_commentary_title
    gallery_page&.at(".modal-caption-pdg h2")&.text
  end

  def artist_commentary_desc
    gallery_page&.at(".modal-caption-pdg div")&.to_html&.gsub("\n", "<br>")
  end

  def gallery_item_id
    parsed_url.gallery_item_id || parsed_referer&.gallery_item_id
  end

  def profile_id
    super || user_id
  end

  memoize def gallery_page
    url = "https://ko-fi.com/Gallery/LoadGalleryItem?galleryItemId=#{gallery_item_id}" if gallery_item_id.present?
    http.cache(1.minute).parsed_get(url)
  end
end
