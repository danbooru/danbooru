# frozen_string_literal: true

# @see Source::URL::Tinami
module Sources
  module Strategies
    class Tinami < Base

      def match?
        Source::URL::Tinami === parsed_url
      end

      def image_urls
        if parsed_url.image_url?
          [url]
        else
          # Page type 1: http://www.tinami.com/view/1087268
          # Page type 2: http://www.tinami.com/view/1087271
          # Page type 3: http://www.tinami.com/view/1087270
          # Page type 4: http://www.tinami.com/view/1087267 (no images, text only)
          page&.css(".viewbody img.captify, .viewbody .nv_body img").to_a.map do |img|
            # img[:src] == "//img.tinami.com/illust2/img/619/6234b647da609.jpg"
            "https:#{img[:src]}"
          end
        end
      end

      def page_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def tags
        page&.css("#view .tag a[href^='/search/list']").to_a.map do |tag|
          [tag.text, "https://www.tinami.com/search/list?keyword=#{CGI.escape(tag.text)}"]
        end
      end

      def profile_url
        "https://www.tinami.com/creator/profile/#{user_id}" if user_id.present?
      end

      def tag_name
        nil
      end

      def artist_name
        page&.at("#view .prof > p > a > strong")&.text
      end

      def artist_commentary_title
        page&.at("#view .viewdata h1")&.text.to_s.strip
      end

      def artist_commentary_desc
        page&.at("#view .comment .description")&.text.to_s.strip.delete("\t")
      end

      def user_id
        url = page&.at("#view .prof > p > a")&.attr("href")&.prepend("https://www.tinami.com")
        Source::URL.parse(url)&.user_id
      end

      def page
        return nil if page_url.blank?

        response = http.cache(1.minute).get(page_url)
        return nil unless response.status == 200

        response.parse
      end

      memoize :page, :user_id
    end
  end
end
