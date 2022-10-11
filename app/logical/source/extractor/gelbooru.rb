# frozen_string_literal: true

# Source extractor for Gelbooru. The commentary and artist information are
# pulled from the Gelbooru post's source, while the translated tags include
# both the Gelbooru tags and the source's tags.
#
# @see Source::URL::Gelbooru
# @see https://gelbooru.com/index.php?page=wiki&s=view&id=18780 (howto:api)
module Source
  class Extractor
    class Gelbooru < Source::Extractor
      delegate :artist_name, :profile_url, :profile_urls, :other_names, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

      def match?
        Source::URL::Gelbooru === parsed_url
      end

      def image_urls
        [api_response[:file_url]].compact
      end

      def page_url
        "https://gelbooru.com/index.php?page=post&s=view&id=#{post_id}" if post_id.present?
      end

      def tags
        gelbooru_tags + source_tags
      end

      def gelbooru_tags
        return [] if api_response.nil?

        tags = api_response[:tags].split + ["rating:#{api_response[:rating]}"]
        tags.map do |tag|
          [tag, "https://gelbooru.com/index.php?page=post&s=list&tags=#{CGI.escape(tag)}"]
        end
      end

      def source_tags
        sub_extractor&.tags.to_a
      end

      def post_id
        parsed_url.post_id || parsed_referer&.post_id || post_id_from_md5
      end

      def api_url
        # https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=779812&json=1
        "https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=#{post_id}&json=1" if post_id.present?
      end

      memoize def api_response
        return nil unless api_url.present?

        response = http.cache(1.minute).get(api_url)
        return nil unless response.status == 200

        response.parse["post"].first.with_indifferent_access
      end

      memoize def post_id_from_md5
        return nil unless parsed_url.page_url.present?

        response = http.cache(1.minute).head(parsed_url.page_url)
        return nil unless response.status == 200

        Source::URL.parse(response.uri).post_id
      end

      def sub_extractor
        return nil if api_response[:source].nil?
        @sub_extractor ||= Source::Extractor.find(api_response[:source], default: nil)
      end
    end
  end
end
