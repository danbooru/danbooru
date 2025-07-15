# frozen_string_literal: true

# @see Source::URL::Huajia
module Source
  class Extractor
    class Huajia < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        elsif work.present?
          url = work.dig("work", "file_url")
          [Source::URL.parse(url)&.full_image_url || url]
        elsif goods.present?
          goods["description_images"].to_a.pluck("file_url").map do |url|
            Source::URL.parse(url)&.full_image_url || url
          end
        elsif commission.present?
          # We may also need to fetch images from character_settings.
          commission["images"].to_a.pluck("file_url").map do |url|
            Source::URL.parse(url)&.full_image_url || url
          end
        else
          []
        end
      end

      def profile_url
        "https://huajia.163.com/main/profile/#{user_id}" if user_id.present?
      end

      def display_name
        user["name"]
      end

      def artist_commentary_title
        if goods.present?
          goods["name"]
        elsif commission.present?
          commission["title"]
        end
      end

      def artist_commentary_desc
        if goods.present?
          goods["description"]
        elsif commission.present?
          commission["description"]
        end
      end

      def user_id
        user["uid"] || parsed_url.user_id || parsed_referer&.user_id unless commission.present?
      end

      def user
        if work.present?
          work["author"]
        elsif goods.present?
          goods["user"]
        else
          {}
        end
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def goods_id
        parsed_url.goods_id || parsed_referer&.goods_id
      end

      def commission_id
        parsed_url.commission_id || parsed_referer&.commission_id
      end

      memoize def work
        return {} unless work_id.present?

        http.cache(1.minute).parsed_get("https://huajia.163.com/napp/work/detail?work_id=#{work_id}")&.dig("data") || {}
      end

      memoize def goods
        return {} unless goods_id.present?

        http.cache(1.minute).parsed_get("https://huajia.163.com/napp/store/goods/detail?goods_id=#{goods_id}")&.dig("data", "goods") || {}
      end

      memoize def commission
        return {} unless commission_id.present?

        http.cache(1.minute).parsed_get("https://huajia.163.com/napp/commission/commission/detail?commission_id=#{commission_id}")&.dig("data", "commission") || {}
      end

      # character_setting
    end
  end
end
