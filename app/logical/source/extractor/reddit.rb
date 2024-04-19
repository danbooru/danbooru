# frozen_string_literal: true

# @see Source::URL::Reddit
module Source
  class Extractor
    class Reddit < Source::Extractor
      def image_urls
        if parsed_url&.full_image_url.present?
          [parsed_url.full_image_url]
        elsif data.present?
          images = [data.dig("media", "content")].compact
          images += ordered_gallery_images
          images.compact.uniq.map { |i| Source::URL.parse(i)&.full_image_url }.compact
        else
          []
        end
      end

      def ordered_gallery_images
        gallery_images = data.dig("media", "mediaMetadata")

        gallery_order = data.dig("media", "gallery", "items").to_a.pluck("mediaId")
        gallery_order = data.dig("media", "richtextContent", "document").to_a.pluck("id").compact if gallery_order.blank?

        gallery_images.to_h.values_at(*gallery_order).compact.pluck("s").pluck("u")
      end

      def profile_url
        return nil if artist_name.blank?
        "https://www.reddit.com/user/#{artist_name}"
      end

      def page_url
        data["permalink"] || parsed_url.page_url || parsed_referer&.page_url
      end

      def artist_commentary_title
        data["title"]
      end

      def work_id
        if share_url.present?
          redirect_url = http.redirect_url(share_url)
          Source::URL.parse(redirect_url)&.work_id
        else
          parsed_url.work_id || parsed_referer&.work_id
        end
      end

      def artist_name
        data["author"] || parsed_url.username || parsed_referer&.username
      end

      def share_url
        parsed_urls.find(&:share_id)
      end

      def api_url
        "https://reddit.com/gallery/#{work_id}" if work_id.present?
      end

      memoize def data
        html = http.cache(1.minute).parsed_get(api_url)

        json_string = html&.at("script#data").to_s[/\s({.*})/, 1].to_s
        data = JSON.parse(json_string).with_indifferent_access
        data.dig("posts", "models").values.min_by { |p| p["created"].to_i } || {} # to avoid reposts
      rescue JSON::ParserError
        {}
      end
    end
  end
end
