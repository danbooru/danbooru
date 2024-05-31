# frozen_string_literal: true

# @see Source::URL::Xfolio
class Source::Extractor::Xfolio < Source::Extractor
  def self.enabled?
    Danbooru.config.xfolio_session.present?
  end

  def image_urls
    if work_id.present? && image_id.present?
      ["https://xfolio.jp/user_asset.php?id=#{image_id}&work_id=#{work_id}&work_image_id=#{image_id}&type=work_image"]
    elsif page.present?
      page&.css(".article__wrap_img").to_a.map do |wrap_img|
        a = wrap_img.search("a").first
        img = wrap_img.search("img").first
        if a
          match = a.attr("href").match(%r{\Ahttps://xfolio.jp/fullscale_image\?image_id=(\d+)&work_id=(\d+)\z})
          image_id, work_id = match[1..]
          "https://xfolio.jp/user_asset.php?id=#{image_id}&work_id=#{work_id}&work_image_id=#{image_id}&type=work_image"
        elsif img
          img.attr("src")
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

  def display_name
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
    DText.from_html(artist_commentary_desc, base_url: "https://xfolio.jp")
  end

  def tags
    tags = page&.at(".article--detailInfo__tags")&.attr("data-tags")&.parse_json.to_a
    tags.map { |tag| [tag["name"], tag["link"]] }
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  def http
    super.cookies(xfolio_session: Danbooru.config.xfolio_session)
  end
end
