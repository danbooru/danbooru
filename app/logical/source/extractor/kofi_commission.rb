# frozen_string_literal: true

# @see Source::Extractor::Kofi
class Source::Extractor::KofiCommission < Source::Extractor::Kofi
  def image_urls
    super.presence || commission[:Previews].to_a.pluck(:DisplayFileName)
  end

  def artist_commentary_title
    commission[:Name]
  end

  def artist_commentary_desc
    commission[:Description]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def commission_id
    parsed_url.commission_id || parsed_referer&.commission_id
  end

  def profile_page
    commission_page
  end

  memoize def commission_page
    # Use Ko-fi's backend IP to bypass Cloudflare protection on the https://ko-fi.com/c/:id endpoint.
    url = "https://104.45.231.79/c/#{commission_id}" if commission_id.present?
    response = http.with_legacy_ssl.headers(Host: "ko-fi.com").no_follow.cache(1.minute).get(url)

    redirect_url = "https://ko-fi.com#{response[:Location]}" if response.status.in?(300..399)
    http.cache(1.minute).parsed_get(redirect_url)
  end

  memoize def commissions
    url = "https://ko-fi.com/shop/#{user_id}/items/0/0?productType=1" if user_id.present?
    http.cache(1.minute).parsed_get(url) || []
  end

  memoize def commission
    commissions.find { |c| c["Alias"] == commission_id }&.with_indifferent_access || {}
  end
end
