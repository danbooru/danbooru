# frozen_string_literal: true

# @see Source::URL::Piapro
class Source::Extractor::Piapro < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif download_url.present?
      [download_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      []
    end
  end

  memoize def download_url
    return nil unless content_id.present? && download_token.present? && post_type != "text"

    http.cache(1.minute).post("https://piapro.jp/download/content/", form: {
      "DownloadContent[contentId]": content_id,
      "DownloadContent[subId]": sub_id,
      "DownloadContent[license]": 1,
      "DownloadContent[_token]": download_token,
    })&.uri.to_s
  end

  def page_url
    if content_id.present?
      "https://piapro.jp/content/#{content_id}"
    else
      parsed_url.page_url || parsed_referer&.page_url
    end
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url ||
      page&.at(".contents_creator > a")&.attr("href")&.then { |url| URI.join("https://piapro.jp", url).to_s }
  end

  def display_name
    page&.at(".contents_creator .contents_creator_txt")&.text
  end

  def username
    Source::URL.parse(profile_url)&.username
  end

  def artist_commentary_title
    page&.at("h1.contents_title")&.text
  end

  def artist_commentary_desc
    page&.at("div.contents_description")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://piapro.jp") do |element|
      # <a href="/jump/?url=http%3A%2F%2Fbit.ly%2FobhXVP" target="_blank">http://bit.ly/obhXVP</a>
      if element.name == "a" && element["href"]&.starts_with?("/jump")
        element["href"] = Addressable::URI.parse(element["href"]).query_values["url"] || element["href"]
      end
    end
  end

  def tags
    page&.css(".contents_taglist .tag a").to_a.map do |tag|
      [tag.text, "https://piapro.jp/content_list/?view=image&tag=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def downloads_enabled?
    page.present? && page.at(".contents_license_list .no_license").nil?
  end

  memoize def post_type
    # <div class="page_contents_inner"><section class="contents_box contents_illust">...
    classes = page&.at("div.page_contents_inner > section.contents_box")&.classes.to_a
    classes.last.delete_prefix("contents_") # => "illust", "music", "text", or "3d"
  end

  memoize def content_id
    parsed_url.content_id || parsed_referer&.content_id || page&.at("#DownloadContent_contentId")&.attr("value")
  end

  memoize def sub_id
    page&.at("#DownloadContent_subId")&.attr("value")
  end

  # The download token seems to be the same for all posts for the duration of the login session.
  memoize def download_token
    page&.at("#DownloadContent__token")&.attr("value")
  end

  memoize def page
    url = parsed_url.page_url || parsed_referer&.page_url
    http.cache(1.minute).parsed_get(url)
  end

  def http
    super.cookies(piapro_s: Danbooru.config.piapro_session_cookie)
  end
end
