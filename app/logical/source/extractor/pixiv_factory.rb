# frozen_string_literal: true

# @see Source::URL::PixivFactory
class Source::Extractor::PixivFactory < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif image_id.present?
      image_urls_from_api { |image| image[:id] == image_id.to_i }
    else
      image_urls_from_api
    end
  end

  def image_urls_from_api(&block)
    images = api_images[:images].to_a
    images = images.select(&block) if block_given?

    images.pluck(:url).pluck(:canvas).map do |path|
      URI.join("https://factory.pixiv.net", path).to_s
    end
  end

  def display_name
    page&.at("main div.text-center > h1 + div.typography-14")&.text
  end

  def artist_commentary_title
    page&.at("main div.text-center > h1")&.text
  end

  def artist_commentary_desc
    page&.at("main div.text-center > h1 ~ .text-left")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://factory.pixiv.net")
  end

  def collection_name
    parsed_url.collection_name || parsed_referer&.collection_name
  end

  def image_id
    parsed_url.image_id || parsed_referer&.image_id
  end

  memoize def page
    url = "https://factory.pixiv.net/palette/collections/#{collection_name}" if collection_name.present?
    http.cache(1.minute).parsed_get(url)
  end

  memoize def api_images
    url = "https://factory.pixiv.net/api/v1/palette/collections/#{collection_name}/images" if collection_name.present?
    http.cache(1.minute).parsed_get(url) || {}
  end
end
