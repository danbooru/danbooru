# frozen_string_literal: true

# @see Source::URL::Lofter
module Sources
  module Strategies
    class Lofter < Base
      extend Memoist

      def match?
        parsed_url&.site_name == "Lofter"
      end

      def site_name
        parsed_url.site_name
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          images = page&.search(".imgclasstag img")
          images.to_a.pluck("src").map { |url| Source::URL.parse(url).full_image_url }
        end
      end

      def profile_url
        return nil if artist_name.blank?
        "https://#{artist_name}.lofter.com"
      end

      def page_url
        return nil if illust_id.blank? || profile_url.blank?

        "#{profile_url}/post/#{illust_id}"
      end

      def page
        return nil if page_url.blank?

        response = http.cache(1.minute).get(page_url)
        response.parse if response.status == 200
      end

      def tags
        tags = page&.search(".info .tag, .main .tag a, .tagarea, .m-info .tags .tag")

        tags.to_a.map do |tag|
          [tag.text.gsub(/^● /, ""), tag.attr("href")]
        end

        if tags.blank?
          tags = page&.search(".main .tags a").to_a.map do |tag|
            [tag.text.gsub(/^#/, ""), tag.attr("href")]
          end
        end

        tags
      end

      def artist_commentary_desc
        page&.search(".ct .text, .content .text, .posts .photo .text").to_a.compact.first&.to_html
      end

      def normalize_for_source
        page_url
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def artist_name
        parsed_url.username || parsed_referer&.username
      end

      memoize :page
    end
  end
end
