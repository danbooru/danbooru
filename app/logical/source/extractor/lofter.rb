# frozen_string_literal: true

# @see Source::URL::Lofter
module Source
  class Extractor
    class Lofter < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        else
          [
            *images_from_photo_post,
            *images_from_video_post,
            *images_from_text_post,
            *images_from_answer_post,
          ].map do |url|
            Source::URL.parse(url).full_image_url || url
          end
        end
      end

      def images_from_photo_post
        page_json.dig("postData", "data", "postData", "postView", "photoPostView", "photoLinks").to_a.pluck("orign")
      end

      def images_from_video_post
        [page_json.dig("postData", "data", "postData", "postView", "videoPostView", "videoInfo", "originUrl")].compact
      end

      def images_from_text_post
        content = page_json.dig("postData", "data", "postData", "postView", "textPostView", "content").to_s
        content.parse_html.css("img").pluck("src")
      end

      def images_from_answer_post
        page_json.dig("postData", "data", "postData", "postView", "answerPostView", "images").to_a.pluck("orign")
      end

      def profile_url
        return nil if artist_name.blank?
        "https://#{artist_name}.lofter.com"
      end

      def page_url
        return nil if illust_id.blank? || profile_url.blank?

        "#{profile_url}/post/#{illust_id}"
      end

      def http
        super.headers("User-Agent": "Mozilla/5.0 (Android 14; Mobile; rv:115.0) Gecko/115.0 Firefox/115.0")
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      memoize def page_json
        script_text = page&.search("body script").to_a.map(&:text).grep(/\Awindow.__initialize_data__ = /).first.to_s
        script_text.strip.delete_prefix("window.__initialize_data__ = ").parse_json || {}
      end

      def tags
        page_json.dig("postData", "data", "postData", "postView", "tagList").to_a.map do |tag|
          [tag, "https://www.lofter.com/tag/#{Danbooru::URL.escape(tag)}"]
        end
      end

      def display_name
        page_json.dig("postData", "data", "blogInfo", "blogNickName")&.strip
      end

      def other_names
        [artist_name, display_name].compact_blank.uniq
      end

      def artist_commentary_title
        title_from_post || title_from_answer_post
      end

      def title_from_post
        page_json.dig("postData", "data", "postData", "postView", "title")
      end

      def title_from_answer_post
        question = page_json.dig("postData", "data", "postData", "postView", "answerPostView", "questionInfo", "question")
        return "Q:#{question}" unless question.nil?
      end

      def artist_commentary_desc
        desc_from_photo_post || desc_from_video_post || desc_from_text_post || desc_from_answer_post
      end

      def desc_from_photo_post
        page_json.dig("postData", "data", "postData", "postView", "photoPostView", "caption")
      end

      def desc_from_video_post
        page_json.dig("postData", "data", "postData", "postView", "videoPostView", "caption")
      end

      def desc_from_text_post
        page_json.dig("postData", "data", "postData", "postView", "textPostView", "content")
      end

      def desc_from_answer_post
        page_json.dig("postData", "data", "postData", "postView", "answerPostView", "answer")
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://www.lofter.com")&.normalize_whitespace&.gsub(/\r\n/, "\n")&.gsub(/ *\n */, "\n")&.strip
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def artist_name
        parsed_url.username || parsed_referer&.username
      end
    end
  end
end
