# frozen_string_literal: true

# @see Source::URL::Tinami
module Source
  class Extractor
    class Tinami < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [url]

        # http://www.tinami.com/view/1087268 (single image)
        elsif page&.css("img.captify")&.size.to_i == 1
          [full_image_url].compact

        # http://www.tinami.com/view/1087270 (multiple images)
        elsif image_sub_ids.present?
          image_sub_ids.map { |sub_id| full_image_url(sub_id) }.compact

        # http://www.tinami.com/view/1087271 (multiple images)
        elsif nv_body_image_urls.present?
          nv_body_image_urls

        # http://www.tinami.com/view/1087267 (no images, text only)
        else
          []
        end
      end

      def nv_body_image_urls
        page&.css(".viewbody .nv_body img").to_a.map do |img|
          "https:#{img[:src]}" # img[:src] == "//img.tinami.com/illust2/img/619/6234b647da609.jpg"
        end
      end

      def image_sub_ids
        page&.css(".viewbody #controller_model .thumbnail_list").to_a.map { |td| td.attr("sub_id") }
      end

      def tags
        page&.css("#view .tag a[href^='/search/list']").to_a.map do |tag|
          [tag.text, "https://www.tinami.com/search/list?keyword=#{Danbooru::URL.escape(tag.text)}"]
        end
      end

      def profile_url
        "https://www.tinami.com/creator/profile/#{user_id}" if user_id.present?
      end

      def tag_name
        "tinami_#{user_id}" if user_id.present?
      end

      def display_name
        page&.at("#view .prof > p > a > strong")&.text
      end

      def artist_commentary_title
        page&.at("#view .viewdata h1")&.text.to_s.strip
      end

      def artist_commentary_desc
        page&.at("#view .comment .description")&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "http://www.tinami.com")
      end

      def user_id
        url = page&.at("#view .prof > p > a")&.attr("href")&.prepend("https://www.tinami.com")
        Source::URL.parse(url)&.user_id
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def ethna_csrf
        page&.at("#open_original_content input[name=ethna_csrf]")&.attr("value")
      end

      def full_image_url(sub_id = nil)
        return nil unless work_id.present? && ethna_csrf.present?

        # Note that we have to spoof the Referer here.
        response = http.post(page_url, form: { action_view_original: true, cont_id: work_id, sub_id: sub_id, ethna_csrf: ethna_csrf })
        return nil unless response.status == 200

        response.parse.at("body > div > a > img[src^='//img.tinami.com']")&.attr("src")&.prepend("https:")
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      def http
        super.cookies(Tinami2SESSID: Danbooru.config.tinami_session_id).use(:spoof_referrer)
      end

      memoize :user_id, :work_id, :ethna_csrf, :image_urls, :image_sub_ids, :nv_body_image_urls
    end
  end
end
