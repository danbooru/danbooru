# frozen_string_literal: true

# @see Source::URL::AppleMusic
class Source::Extractor::AppleMusic < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      return [parsed_url.full_image_url]
    end

    node = page&.at("source[srcset]")
    if node.present?
      found_url = node["srcset"].split(",").first.to_s.split.first.to_s
      full_url = Source::URL.parse(found_url)&.full_image_url || found_url
      [full_url].compact_blank
    end
  end

  def page_url
    parsed_url.try(:page_url) || parsed_referer.try(:page_url)
  end

  def artist_commentary_title
    page&.at("h1[data-testid='non-editable-product-title']")&.text&.strip
  end

  memoize def page
    http.cache(1.minute).get(page_url).parse if page_url.present?
  end
end
