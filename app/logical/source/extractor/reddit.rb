# frozen_string_literal: true

# @see Source::URL::Reddit
module Source
  class Extractor
    class Reddit < Source::Extractor
      def match?
        Source::URL::Reddit === parsed_url
      end

      def image_urls
        if parsed_url&.full_image_url.present?
          [parsed_url.full_image_url]
        elsif data.present?
          images = [data.dig("media", "resolutions", 0, "url")].compact
          images += ordered_gallery_images
          images.compact.uniq.map { |i| Source::URL.parse(i)&.full_image_url }.compact
        else
          [parsed_url.original_url]
        end
      end

      def ordered_gallery_images
        gallery_images = data.dig("media", "mediaMetadata")
        return [] unless gallery_images.present?
        gallery_order = data.dig("media", "gallery", "items").pluck("mediaId")

        gallery_order.map { |id| gallery_images[id].dig("s", "u") }
      end

      def profile_url
        return nil if artist_name.blank?
        "https://reddit.com/user/#{artist_name}"
      end

      def page_url
        data["permalink"] || parsed_url.page_url || parsed_referer&.page_url
      end

      def artist_commentary_title
        data["title"]
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def artist_name
        data["author"] || parsed_url.username || parsed_referer&.username
      end

      def data
        return {} if work_id.blank?

        response = http.cache(1.minute).get("https://reddit.com/gallery/#{work_id}")
        return {} if response.status != 200

        json_string = response.parse&.at("script#data").to_s[/\s({.*})/, 1]
        data = JSON.parse(json_string).with_indifferent_access
        data.dig("posts", "models").values.min_by { |p| p["created"].to_i } # to avoid reposts
      rescue JSON::ParserError
        {}
      end

      memoize :data
    end
  end
end
