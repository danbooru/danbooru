# frozen_string_literal: true

# @see https://dcinside.com
# @see Source::URL::DcInside
class Source::Extractor::DcInside < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.full_image_url]
    else
      image_urls_from_commentary
    end
  end

  def image_urls_from_commentary
    page&.css(".writing_view_box .write_div")&.css("img, video").to_a.filter_map do |el|
      next if el.classes.include?("written_dccon")

      if el.name == "video"
        src = el.attr("data-src")
      else
        src = el.attr("src")
      end

      next unless src.match %r{\Ahttps?://dcimg\d+\.dcinside\.(?:com|co\.kr)/viewimage\.php}

      if el.attr("onclick").to_s.match(/\Ajavascript:imgPop\('([^']*)'/)
        src = $1
      end

      Source::URL.parse(src).full_image_url
    end
  end

  def profile_url
    "https://gallog.dcinside.com/#{username}" if username.present?
  end

  def display_name
    page&.css(".gallview_head .gall_writer")&.attr("data-nick")&.value
  end

  def username
    page&.css(".gallview_head .gall_writer")&.attr("data-uid")&.value
  end

  def artist_commentary_title
    page&.css(".title")&.text&.strip
  end

  def artist_commentary_desc
    page&.css(".writing_view_box")&.to_s
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://gall.dcinside.com").squeeze("\n\n").strip
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end
end
