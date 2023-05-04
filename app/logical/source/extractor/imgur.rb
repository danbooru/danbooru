# frozen_string_literal: true

# @see https://imgur.com
# @see https://apidocs.imgur.com/
# @see Source::URL::Imgur
module Source
  class Extractor
    class Imgur < Source::Extractor
      # This is the public client_id that the Imgur website uses to make API calls. gallery-dl has been using it since
      # 2019, so hardcoding it should be fine.
      IMGUR_CLIENT_ID = "546c25a59c58ad7"

      def match?
        Source::URL::Imgur === parsed_url
      end

      def image_urls
        # For .mp4 files (e.g. https://i.imgur.com/Kp9TdlX.mp4), we have to use the API to tell whether the original image is a .gif or not.
        if parsed_url.image_url? && parsed_url.file_ext == "mp4"
          image_urls_from_api.select { |url| Source::URL.parse(url).image_id == parsed_url.image_id }
        elsif parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          image_urls_from_api
        end
      end

      def image_urls_from_api
        api_response.dig(:media).to_a.pluck(:url)
      end

      def page_url
        if album_id.present?
          "https://imgur.com/a/#{album_id}"
        elsif image_id.present?
          "https://imgur.com/#{image_id}"
        end
      end

      def profile_url
        "https://imgur.com/user/#{artist_name}" if artist_name
      end

      def artist_name
        api_response.dig(:account, :username)
      end

      # XXX Each image in an album can have a separate title, tags, and description.
      def artist_commentary_title
        api_response[:title]
      end

      def artist_commentary_desc
        api_response[:description]
      end

      def tags
        api_response[:tags].to_a.pluck(:tag).map do |tag|
          [tag, "https://imgur.com/t/#{CGI.escape(tag)}"]
        end
      end

      def image_id
        parsed_url.image_id || parsed_referer&.image_id
      end

      def album_id
        parsed_url.album_id || parsed_referer&.album_id
      end

      def api_url
        if album_id.present?
          "https://api.imgur.com/post/v1/posts/#{album_id}?include=media,tags,account&client_id=#{IMGUR_CLIENT_ID}"
        elsif image_id.present?
          "https://api.imgur.com/post/v1/media/#{image_id}?include=media,tags,account&client_id=#{IMGUR_CLIENT_ID}"
        end
      end

      memoize def api_response
        # Imgur uses a custom 'application/vnd.imgur.v1+json' content type that isn't recognized by `response.parse`
        http.cache(1.minute).parsed_get(api_url, format: :json) || {}
      end
    end
  end
end
