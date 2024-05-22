# frozen_string_literal: true

# @see https://caburum.fandom.com/wiki/Nirvana (API docs)
# @see Source::URL::Fandom
class Source::Extractor::Fandom < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url.to_s]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif media_detail["mediaType"] == "image"
      image_url = media_detail["rawImageUrl"].presence
      [Source::URL.parse(image_url).try(:full_image_url) || image_url].compact
    else
      []
    end
  end

  def profile_url
    media_detail["userPageUrl"].presence || wiki_url
  end

  def username
    media_detail["userName"].presence
  end

  def artist_commentary_desc
    media_detail["imageDescription"].presence
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "")
  end

  def wiki
    parsed_url.wiki || parsed_referer&.wiki
  end

  def file
    parsed_url.file || parsed_referer&.file
  end

  def wiki_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  memoize def media_detail
    # curl "https://kancolle.fandom.com/wikia.php?controller=Lightbox&method=getMediaDetail&fileTitle=Mutsuki_Full_Damaged.png" | jq
    url = "#{wiki_url}/wikia.php?controller=Lightbox&method=getMediaDetail&fileTitle=#{Danbooru::URL.escape(file)}" if wiki_url.present? && file.present?
    http.cache(1.minute).parsed_get(url) || {}
  end

  memoize def file_usage
    # curl "https://kancolle.fandom.com/api.php?action=query&prop=fileusage&format=json&titles=File:Mutsuki_Full_Damaged.png" | jq
    url = "#{wiki_url}/api.php?action=query&prop=fileusage&format=json&titles=File:#{Danbooru::URL.escape(file)}" if wiki_url.present? && file.present?
    http.cache(1.minute).parsed_get(url) || {}
  end
end
