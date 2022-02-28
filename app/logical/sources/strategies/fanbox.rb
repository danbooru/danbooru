# frozen_string_literal: true

# @see Source::URL::Fanbox
module Sources
  module Strategies
    class Fanbox < Base
      def match?
        Source::URL::Fanbox === parsed_url
      end

      def site_name
        parsed_url.site_name
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        elsif api_response.present?
          # There's two ways pics are returned via api:
          # Pics in proper array: https://yanmi0308.fanbox.cc/posts/1141325
          # Embedded pics (imageMap): https://www.fanbox.cc/@tsukiori/posts/1080657
          images = api_response.dig("body", "images").to_a + api_response.dig("body", "imageMap").to_a.map { |id| id[1] }
          # The following is needed because imageMap is sorted alphabetically rather than by image order
          sort_order = api_response.dig("body", "blocks").to_a.map { |b| b["imageId"] if b["type"] == "image" }.compact.uniq
          images = images.sort_by { |img| sort_order.index(img["id"]) } if sort_order.present?
          images.pluck("originalUrl")
        else
          []
        end
      end

      def page_url
        if artist_name.present? && illust_id.present?
          "https://#{artist_name}.fanbox.cc/posts/#{illust_id}"
        elsif parsed_url.image_url? && artist_name.present?
          # Cover images
          "https://#{artist_name}.fanbox.cc"
        end
      end

      def normalize_for_source
        if illust_id.present?
          if artist_name_from_url.present?
            "https://#{artist_name_from_url}.fanbox.cc/posts/#{illust_id}"
          elsif artist_id_from_url.present?
            "https://www.pixiv.net/fanbox/creator/#{artist_id_from_url}/post/#{illust_id}"
          end
        elsif artist_id_from_url.present?
          # Cover images
          "https://www.pixiv.net/fanbox/creator/#{artist_id_from_url}"
        end
      end

      def profile_url
        return if artist_name.blank?

        "https://#{artist_name}.fanbox.cc"
      end

      def artist_name
        artist_name_from_url || api_response["creatorId"] || artist_api_response["creatorId"]
      end

      def display_name
        api_response.dig("user", "name") || artist_api_response.dig("user", "name")
      end

      def other_names
        [artist_name, display_name].compact.uniq
      end

      def tags
        api_response["tags"].to_a.map { |tag| [tag, "https://fanbox.cc/tags/#{tag}"] }
      end

      def artist_commentary_title
        api_response["title"]
      end

      def artist_commentary_desc
        body = api_response["body"]
        return if body.blank?

        if body["text"].present?
          body["text"]
        elsif body["blocks"].present?
          # Reference: https://official.fanbox.cc/posts/182757
          # Commentary can get pretty complex, but unfortunately it's served in json format so it's a pain to parse it.
          # I've left out parsing external embeds because each supported site has its own id mapped to the domain
          commentary = body["blocks"].map do |node|
            if node["type"] == "image"
              body["imageMap"][node["imageId"]]["originalUrl"]
            else
              node["text"] || "\n"
            end
          end
          commentary.join("\n")
        end
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def artist_id_from_url
        parsed_url.user_id || parsed_referer&.user_id
      end

      def artist_name_from_url
        parsed_url.username || parsed_referer&.username
      end

      def api_response
        return {} if illust_id.blank?
        resp = client.get("https://api.fanbox.cc/post.info?postId=#{illust_id}")
        json_response = JSON.parse(resp)["body"]

        # At some point in 2020 fanbox stopped hiding R18 posts from the api
        # This check exists in case they ever start blocking them again
        return {} if json_response["restrictedFor"] == 2 && json_response["body"].blank?

        json_response
      rescue JSON::ParserError
        {}
      end

      def artist_api_response
        # Needed to fetch artist from cover pages
        return {} if artist_id_from_url.blank?
        resp = client.get("https://api.fanbox.cc/creator.get?userId=#{artist_id_from_url}")
        JSON.parse(resp)["body"]
      rescue JSON::ParserError
        {}
      end

      def client
        @client ||= http.headers(Origin: "https://fanbox.cc").cache(1.minute)
      end
    end
  end
end
