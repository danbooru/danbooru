# Image URLs
# * https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png
#
# Page URLs
#
# * https://foundation.app/@mochiiimo/~/97376
# * https://foundation.app/@huwari/~/88982 (video)
#
# Even if the username is wrong, the ID is still fetched correctly. Example:
# * https://foundation.app/@asdasdasd/~/97376
#
# Profile URLs
#
# Profile urls seem to accept any character in them, even no character at all:
# * https://foundation.app/@mochiiimo
# * https://foundation.app/@ <- This seems to be a novelty account.
#                               Probably not worth supporting it given its
#                               uniqueness and chance for headaches

module Sources
  module Strategies
    class Foundation < Base
      BASE_URL    = %r{\Ahttps?://(www\.)?foundation\.app}i
      PROFILE_URL = %r{#{BASE_URL}/@(?<artist_name>[^/]+)/?}i
      PAGE_URL    = %r{#{PROFILE_URL}/~/(?<illust_id>\d+)}i

      IMAGE_HOST  = /f8n-ipfs-production\.imgix\.net/
      IMAGE_URL   = %r{\Ahttps?://#{IMAGE_HOST}/\w+/nft.\w+}i

      def domains
        ["foundation.app"]
      end

      def match?
        return false if parsed_url.nil?
        parsed_url.domain.in?(domains) || parsed_url.host =~ IMAGE_HOST
      end

      def site_name
        "Foundation"
      end

      def image_urls
        return [url.gsub(/\?.*/, "")] if url =~ IMAGE_URL
        image = page&.at(".fullscreen img, .fullscreen video")&.[](:src)&.gsub(/\?.*/, "")

        if image =~ %r{assets\.foundation\.app/(?:\w+/)+(\w+)/nft_\w+\.(\w+)}i
          image = "https://f8n-ipfs-production.imgix.net/#{$1}/nft.#{$2}"
        end

        [image]
      end

      def preview_urls
        previews = [page&.at("meta[property='og:image']")&.[](:content)].compact

        previews.presence || image_urls
      end

      def page_url
        urls.select { |url| url[PAGE_URL]}.compact.first
      end

      def page
        return nil if page_url.blank?

        response = http.cache(1.minute).get(page_url)
        return nil unless response.status == 200

        response.parse
      end

      def tags
        tags = page&.search("a[href^='/tags/']").to_a

        tags.map do |tag|
          [tag.text, URI.join(page_url, tag.attr("href")).to_s]
        end
      end

      def artist_name
        urls.map { |u| u[PROFILE_URL, :artist_name] }.compact.first
      end

      def profile_url
        return nil if artist_name.blank?
        "https://foundation.app/@#{artist_name}"
      end

      def artist_commentary_title
        return nil if page.blank?
        page.at("meta[property='og:title']")["content"].gsub(/ \| Foundation$/, "")
      end

      def artist_commentary_desc
        header = page&.xpath("//h2[text()='Description']")&.first
        return nil if header.blank?
        header&.parent&.search("div").first&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc)
      end

      def normalize_for_source
        page_url
      end
    end
  end
end
