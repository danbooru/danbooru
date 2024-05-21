# frozen_string_literal: true

# @see Source::URL::Carrd
class Source::Extractor::Carrd < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.candidate_full_image_urls.present?
      [parsed_url.candidate_full_image_urls.find { |url| http_exists?(url) } || parsed_url.without(:query).to_s]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      page_section&.css("img, video").to_a.flat_map do |element|
        image_url = extract_image_url(element)
        Source::URL::Carrd.new(image_url).extractor.image_urls
      end
    end
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def artist_commentary_desc
    page_section&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: profile_url) do |element|
      # Drop all parts of the page that don't contain a p, img, video, or hN element. This is to try to include only
      # parts of the page that have real content, and not headers or footers that only contain buttons or icons.
      self_and_ancestors = [element, *element.ancestors]
      if !self_and_ancestors.map(&:name).intersect?(%w[p img video text h1 h2 h3 h4 h5 h6]) && element.at("p, img, video, h1, h2, h3, h4, h5, h6").nil?
        element.content = nil

      # Turn <a href="assets/images/gallery02/2973b8cd.jpg"><img src="..."></a> tags into "[image]":[https://...] links.
      elsif element.name == "a" && element.at("img, video").present?
        element[:href] = extract_image_url(element)
        element.inner_html = "[image]"

      # Turn <img src="assets/images/gallery02/2973b8cd.jpg" alt="Untitled"> tags into "[image]":[https://...] links.
      elsif element.name == "img"
        element[:alt] = "[image]"
        element[:src] = extract_image_url(element)

      # Turn <video src="assets/videos/video03.mp4?v=c6f079b5" poster="assets/videos/video03.mp4.jpg?v=c6f079b5"> tags
      # into "[video]":[https://...] links.
      elsif element.name == "video"
        element.name = "a"
        element.content = "[video]"
        element[:href] = extract_image_url(element)
      end
    end
  end

  # Given an <img> or <video> element, extract the relative URL from the data-src or src attribute and turn it into an absolute URL.
  def extract_image_url(element)
    image_url = [element["data-src"], element["src"], element["href"]].compact.find { |src| src.starts_with?("assets") }
    Source::URL.parse(URI.join(profile_url, image_url).to_s).without(:query).to_s
  end

  def page_id
    parsed_url.page_id || parsed_referer&.page_id
  end

  def username
    parsed_url.username || parsed_referer&.username
  end

  memoize def page_section
    page&.at("##{page_id}-section")
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end
end
