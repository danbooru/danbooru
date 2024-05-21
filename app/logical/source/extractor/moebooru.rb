# frozen_string_literal: true

# @see Source::URL::Moebooru
module Source
  class Extractor
    class Moebooru < Source::Extractor
      delegate :artist_name, :profile_url, :display_name, :username, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true
      delegate :site_name, :domain, to: :parsed_url

      def image_urls
        return [] if post_md5.blank? || file_ext.blank?
        [Source::URL::Moebooru.full_image_url(site_name, post_md5, file_ext, post_id)]
      end

      def page_url
        return nil if post_id.blank?
        "https://#{domain}/post/show/#{post_id}"
      end

      def tags
        api_response[:tags].to_s.split.map do |tag|
          [tag, "https://#{domain}/post?tags=#{Danbooru::URL.escape(tag)}"]
        end
      end

      # XXX the base extractor excludes artist tags from the translated tags; we don't want that for moebooru.
      def translated_tags
        tags.map(&:first).flat_map(&method(:translate_tag)).uniq.sort
      end

      # Moebooru returns an empty array when doing an md5:<hash> search for a
      # deleted post. Because of this, api_response may be empty in some cases.
      memoize def api_response
        if post_id_from_url.present?
          params = { tags: "id:#{post_id_from_url}" }
        elsif post_md5_from_url.present?
          params = { tags: "md5:#{post_md5_from_url}" }
        else
          return {}
        end

        http.cache(1.minute).parsed_get("https://#{domain}/post.json", params: params)&.first&.with_indifferent_access || {}
      end

      def http_downloader
        # Yande.re redirects image URLs to the HTML page if we spoof the referer.
        super.disable_feature(:spoof_referrer)
      end

      concerning :HelperMethods do
        def sub_extractor
          return nil if parent_extractor.present?

          @sub_extractor ||= Source::Extractor.find(api_response[:source], default_extractor: nil, parent_extractor: self)
        end

        def file_ext
          if parsed_url.original_file_ext.present?
            parsed_url.original_file_ext

          # file_ext is not present in konachan's api (only on yande.re)
          elsif api_response[:file_ext].present?
            api_response[:file_ext]

          # file_url is not present in yande.re's api on deleted posts
          elsif api_response[:file_url].present?
            api_response[:file_url][/\.(jpg|jpeg|png|gif)\z/i, 1]

          # on yande.re, the file extension doesn't matter, any random string will work. This means we can't guess the true file extension.
          elsif domain == "yande.re"
            "png"

          # the api_response wasn't available because it's a deleted post.
          elsif post_md5.present?
            %w[jpg png gif].find { |ext| http_exists?("https://#{domain}/image/#{post_md5}.#{ext}") }

          else
            nil
          end
        end

        def post_id_from_url
          parsed_url.work_id || parsed_referer&.work_id
        end

        def post_md5_from_url
          parsed_url.md5 || parsed_referer&.md5
        end

        def post_id
          post_id_from_url || api_response[:id]
        end

        def post_md5
          post_md5_from_url || api_response[:md5]
        end
      end
    end
  end
end
