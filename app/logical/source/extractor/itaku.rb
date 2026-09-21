# frozen_string_literal: true

# @see Source::URL::Itaku
class Source::Extractor::Itaku < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.candidate_full_image_urls.to_a.find { |url| http_exists?(url) } || url]
    elsif post_id.present?
      api_response["gallery_images"].to_a.pluck("image")
    elsif commission_id.present?
      api_response.values_at("reference_gallery_images", "finished_work_gallery_images").flatten.compact.pluck("image")
    else
      [api_response.dig("video", "video") || api_response["image"]].compact
    end
  end

  def profile_url
    "https://itaku.ee/#{username}" if username.present?
  end

  def display_name
    api_response["owner_displayname"]
  end

  def username
    api_response["owner_username"]
  end

  def artist_commentary_title
    api_response["title"]
  end

  def artist_commentary_desc
    api_response["description"] || api_response["content"]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def published_at
    Time.zone.parse(api_response["date_added"]) if api_response["date_added"].present?
  end

  def updated_at
    Time.zone.parse(api_response["date_edited"]) if api_response["date_edited"].present?
  end

  def tags
    api_response["tags"].to_a.pluck("name").map do |tag|
      [tag, "https://itaku.ee/home/images?tags=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def image_id
    parsed_url.image_id || parsed_referer&.image_id
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def commission_id
    parsed_url.commission_id || parsed_referer&.commission_id
  end

  memoize def api_response
    # curl https://itaku.ee/api/galleries/images/576357/ | jq
    # curl https://itaku.ee/api/posts/130073/ | jq
    # curl https://itaku.ee/api/commissions/1755/ | jq
    if post_id.present?
      api_url =
        "https://itaku.ee/api/posts/#{post_id}/"
    elsif commission_id.present?
      api_url =
        "https://itaku.ee/api/commissions/#{commission_id}/"
    elsif image_id.present?
      api_url =
        "https://itaku.ee/api/galleries/images/#{image_id}/"
    end

    return {} if api_url.blank?

    http.cache(1.minute).parsed_get(api_url) || {}
  end
end
