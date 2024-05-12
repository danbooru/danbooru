# frozen_string_literal: true

# @see https://dev.vk.com/ru/api/overview
# @see https://github.com/mikf/gallery-dl/blob/master/gallery_dl/extractor/vk.py
# @see svn export svn://svn.jdownloader.org/jdownloader/trunk/src/jd/plugins/hoster/VKontakteRuHoster.java
# @see Source::URL::Vk
class Source::Extractor::Vk < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif page_type == "wall" && !repost?
      # .MediaGrid__interactive grabs attached images. Ex: https://m.vk.com/wall-191516762_1706.
      # .SecondaryAttachment grabs attached files. Ex: https://m.vk.com/wall-184253008_27.
      page&.css("img.PhotoPrimaryAttachment__imageElement, a.MediaGrid__interactive, a.SecondaryAttachment").to_a.flat_map do |element|
        url = element[:src] || element[:href]
        url = URI.join("https://vk.com", url).to_s

        # Resolve both sample image URLs and document URLs (https://vk.com/doc495199190_630536868) to full image URLs.
        Source::Extractor.find(url).image_urls
      end
    elsif page_type == "photo"
      [Source::URL.parse(photo["photo"]).try(:full_image_url) || photo["photo"]].compact
    elsif page_type == "doc"
      # https://m.vk.com/doc495199190_630536868 -> https://psv4.userapi.com/c235131/u495199190/docs/d59/b94c28ecfbf7/Strakh_Pakhnet_Lyubovyu.png
      url = http.cache(1.minute).redirect_url(mobile_url, method: "GET").to_s
      [Source::URL.parse(url).try(:full_image_url) || url].compact_blank
    else
      []
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://vk.com/#{username}" if username.present?
  end

  def profile_urls
    wall_url = "https://vk.com/wall#{wall_id}" if wall_id.present?
    [profile_url, wall_url].compact
  end

  def artist_name
    if page_type == "wall"
      page&.at(".wall_item .pi_author")&.text
    elsif page_type == "photo"
      photo["album_info_subtitle"]&.parse_html&.at("a")&.text
    end
  end

  def tag_name
    username.to_s.downcase.gsub(/\A_+|_+\z/, "").squeeze("_").presence
  end

  def other_names
    [artist_name, username].compact.uniq(&:downcase)
  end

  def tags
    if page_type == "wall" && !repost?
      page&.css(".pi_text a").to_a.filter_map do |link|
        if link.text.starts_with?("#")
          # <a href="/feed?section=search&q=%23Hokuto_no_ken">#Hokuto_no_ken</a>
          # <a href="/enigmasblog/Fullart">#Fullart@enigmasblog</a>
          tag = link.text.delete_prefix("#").gsub(/@.*$/, "")
          [tag, "https://vk.com#{link["href"]}"]
        end
      end
    else
      []
    end
  end

  def artist_commentary_desc
    if page_type == "wall" && !repost?
      page&.at(".pi_text")&.to_html
    elsif page_type == "photo"
      photo["description"]
    end
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://vk.com") do |element|
      case element.name

      # Replace emoji images with actual emoji. Ex: https://m.vk.com/wall-221992613_185
      in "img" if element["src"]&.starts_with?("/emoji")
        element.name = "span"
        element["src"] = nil
        element.content = element["alt"]

      # Fix outgoing links. XXX If the outgoing link is shortened, we should unshorten it too.
      # <a href="/away.php?to=https%3A%2F%2Fgoo.gl%2FrqpZFN&amp;post=-165878884_230" target="_blank" rel="noopener nofollow">https://goo.gl/rqpZFN</a>
      in "a" if element["href"]&.starts_with?("/away.php")
        element["href"] = element["to"]

      else
        nil
      end
    end
  end

  def mobile_url
    parsed_url.mobile_url || parsed_referer&.mobile_url
  end

  def page_type
    parsed_url.page_type || parsed_referer&.page_type
  end

  def id
    parsed_url.id || parsed_referer&.id
  end

  def parent_id
    parsed_url.parent_id || parsed_referer&.parent_id
  end

  def wall_id
    parsed_url.wall_id || parsed_referer&.wall_id || photo["author_id"]
  end

  # The id of the original post, if this is a repost.
  def original_post_id
    page&.at(".wall_item")&.attr("data-copy") if page_type == "wall"
  end

  def repost?
    original_post_id.present?
  end

  def username
    if parsed_url.username.present?
      parsed_url.username
    elsif parsed_referer&.username.present?
      parsed_url.referer
    elsif page_type == "wall"
      page&.at(".wi_head .Avatar")&.attr("aria-label")
    elsif page_type == "photo"
      photo["author_href"]&.delete_prefix("/")
    end
  end

  memoize def page
    http.cache(1.minute).parsed_get(mobile_url) unless page_type == "doc"
  end

  memoize def photo
    return {} unless page.present? && page_type == "photo"

    json = page&.at("script#page_script")&.text&.slice(/.*PHOTOVIEW_PAGE":({.*})/m, 1)&.delete_suffix("}));}")&.parse_json || {}
    json["photos"].to_a.find { |photo| photo["id"] == json["initial_photo_id"] } || {}
  end

  def http
    super.cookies(remixmdevice: "1920/1080/1/!").headers("Accept-Encoding": "identity")
  end
end
