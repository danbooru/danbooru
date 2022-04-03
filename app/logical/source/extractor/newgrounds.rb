# frozen_string_literal: true

# @see Source::URL::Newgrounds
module Source
  class Extractor
    class Newgrounds < Source::Extractor
      def match?
        Source::URL::Newgrounds === parsed_url
      end

      def image_urls
        if parsed_url.image_url?
          [url]
        else
          urls = []

          urls += page&.css(".image img").to_a.map { |img| img["src"] }
          urls += page&.css("#author_comments img[data-user-image='1']").to_a.map { |img| img["data-smartload-src"] || img["src"] }

          urls.compact
        end
      end

      def page_url
        return nil if illust_title.blank? || user_name.blank?

        "https://www.newgrounds.com/art/view/#{user_name}/#{illust_title}"
      end

      def page
        return nil if page_url.blank?

        response = http.cookies(vmkIdu5l8m: Danbooru.config.newgrounds_session_cookie).cache(1.minute).get(page_url)
        return nil if response.status == 404

        response.parse
      end
      memoize :page

      def tags
        page&.css("#sidestats .tags a").to_a.map do |tag|
          [tag.text, "https://www.newgrounds.com/search/conduct/art?match=tags&tags=" + tag.text]
        end
      end

      def normalize_tag(tag)
        tag = tag.tr("-", "_")
        super(tag)
      end

      def artist_name
        name = page&.css(".item-user .item-details h4 a")&.text&.strip || user_name
        name&.downcase
      end

      def other_names
        [artist_name, user_name].compact.uniq
      end

      def profile_url
        # user names are not mutable, artist names are.
        # However we need the latest name for normalization
        "https://#{artist_name}.newgrounds.com"
      end

      def artist_commentary_title
        page&.css(".pod-head > [itemprop='name']")&.text
      end

      def artist_commentary_desc
        return "" if page.nil?
        page.dup.css("#author_comments").tap { _1.css("ul.itemlist").remove }.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc).strip
      end

      def user_name
        parsed_url.username || parsed_referer&.username
      end

      def illust_title
        parsed_url.work_title || parsed_referer&.work_title
      end
    end
  end
end
