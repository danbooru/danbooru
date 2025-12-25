# frozen_string_literal: true

# @see Source::URL::Artistree
class Source::Extractor::Artistree < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    elsif commission.present?
      commission["reference_images"]
    else
      []
    end
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def artist_commentary_title
    commission["name"]
  end

  def artist_commentary_desc
    commission["additional_info"]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def username
    parsed_url.username || parsed_referer&.username
  end

  def commission
    if parsed_url.image_url?
      commissions.find { |comm| comm["reference_images"].include?(parsed_url.to_s) } || {}
    else
      commission_id = parsed_url.commission_id || parsed_referer&.commission_id
      commissions.find { |comm| comm["listing_id"] == commission_id } || {}
    end
  end

  memoize def commissions
    api_response["commission_info"] || []
  end

  memoize def api_response
    return {} if username.blank?

    # curl "https://api.artifyc.com/commission/request?artist=alysonsega" | jq
    http.cache(1.minute).parsed_get("https://api.artifyc.com/commission/request?artist=#{username}") || {}
  end
end
