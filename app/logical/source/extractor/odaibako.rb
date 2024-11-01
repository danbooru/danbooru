# frozen_string_literal: true

# @see Source::URL::Odaibako
class Source::Extractor::Odaibako < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      image_urls_from_page
    end
  end

  def image_urls_from_page
    page&.css("main > section:nth-child(1) > div > section > div:nth-child(2) > div:nth-child(2) a")&.pluck(:href).to_a
  end

  def profile_url
    "https://odaibako.net/u/#{username}"
  end

  def page_url
    # Normalize to just odai ids
    if odai_id.present?
      "https://odaibako.net/odais/#{odai_id}"
    else
      page_url_from_parsed_url
    end
  end

  def page_url_from_parsed_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def display_name
    page&.css("main > section:nth-child(2) > div > div > h3 > a:nth-child(2) > div:nth-child(1)")&.text
  end

  def username
    href = page&.css("main > section:nth-child(2) > div > div > h3 > a:nth-child(2)")&.attr("href")
    Source::URL.parse(URI.join("https://odaibako.net/", href)).username if href.present?
  end

  def odai_id
    href = page&.css("main > section:nth-child(1) > div > div:nth-child(2) > a")&.attr("href")
    Source::URL.parse(URI.join("https://odaibako.net/", href)).odai_id if href.present?
  end

  def artist_request
    page&.css("main > section:nth-child(1) > div > div:nth-child(1)")&.inner_html&.strip
  end

  def artist_response
    page&.css("main > section:nth-child(1) > div > section > div:nth-child(2) > div:nth-child(1)")&.inner_html&.strip
  end

  def dtext_artist_commentary_desc
    commentary = "".dup

    if artist_request.present?
      commentary << <<~EOS.chomp
        h6. Original Request

        #{DText.from_html(artist_request)}
      EOS
    end

    if artist_response.present?
      commentary << <<~EOS.chomp


        h6. Artist Response

        #{DText.from_html(artist_response)}
      EOS
    end

    commentary.strip
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url_from_parsed_url)
  end
end
