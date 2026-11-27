# frozen_string_literal: true

# @see Source::URL::Crepe
class Source::Extractor::Crepe < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    else
      commission_data.dig(:images, :__refs).to_a.filter_map { |ref| relay_data.dig(ref, :url) }
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://crepe.cm/@#{username}" if username.present?
  end

  def username
    user[:username] || parsed_url.username || parsed_referer&.username
  end

  def display_name
    user[:name]
  end

  def tags
    commission_data.dig(:tags, :__refs).to_a.filter_map { |ref| relay_data.dig(ref, :name) }.map do |tag|
      [tag, "https://crepe.cm/search?query=#{Danbooru::URL.escape("##{tag}")}"]
    end
  end

  def artist_commentary_title
    commission_data[:name]
  end

  def artist_commentary_desc
    DText.tiptap_to_html(commission_data[:content])
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://crepe.cm")
  end

  def user
    relay_data[commission_data.dig(:user, :__ref)] || {}
  end

  # The commission data is the root record matching e.g. `commissionType(input:{"commissionTypePath":{"slug":"t71oz0uls","username":"yolrsona"}})`.
  def commission_data
    ref = relay_data["client:root"]&.find { |key, _value| key.start_with?("commissionType(") }&.second&.dig(:__ref)
    relay_data[ref] || {}
  end

  # The page's data is a Relay store in `<script id="vike_pageContext">`, with forward slashes escaped as `\/` inside strings.
  memoize def relay_data
    json = page&.at("script#vike_pageContext")&.text&.gsub("\\\\/", "/")&.parse_json
    json&.dig(:relayInitialData) || {}
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url) if page_url.present?
  end
end
