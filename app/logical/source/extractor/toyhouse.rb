# frozen_string_literal: true

# @see Source::URL::Toyhouse
class Source::Extractor::Toyhouse < Source::Extractor
  def image_urls
    # Only use the image URL as-is if we can't get the full size image from the page.
    if parsed_url.image_url? && image_url_from_page.nil?
      [parsed_url.to_s]
    else
      [image_url_from_page].compact
    end
  end

  def image_url_from_page
    page&.at("#content img")&.attr(:src)
  end

  # Note that this can be a different artist on a different website.
  # Ex: https://toyhou.se/2712983.cudlil/19136838.art-by-others#58116270
  def profile_url
    page&.at(".image-credits .artist-credit a")&.attr(:href)&.then { |url| Source::URL.profile_url(url) || url }
  end

  def display_name
    name = page&.at(".image-credits .artist-credit a")&.text
    name unless name&.match?(%r{^https?://})
  end

  def tags
    page&.css(".image-characters .character-name-badge").to_a.map do |element|
      url = URI.join("https://toyhou.se", element[:href]).to_s

      # <a href="/2712983.cudlil/19136838.art-by-others" class="character-name-badge">cudlil (<i class="fa fa-images mr-1"></i>art by others)</a>
      # <a href="/19108771.june-human-" class="character-name-badge">June (Human)</a>
      character_name = element.children.first.text.delete_suffix(" (")

      [character_name, url]
    end
  end

  def artist_commentary_desc
    page&.at(".image-description.user-content")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://toyhou.se")
  end

  def image_id
    parsed_url.image_id || parsed_referer&.image_id
  end

  memoize def page
    http.cache(1.minute).parsed_get("https://toyhou.se/~images/#{image_id}") if image_id.present?
  end
end
