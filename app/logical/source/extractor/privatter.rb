# frozen_string_literal: true

# @see Source::URL::Privatter

class Source::Extractor::Privatter < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      images_from_page
    end
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url || profile_url_from_page
  end

  def display_name
    page&.search(".panel-body > b")&.first&.text&.strip
  end

  def username
    parsed_url.username || parsed_referer&.username || username_from_page
  end

  def username_from_page
    page&.search("a[href*='/u/']")&.first&.attr("href")&.delete_prefix("/u/")
  end

  def profile_url_from_page
    "https://privatter.net/u/#{username_from_page}" if username_from_page.present? # relative link
  end

  def images_from_page
    page&.search("p.image a, span.imgredir > a").to_a.map { |elem| elem.attr("href") }.uniq
  end

  def artist_commentary_title
    page&.search("#left div.panel:first-child div.panel-body, #left .lead")&.first&.text
  end

  def dtext_artist_commentary_desc
    commentary = page&.search("#left p.honbun")
    return "" if commentary.blank?
    # Keep image location in commentary, unless the post has no text.
    return "" if commentary.text.strip.blank?

    DText.from_html(commentary) do |element|
      case element.name
      in "span" if element.css("a img").present? && element.next&.css("a img").present?
        element.after("<br>")

      in "img"
        element["alt"] = "[image]"

      else
        nil
      end
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def page
    http.cache(1.minute).parsed_get(page_url)
  end

  memoize :page
end
