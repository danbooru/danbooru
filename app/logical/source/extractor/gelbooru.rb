# frozen_string_literal: true

# Source extractor for Gelbooru-based sites, including Gelbooru, Safebooru.org, TBIB.org, and Rule34.xxx. The commentary
# and artist information are pulled from the booru post's source, while the translated tags include both the booru tags
# and the source's tags.
#
# @see Source::URL::Gelbooru
# @see https://gelbooru.com/index.php?page=wiki&s=view&id=18780 (howto:api)
# @see https://safebooru.org/index.php?page=help&topic=dapi
# @see https://tbib.org/
# @see https://rule34.xxx/index.php?page=help&topic=dapi
module Source
  class Extractor
    class Gelbooru < Source::Extractor
      delegate :artist_name, :profile_url, :display_name, :username, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        else
          [api_response[:file_url]].compact
        end
      end

      def page_url
        "https://#{domain}/index.php?page=post&s=view&id=#{post_id}" if post_id.present?
      end

      def tags
        site_tags + source_tags
      end

      def site_tags
        return [] if api_response.blank?

        tags = api_response[:tags].split + ["rating:#{api_response[:rating]}"]
        tags.map do |tag|
          [tag, "https://#{domain}/index.php?page=post&s=list&tags=#{Danbooru::URL.escape(tag)}"]
        end
      end

      def source_tags
        sub_extractor&.tags.to_a
      end

      def other_names
        sub_extractor&.other_names.to_a
      end

      def profile_urls
        sub_extractor&.profile_urls.to_a
      end

      def domain
        parsed_url.domain
      end

      def post_id
        parsed_url.post_id || parsed_referer&.post_id || api_response[:id]
      end

      def api_url
        # https://gelbooru.com//index.php?page=dapi&s=post&q=index&tags=md5:338078144fe77c9e5f35dbb585e749ec
        # https://gelbooru.com//index.php?page=dapi&s=post&q=index&tags=id:7903922
        parsed_url.api_url || parsed_referer&.api_url
      end

      memoize def api_response
        http.cache(1.minute).parsed_get(api_url)&.dig("posts", "post") || {}
      end

      def sub_extractor
        return nil if parent_extractor.present? || !api_response[:source].to_s.match?(%r{\Ahttps?://}i)

        @sub_extractor ||= Source::Extractor.find(api_response[:source], default_extractor: nil, parent_extractor: self)
      end
    end
  end
end
