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
        post.dig(:photoPostView, :photoLinks).to_a.pluck(:orign)
      end

      def images_from_video_post
        [post.dig(:videoPostView, :videoInfo, :originUrl)].compact
      end

      def images_from_text_post
        post.dig(:textPostView, :content)&.parse_html&.css("img").to_a.pluck("src")
      end

      def images_from_answer_post
        post.dig(:answerPostView, :images).to_a.pluck("orign")
      end

      def profile_url
        parsed_url.profile_url || parsed_referer&.profile_url
      end

      def tags
        post[:tagList].to_a.map do |tag|
          [tag, "https://www.lofter.com/tag/#{Danbooru::URL.escape(tag)}"]
        end
      end

      def display_name
        page_json.dig(:postData, :data, :blogInfo, :blogNickName)&.strip
      end

      def username
        parsed_url.username || parsed_referer&.username
      end

      def artist_commentary_title
        title_from_post || title_from_answer_post
      end

      def title_from_post
        post[:title]
      end

      def title_from_answer_post
        question = post.dig(:answerPostView, :questionInfo, :question)
        "Q:#{question}" unless question.nil?
      end

      def artist_commentary_desc
        post.dig(:photoPostView, :caption) || post.dig(:videoPostView, :caption) || post.dig(:textPostView, :content) || post.dig(:answerPostView, :answer)
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://www.lofter.com")
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

      memoize def post
        page_json.dig(:postData, :data, :postData, :postView) || {}
      end
    end
  end
end
