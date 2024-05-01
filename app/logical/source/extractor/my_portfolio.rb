# frozen_string_literal: true

# @see Source::URL::MyPortfolio
class Source::Extractor::MyPortfolio < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      # Grab the data-src attribute from all <div> and <img> tags. This may grab multiple versions of the same image. In
      # that case we pick the first URL for each image (which is assumed to be the largest version of the image).
      page&.css("#project-modules [data-src]").to_a.pluck("data-src").uniq do |url|
        Source::URL.parse(url)&.image_uuid
      end
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def artist_name
    page&.at("title")&.text&.split(" - ")&.first&.normalize_whitespace
  end

  def tag_name
    username
  end

  def other_names
    [artist_name, username].compact_blank.uniq
  end

  def artist_commentary_title
    page&.at("title")&.text&.split(" - ")&.second&.normalize_whitespace
  end

  def artist_commentary_desc
    commentary = ""

    # https://sekigahara023.myportfolio.com/ea-apexlegends-4
    if page&.at(".page-header p.description").present?
      commentary += page&.at(".page-header p.description")&.to_html.to_s
    end

    # Grab all HTML under #project-modules, unless it contains only empty text nodes.
    # https://shiori-shii.myportfolio.com/work-1 (has both images and text)
    # https://shiori-shii.myportfolio.com/portfolio (only images)
    if page&.at("#project-modules")&.enum_for(:traverse)&.any? { |node| node.text? && node.text.present? && node.parent.name != "script" }
      commentary += page&.at("#project-modules")&.to_html.to_s
    end

    commentary.presence
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: profile_url) do |element|
      case element.name
      when "img"
        element["alt"] = "[image]"
        element["src"] = element["data-src"]
      when "div"
        element.name = "p"
      end
    end
  end

  def username
    parsed_url.username || parsed_referer&.username
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end
end
