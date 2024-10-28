# frozen_string_literal: true

# Source extractor for Danbooru-based sites.
#
# @see Source::URL::Danbooru
module Source
  class Extractor
    # The class is called `Danbooru2` instead of `Danbooru` to avoid ambiguity with the top-level `Danbooru` class.
    class Danbooru2 < Source::Extractor
      delegate :artist_name, :profile_url, :display_name, :username, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.candidate_full_image_urls.find { |url| http_exists?(url) } || url]
        else
          [api_response[:variants]&.find { _1[:type] == "original" }&.dig(:url)].compact
        end
      end

      def page_url
        "https://danbooru.donmai.us/posts/#{post_id}" if post_id.present?
      end

      def tags
        api_response.dig(:post, :tag_string).to_s.split.map do |tag|
          [tag, "https://danbooru.donmai.us/posts?tags=#{::Danbooru::URL.escape(tag)}"]
        end
      end

      # XXX The base extractor excludes artist tags from the translated tags; we don't want that for Danbooru.
      def translated_tags
        tags.map(&:first).flat_map(&method(:translate_tag)).uniq.sort
      end

      # Don't spoof our user agent as a browser to avoid being blocked.
      def http
        super.headers("User-Agent": "#{Danbooru.config.canonical_app_name}/#{Rails.application.config.x.git_hash}")
      end

      def http_downloader
        super.headers("User-Agent": "#{Danbooru.config.canonical_app_name}/#{Rails.application.config.x.git_hash}")
      end

      def download_file!(url)
        media_file = super(url)
        media_file.frame_delays = ugoira_frame_delays if ugoira_frame_delays.present?
        media_file
      end

      def ugoira_frame_delays
        api_response.dig(:media_metadata, :metadata, :"Ugoira:FrameDelays")
      end

      memoize def api_response
        fields = %w[variants media_metadata[metadata] post[id,tag_string,source]].join(",")

        api_url = if post_md5_from_url.present?
          "https://danbooru.donmai.us/media_assets.json?search[md5]=#{post_md5_from_url}&only=#{fields}"
        elsif post_id_from_url.present?
          "https://danbooru.donmai.us/media_assets.json?search[post][id]=#{post_id_from_url}&only=#{fields}"
        end

        response = http.cache(1.minute).parsed_get(api_url) if api_url.present?
        (response || []).first.to_h.with_indifferent_access
      end

      concerning :HelperMethods do
        def post_id
          post_id_from_url || api_response.dig(:post, :id)
        end

        def post_id_from_url
          parsed_url.post_id || parsed_referer&.post_id
        end

        def post_md5_from_url
          parsed_url.md5 || parsed_referer&.md5
        end

        def sub_extractor
          return nil if parent_extractor.present?

          @sub_extractor ||= Source::Extractor.find(api_response.dig(:post, :source), default_extractor: nil, parent_extractor: self)
        end
      end
    end
  end
end
