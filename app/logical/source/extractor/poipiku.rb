# frozen_string_literal: true

# @see Source::URL::Poipiku
class Source::Extractor
  class Poipiku < Source::Extractor
    delegate :profile_url, :user_id, to: :parsed_url

    # Paswords to check.
    # Password parameter is ignored when it's not needed, so no need for an explicit empty password
    PASSWORDS = %w[y yes]

    def image_urls
      api_html&.css("img.DetailIllustItemImage").to_a.pluck(:src).map do |url|
        Source::URL.parse(url)&.full_image_url
      end&.compact
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

    def display_name
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

    def page_url
      # The original parsed_url.page_url may redirect to a different page with a different post ID; get the final page.
      page&.at_css('link[rel="canonical"]')&.attr(:href) || parsed_url.page_url
    end

    def post_id
      Source::URL.parse(page_url).try(:post_id)
    end

    memoize def page
      parsed_get(parsed_url.page_url)
    end

    memoize def api_html
      return nil if user_id.blank? || post_id.blank?

      PASSWORDS.each do |pw|
        res = http.cookies(POIPIKU_LK: credentials[:session_cookie], POIPIKU_CONTENTS_VIEW_MODE: 1)
                  .headers(Referer: "https://poipiku.com")
                  .parsed_post(
                    "https://poipiku.com/f/ShowIllustDetailF.jsp",
                    form: { ID: user_id, TD: post_id, PAS: pw },
                  )&.text&.parse_json

        return res[:html].parse_html if res[:result] == 1
      end

      nil
    end
  end
end
