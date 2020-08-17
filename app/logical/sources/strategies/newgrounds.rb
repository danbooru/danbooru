# Image Urls
# * https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg
# * https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181
# * https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg
#
# Page URLs
# * https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat
# * https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic (multiple)
#
# Profile URLs
# * https://natthelich.newgrounds.com/

module Sources
  module Strategies
    class Newgrounds < Base
      IMAGE_URL   = %r{\Ahttps?://art\.ngfiles\.com/images/\d+/\d+_(?<user_name>[0-9a-z-]+)_(?<illust_title>[0-9a-z-]+)\.\w+}i
      COMMENT_URL = %r{\Ahttps?://art\.ngfiles\.com/comments/\d+/\w+\.\w+}i

      PAGE_URL    = %r{\Ahttps?://(?:www\.)?newgrounds\.com/art/view/(?<user_name>[0-9a-z-]+)/(?<illust_title>[0-9a-z-]+)(?:\?.*)?}i

      PROFILE_URL = %r{\Ahttps?://(?<artist_name>(?!www)[0-9a-z-]+)\.newgrounds\.com(?:/.*)?}i

      def domains
        ["newgrounds.com", "ngfiles.com"]
      end

      def site_name
        "NewGrounds"
      end

      def image_urls
        if url =~ COMMENT_URL || url =~ IMAGE_URL
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

        response = http.cache(1.minute).get(page_url)
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
        page&.css("#author_comments")&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc)
      end

      def normalize_for_source
        page_url
      end

      def user_name
        urls.map { |u| url[PROFILE_URL, :artist_name] || u[IMAGE_URL, :user_name] || u[PAGE_URL, :user_name] }.compact.first
      end

      def illust_title
        urls.map { |u| u[IMAGE_URL, :illust_title] || u[PAGE_URL, :illust_title] }.compact.first
      end
    end
  end
end
