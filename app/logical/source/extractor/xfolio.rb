# frozen_string_literal: true

# @see Source::URL::Xfolio
class Source::Extractor::Xfolio < Source::Extractor
  def self.enabled?
    Danbooru.config.xfolio_session.present?
  end

  def match?
    Source::URL::Xfolio === parsed_url
  end

  def image_urls
    if work_id.present? && image_id.present?
      ["https://xfolio.jp/user_asset.php?id=#{image_id}&work_id=#{work_id}&work_image_id=#{image_id}&type=work_image"]
    elsif page.present?
      page&.search("a").to_a.pluck("href").map do |url|
        match = url.to_s.match(%r{\Ahttps://xfolio.jp/fullscale_image\?image_id=(\d+)&work_id=(\d+)\z})
        if match
          image_id, work_id = match[1..]
          "https://xfolio.jp/user_asset.php?id=#{image_id}&work_id=#{work_id}&work_image_id=#{image_id}&type=work_image"
        end
      end.compact
    else
      []
    end
  end

  def page_url
    "https://xfolio.jp/portfolio/#{username}/works/#{work_id}" if username.present? && work_id.present?
  end

  def profile_url
    "https://xfolio.jp/portfolio/#{username}" if username.present?
  end

  def username
    parsed_url.username || parsed_referer&.username
  end

  def tag_name
    username
  end

  def artist_name
    page&.search(".creatorInfo").to_a.first&.attr("data-creator-name") 
  end

  def work_id
    parsed_url.work_id || parsed_referer&.work_id
  end

  def image_id
    parsed_url.image_id || parsed_referer&.image_id
  end

  def artist_commentary_title
    page&.search(".article--detailInfo__title").to_a.first&.text&.strip
  end

  def artist_commentary_desc
    page&.search(".richDescriptionText").to_a.first&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc)
  end

  def tags
    data = page&.search(".article--detailInfo__tags").to_a.first&.attr("data-tags")
    return [] unless data

    JSON.parse(data).map do |tag| [tag["name"], tag["link"]] end
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  def http
    super.cookies(xfolio_session: Danbooru.config.xfolio_session)
  end

end
