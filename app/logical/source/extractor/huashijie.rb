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
        else
          api_response.dig("data", "multiImages").to_a.map do |map|
            image_url = map[:orgPath]
            if map[:videoPath] != ""
              image_url = map[:videoPath]&.split(",")&.first
            end
            Source::URL.parse(image_url).try(:full_image_url) || image_url
          end
        end
      end

      def profile_url
        "https://www.huashijie.art/user/index/#{user_id}" if user_id.present?
      end

      def tags
        api_response.dig("data", "faction").to_a.map do |tag|
          [tag[:name], "https://www.huashijie.art/topic/#{tag[:id]}"]
        end
      end

      def display_name
        api_response.dig("data", "user", "nick")&.strip
      end

      def tag_name
        "huashijie_#{user_id}" if user_id.present?
      end

      def user_id
        api_response.dig("data", "user", "id") || parsed_url.user_id || parsed_referer&.user_id
      end

      def artist_commentary_desc
        api_response.dig("data", "content")
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def api_url
        "https://app.huashijie.art/api/work/detail?channel=wap&platform=wap&userId=#{credentials[:user_id]}&token=#{credentials[:session_cookie]}&workId=#{work_id}" if work_id.present?
      end

      memoize def api_response
        return {} if work_id.blank?

        http.cache(1.minute).parsed_get(api_url) || {}
      end
    end
  end
end
