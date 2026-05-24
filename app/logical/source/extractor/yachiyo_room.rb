# frozen_string_literal: true

class Source::Extractor::YachiyoRoom < Source::Extractor
    delegate :image_url?, :page_url?, :profile_url?, to: :parsed_url

    def image_urls
        return [parsed_url.to_s] if image_url?
        return [page.at("img[src^='https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/']")[:src]] if page_url?

        []
    end

    def display_name
        return parsed_url.params["name"] if profile_url?

        page.at("a[href^='/gallery?name=']")&.text if page_url?
    end

    def profile_url
        "https://yachiyo-room.com/gallery?name=#{display_name}" if display_name.present?
    end

    def artist_commentary_title
        page.at("td:contains('タイトル')")&.next_sibling&.text if page_url?
    end

    def artist_commentary_desc
        page.at("td:contains('タイトル')")&.parent&.parent&.parent&.next_sibling&.text if page_url?
    end

    def published_at
        Time.at(Source::URL.parse(image_urls.dig(0)).timestamp / 1000) if page_url? || image_url?
    end

    def tags
        return page.search("a[href^='/gallery?tag=']").map do |a|
            [
                a.text.strip,
                "https://yachiyo-room/#{a[:href]}"
            ]
        end if page_url?

        []
    end

    memoize def page
        http.cache(1.minute).parsed_get(parsed_url.page_url) if page_url?
    end
end
