# frozen_string_literal: true

# @see Source::URL::Newgrounds
module Source
  class Extractor
    class Newgrounds < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.candidate_full_image_urls.present?
          full_image_url = parsed_url.candidate_full_image_urls.find { |url| http_exists?(url) }
          [full_image_url.presence || url]
        elsif parsed_url.image_url?
          [url]
        elsif video_data.present?
          sample = video_data&.[]("sources")&.max_by { |k, _v| k.gsub(/p$/, "").to_i }&.dig(1, 0, "src")
          final = [Source::URL.parse(sample)&.full_image_url, sample].compact.find { |u| http_exists?(u) }
          [final].compact
        else
          urls = []

          if page&.css(".art-view-gallery").present?
            urls += image_urls_from_gallery
          elsif page&.css(".art-images").present?
            urls += page&.css(".image a[data-action]").to_a.pluck("href")
          else
            urls += page&.css(".image img").to_a.pluck("src")
          end

          urls += page&.css("#author_comments img[data-user-image='1']").to_a.map { |img| img["data-smartload-src"] || img["src"] }

          urls.compact
        end
      end

      def image_urls_from_gallery
        script = page&.css("script")&.find { |node| node.text.match?(/let imageData =/) }
        images = script&.text.to_s[/let imageData =(.*?);/m, 1]&.parse_json || []
        images.pluck("image")
      end

      def tags
        page&.css("#sidestats .tags a").to_a.map do |tag|
          [tag.text, "https://www.newgrounds.com/search/conduct/art?match=tags&tags=#{tag.text}"]
        end
      end

      def normalize_tag(tag)
        tag = tag.tr("-", "_")
        super(tag)
      end

      def display_name
        page&.at(".item-user .item-details h4 a")&.text&.strip
      end

      def username
        Source::URL.parse(page&.at(".item-user .item-details h4 a")&.attr("href"))&.username || parsed_url.username || parsed_referer&.username
      end

      def profile_url
        "https://#{username}.newgrounds.com" if username.present?
      end

      def artist_commentary_title
        page&.css(".pod-head > [itemprop='name']")&.text
      end

      def artist_commentary_desc
        return "" if page.nil?
        page.dup.css("#author_comments").tap { _1.css("ul.itemlist").remove }.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://www.newgrounds.com").strip
      end

      def illust_title
        parsed_url.work_title || parsed_referer&.work_title
      end

      def video_id
        parsed_url.video_id || parsed_referer&.video_id
      end

      def http
        super.cookies(vmkIdu5l8m: Danbooru.config.newgrounds_session_cookie)
      end

      def video_page_url
        "https://www.newgrounds.com/portal/video/#{video_id}" if video_id.present?
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      memoize def video_data
        # flash files return {"error"=>{"code"=>404, "msg"=>"The submission you are looking for does not have a video."}}
        response = http.headers("X-Requested-With": "XMLHttpRequest").cache(1.minute).parsed_get(video_page_url, format: :json)
      end
    end
  end
end
