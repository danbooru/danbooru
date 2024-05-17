# frozen_string_literal: true

# @see Source::URL::Fanbox
module Source
  class Extractor
    class Fanbox < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        elsif api_response.present?
          file_list
        else
          []
        end
      end

      def file_list
        # There's two ways files or images are returned via api:
        # https://yanmi0308.fanbox.cc/posts/1141325 (Array) vs https://www.fanbox.cc/@tsukiori/posts/1080657 (embedded)
        # Same goes for videos and files: https://naochi.fanbox.cc/posts/4657540 (Array) vs https://gomeifuku.fanbox.cc/posts/3975317 (embedded)

        return [] unless api_response.present?
        files = api_response.dig("body", "files").to_a
        files += api_response.dig("body", "images").to_a

        sortable_files = api_response.dig("body", "fileMap").to_a.pluck(1)
        sortable_files += api_response.dig("body", "imageMap").to_a.pluck(1)

        # The following is needed because imageMap/fileMap are sorted alphabetically rather than by image order
        sort_order = api_response.dig("body", "blocks").to_a.map { |b| b["#{b["type"]}Id"] }.compact.uniq
        sortable_files = sortable_files.sort_by { |f| sort_order.index(f["id"] || f["imageId"]) } if sort_order.present?

        (files + sortable_files).map { |file| file["originalUrl"] || file["url"] }.reject { |file| File.extname(file) == ".zip" } # XXX remove if we ever add a way to extract zip files from sources
      end

      def page_url
        if username.present? && illust_id.present?
          "https://#{username}.fanbox.cc/posts/#{illust_id}"
        elsif parsed_url.image_url? && username.present?
          # Cover images
          "https://#{username}.fanbox.cc"
        end
      end

      def profile_url
        if username.present?
          "https://#{username}.fanbox.cc"
        elsif artist_id_from_url.present?
          "https://www.pixiv.net/fanbox/creator/#{artist_id_from_url}"
        end
      end

      def display_name
        api_response.dig("user", "name") || artist_api_response.dig("body", "user", "name")
      end

      def username
        parsed_url.username || parsed_referer&.username || api_response["creatorId"] || artist_api_response.dig("body", "creatorId")
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

      def post_api_url
        "https://api.fanbox.cc/post.info?postId=#{illust_id}" if illust_id.present?
      end

      def artist_api_url
        "https://api.fanbox.cc/creator.get?userId=#{artist_id_from_url}" if artist_id_from_url.present?
      end

      memoize def api_response
        http.cache(1.minute).parsed_get(post_api_url)&.dig(:body) || {}
      end

      memoize def artist_api_response
        http.cache(1.minute).parsed_get(artist_api_url) || {}
      end

      def http
        super.headers(Origin: "https://fanbox.cc")
      end
    end
  end
end
