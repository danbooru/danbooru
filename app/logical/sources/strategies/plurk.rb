# Image URLs
#
# * https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg
#
# Page URLs
#
# * https://www.plurk.com/p/om6zv4
#
# Profile URLs
#
# * https://www.plurk.com/redeyehare

module Sources
  module Strategies
    class Plurk < Base
      BASE_URL    = %r{\Ahttps?://(?:www\.)?plurk\.com}i
      PAGE_URL    = %r{#{BASE_URL}(?:/m)?/p/(?<illust_id>\w+)}i
      PROFILE_URL = %r{#{BASE_URL}/\w+}i
      IMAGE_URL =   %r{https?://images\.plurk\.com/\w+\.\w+}i

      def domains
        ["plurk.com"]
      end

      def site_name
        "Plurk"
      end

      def image_urls
        return [url] if url =~ IMAGE_URL
        images = page&.search(".bigplurk .content a img, .response.highlight_owner .content a img").to_a.map { |img| img["alt"] }
        # the above returns both the "main" images, and any other art the artist might have posted in the replies

        if images.empty?
          # in case of adult posts, we fall back to the internal api, which doesn't show replies
          images = images_from_internal_api
        end

        images
      end

      def page_url
        return nil if illust_id.blank?

        "https://plurk.com/p/#{illust_id}"
      end

      def illust_id
        urls.map { |u| u[PAGE_URL, :illust_id] }.compact.first
      end

      def page
        return nil if page_url.blank?

        response = http.cache(1.minute).get(page_url)
        return nil unless response.status == 200

        response.parse
      end

      def images_from_internal_api
        internal_api = page&.search("body script")&.select {|s| s.text =~ /plurk =/ }.to_a.compact.first&.text
        return [] unless internal_api.present?
        internal_api.scan(/(#{IMAGE_URL})/).flatten.compact.uniq.filter { |img| img !~ %r{/mx_\w+}i }
      end

      def tag_name
        page&.at(".bigplurk .user a")&.[](:href)&.gsub(%r{^/}, "")
      end

      def artist_name
        page&.at(".bigplurk .user a")&.text
      end

      def profile_url
        return nil if artist_name.blank?
        "https://www.plurk.com/#{tag_name}"
      end

      def artist_commentary_desc
        page&.search(".bigplurk .content .text_holder, .response.highlight_owner .content .text_holder")&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc) do |element|
          if element.name == "a"
            element.content = ""
          end
        end.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
      end

      def normalize_for_source
        page_url
      end
    end
  end
end
