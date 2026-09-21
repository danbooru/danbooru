# frozen_string_literal: true

# @see Source::URL::Taittsuu
class Source::Extractor::Taittsuu < Source::Extractor
  # The public API key and guest access token used by the website itself.
  API_KEY = "mr5cs4KixwyqsnGcTVU5qsTYGXbvsgmZgMk799SaC2gbFigZ"
  ACCESS_TOKEN = "iuq6whe8Qofbweu3hVVfjoCeifoK00qe8Af"

  def image_urls
    if parsed_url.image_url?
      [url]
    else
      post[:media].to_a.select { |media| media[:enabled] }.pluck(:url)
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://taittsuu.com/users/#{username}" if username.present?
  end

  def username
    post[:user_screenname] || parsed_url.username || parsed_referer&.username
  end

  def display_name
    post[:user_name]
  end

  def published_at
    Time.zone.parse(post[:created_at]) if post[:created_at].present?
  end

  def tags
    post[:hashtags].to_a.pluck(:tag).map do |tag|
      [tag, "https://taittsuu.com/taiitsus/hashtags/search?query=#{Addressable::URI.encode_component(tag)}"]
    end
  end

  def artist_commentary_desc
    post[:content]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  memoize def post
    return {} if post_id.blank?

    response = http.headers("X-API-KEY": API_KEY, "X-ACCESS-TOKEN": ACCESS_TOKEN).cache(1.minute).parsed_get("https://apt.taittsuu.com/api/v0.1/taiitsus/#{post_id}?aikotoba=")
    response&.dig(:data)&.first || {}
  end
end
