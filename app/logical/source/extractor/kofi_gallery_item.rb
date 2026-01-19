# frozen_string_literal: true

# @see Source::Extractor::Kofi
class Source::Extractor::KofiGalleryItem < Source::Extractor::Kofi
  def image_urls
    if super.present?
      super
    elsif (download_buttons = gallery_page&.css("#gallery-item-view .label-hires a, #gallery-item-view a.label-hires")).present?
      download_buttons.to_a.pluck(:href).compact
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
    url = "https://104.45.231.79/Gallery/LoadGalleryItem?galleryItemId=#{gallery_item_id}" if gallery_item_id.present?
    http.with_legacy_ssl.headers(Host: "ko-fi.com").cache(1.minute).parsed_get(url)
  end
end
