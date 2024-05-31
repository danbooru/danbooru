# frozen_string_literal: true

# @see https://enty.jp
# @see Source::URL::Enty
module Source
  class Extractor
    class Enty < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.to_s]
        else
          image_urls_from_commentary
        end
      end

      def image_urls_from_commentary
        return [] if page.nil?

        images = page.css("#post-main-content-block img").pluck(:src)
        links = page.css("#post-main-content-block a").pluck(:href)
        urls = images + links

        urls.select { |url| Source::URL.parse(url)&.image_url? }
      end

      def profile_url
        "https://enty.jp/#{username}" if username.present?
      end

      def profile_urls
        urls = profile_page&.css("#main-content a")&.pluck(:href).to_a
        urls.filter_map { |url| Source::URL.parse(url).profile_url }.sort.uniq
      end

      def username
        page&.css("#breadcrumbs-one > li:nth-child(1) > a")&.attr("href")&.to_s&.delete_prefix("/")
      end

      def display_name
        page&.css("#breadcrumbs-one > li:nth-child(1) > a")&.text&.normalize_whitespace&.strip
      end

      def artist_commentary_title
        page&.css("h4.article-post-title")&.text&.strip
      end

      def artist_commentary_desc
        page&.css(".user-content.main-content-body")&.to_s
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      memoize def profile_page
        http.cache(1.minute).parsed_get(profile_url)
      end
    end
  end
end
