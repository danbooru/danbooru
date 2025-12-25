# frozen_string_literal: true

# https://rule34.us is running a modified fork of Gelbooru 0.1, so its structure is similar but not identical to that of
# other Gelbooru-based sites.
#
# @see Source::Extractor::Gelbooru
# @see Source::URL::Rule34DotUs
# @see https://rule34.us
module Source
  class Extractor
    class Rule34DotUs < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        else
          image_url = page&.css(".tag-list-left > a[href*='/images/']")&.attr("href")&.value
          [image_url].compact
        end
      end

      def page_url
        "https://rule34.us/index.php?r=posts/view&id=#{post_id}" if post_id.present?
      end

      def tags
        page&.css("meta[name='keywords']")&.attr("content")&.value.to_s.split(", ").compact.map do |tag|
          [tag.tr(" ", "_"), "https://rule34.us/index.php?r=posts/index&q=#{Danbooru::URL.escape(tag)}"]
        end
      end

      def post_id
        parsed_url.post_id || parsed_referer&.post_id || post_id_from_page
      end

      def post_id_from_page
        # title = "Rule34 - If it exists, there is porn of it  / sora / 6204967"
        page&.title.to_s[/([0-9]+)\z/, 1]
      end

      def api_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      memoize def page
        http.cache(1.minute).parsed_get(api_url)
      end
    end
  end
end
