# frozen_string_literal: true

# @see https://arca.live
# @see Source::URL::ArcaLive
module Source
  class Extractor
    class ArcaLive < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          image_urls_from_commentary.map do |url|
            url = image_urls_from_api.find { |u| u.filename == url.filename } || url
            url.full_image_url || url.to_s
          end
        end
      end

      # The commentary contains all the videos and images, but not the original files, only samples.
      # The API has to be used to find the originals.
      memoize def image_urls_from_commentary
        artist_commentary_desc.to_s.parse_html.css("img:not(.arca-emoticon), video:not(.arca-emoticon)").to_a.filter_map do |element|
          url = element.attr("data-originalurl") || element.attr("src")
          Source::URL.parse(URI.join("https:", url).to_s)
        end
      end

      # The API contains the original images, but not the videos.
      memoize def image_urls_from_api
        api_response[:images].to_a.filter_map do |url|
          Source::URL.parse(URI.join("https:", url).to_s)
        end
      end

      def profile_url
        if username.present? && artist_id.present?
          "https://arca.live/u/@#{username}/#{artist_id}"
        elsif username.present?
          "https://arca.live/u/@#{username}"
        end
      end

      def page_url
        channel = api_response["boardSlug"] || parsed_url.channel || parsed_referer&.channel || "breaking"
        post_id = api_response["id"] || parsed_url.post_id || parsed_referer&.post_id
        "https://arca.live/b/#{channel}/#{post_id}" if channel.present? && post_id.present?
      end

      def username
        api_response["nickname"]
      end

      def artist_id
        api_response["publicId"]
      end

      def artist_commentary_title
        api_response["title"]
      end

      def artist_commentary_desc
        api_response["content"]
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://arca.live") do |element|
          case element.name
          in "a" if element["href"].present?
            element["href"] = element["href"].gsub(%r{\Ahttps?://unsafelink\.com/}i, "")
          in "video" unless element["class"]&.include?("arca-emoticon")
            element.content = "[video]"
          else
            nil
          end
        end.gsub(/\n\n+/, "\n\n").strip
      end

      def post_id
        parsed_url.post_id || parsed_referer&.post_id
      end

      def api_url
        "https://arca.live/api/app/view/article/breaking/#{post_id}" if post_id.present?
      end

      def http
        super.headers("User-Agent": "net.umanle.arca.android.playstore/0.9.75")
      end

      def http_downloader
        super.disable_feature(:spoof_referrer)
      end

      memoize def api_response
        http.cache(1.minute).parsed_get(api_url) || {}
      end
    end
  end
end
