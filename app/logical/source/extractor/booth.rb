# frozen_string_literal: true

# @see Source::URL::Booth
class Source::Extractor
  class Booth < Source::Extractor
    def match?
      Source::URL::Booth === parsed_url
    end

    def image_urls
      if parsed_url.image_url?
        if parsed_url.full_image_url?
          [parsed_url.to_s]
        else
          [find_right_extension(parsed_url)]
        end
      else
        page&.css(".market-item-detail-item-image")&.pluck("data-origin").to_a.compact
      end
    end

    def profile_url
      if page.present?
        page.at(".summary [data-product-list*='shop_index']")&.[]("href")&.chomp("/")
      else
        parsed_url.profile_url || parsed_referer&.profile_url
      end
    end

    def artist_name
      return nil unless profile_url.present?
      Source::URL.parse(profile_url)&.username
    end

    def display_name
      page&.at(".summary .user-avatar")&.[]("alt")
    end

    def other_names
      [display_name].compact
    end

    def artist_commentary_title
      page&.at(".summary .u-tpg-title1")&.text
    end

    def artist_commentary_desc
      page&.at(".autolink")&.to_html
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc)
    end

    def tags
      page&.css(".item-info-detail [data-product-list*='tag_category_search']").to_a.map do |element|
        [element.text.gsub(/ x .*/, ""), element["href"]]
      end
    end

    def page_url
      parsed_url.page_url || parsed_referer&.page_url
    end

    def page
      return nil if parsed_url.page_url.blank?

      resp = http.cache(1.minute).cookies(adult: "t").get(page_url)
      return nil if resp.code != 200

      resp.parse
    end
    memoize :page

    def find_right_extension(parsed_url)
      extensions = %w[png jpg jpeg]
      candidates = extensions.map { |ext| parsed_url.full_image_url_for(ext) }

      chosen_url = candidates.find { |candidate| http_exists?(candidate) }
      chosen_url || parsed_url.to_s
    end
  end
end
