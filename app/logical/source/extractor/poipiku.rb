# frozen_string_literal: true

# @see Source::URL::Poipiku
class Source::Extractor
  class Poipiku < Source::Extractor
    delegate :page_url, :profile_url, :user_id, :post_id, to: :parsed_url

    def image_urls
      if parsed_url.image_url?
        [parsed_url.full_image_url]
      else
        image_urls_from_html
      end
    end

    def image_urls_from_html
      first_image = page&.at("img.IllustItemThumbImg")&.attr(:src).to_s
      additional_images = additional_images_html&.css("img").to_a.pluck(:src)

      [first_image, *additional_images].map do |url|
        # url = "//img.poipiku.com/user_img03/000013318/007865949_015701153_EcvKNO8Dt.png_640.jpg"
        url = "https:" + url if url.starts_with?("//")
        Source::URL.parse(url)&.full_image_url
      end.compact
    end

    def profile_urls
      urls = page&.css(".UserInfoProfile a").to_a.pluck(:href).map do |url|
        Source::URL.parse(url)&.profile_url
      end

      [profile_url, *urls].compact_blank.uniq
    end

    def tag_name
      if super.present?
        super
      elsif parsed_url.user_id.present?
        "poipiku_#{parsed_url.user_id}"
      end
    end

    def artist_name
      page&.css(".UserInfoUserName")&.first&.text
    end

    def artist_commentary_desc
      page&.css(".IllustItemDesc")&.inner_html
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc, base_url: "https://poipiku.com")
    end

    def tags
      page&.css(".IllustItemTag div.TagName").to_a.map do |tag|
        tag = tag.text.gsub(/^#+/, "")
        [tag, "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=#{Danbooru::URL.escape(tag)}"]
      end
    end

    memoize def page
      http.cache(1.minute).parsed_get(page_url)
    end

    memoize def additional_images_html
      return nil if user_id.blank? || post_id.blank?

      html = http.cookies(POIPIKU_LK: Danbooru.config.poipiku_session_cookie).use(:spoof_referrer).cache(1.minute).parsed_post("https://poipiku.com/f/ShowAppendFileF.jsp", form: { UID: user_id, IID: post_id })
      html&.text&.parse_json&.dig("html")&.parse_html
    end
  end
end
