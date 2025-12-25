# frozen_string_literal: true

# @see Source::URL::Huashijie
module Source
  class Extractor
    class Huashijie < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        elsif work.present?
          work[:multiImages].to_a.map do |map|
            image_url = map[:orgPath]
            if map[:videoPath] != ""
              image_url = map[:videoPath].split(",").first
            end
            Source::URL.parse(image_url).try(:full_image_url) || image_url
          end
        elsif product.present?
          product[:imageUrls].to_a.map do |url|
            Source::URL.parse(url).try(:full_image_url) || url
          end
        else
          []
        end
      end

      def profile_url
        "https://www.huashijie.art/user/index/#{user_id}" if user_id.present?
      end

      def display_name
        user[:nick]&.strip
      end

      def tag_name
        "huashijie_#{user_id}" if user_id.present?
      end

      def tags
        if work.present?
          work[:faction].to_a.map do |tag|
            [tag[:name], "https://www.huashijie.art/topic/#{tag[:id]}"]
          end
        else
          []
        end
      end

      def artist_commentary_title
        if product.present?
          product[:title]
        end
      end

      def artist_commentary_desc
        if work.present?
          work[:content]
        elsif product.present?
          product[:description]
        end
      end

      def user_id
        user[:id] || parsed_url.user_id || parsed_referer&.user_id
      end

      def user
        if work.present?
          work[:user]
        elsif product.present?
          product[:user]
        else
          {}
        end
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def product_id
        parsed_url.product_id || parsed_referer&.product_id
      end

      def work_api_url
        "https://app.huashijie.art/api/work/detail?channel=wap&platform=wap&userId=#{credentials[:user_id]}&token=#{credentials[:session_cookie]}&workId=#{work_id}" if work_id.present?
      end

      def product_api_url
        "https://app.huashijie.art/api/product/detail?channel=wap&platform=wap&userId=#{credentials[:user_id]}&token=#{credentials[:session_cookie]}&productId=#{product_id}" if product_id.present?
      end

      memoize def work
        return {} unless work_id.present?

        http.cache(1.minute).parsed_get(work_api_url)&.dig(:data) || {}
      end

      memoize def product
        return {} unless product_id.present?

        http.cache(1.minute).parsed_get(product_api_url)&.dig(:data) || {}
      end
    end
  end
end
