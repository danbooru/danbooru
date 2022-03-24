# frozen_string_literal: true

# @see Source::URL::HentaiFoundry
module Source
  class Extractor
    class HentaiFoundry < Source::Extractor
      def match?
        Source::URL::HentaiFoundry === parsed_url
      end

      def image_urls
        image = page&.search("#picBox img")

        return [] unless image

        image.to_a.map { |img| URI.join(page_url, img["src"]).to_s }
      end

      def page_url
        return nil if illust_id.blank?

        if artist_name.blank?
          "https://www.hentai-foundry.com/pic-#{illust_id}"
        else
          "https://www.hentai-foundry.com/pictures/user/#{artist_name}/#{illust_id}"
        end
      end

      def page
        return nil if page_url.blank?

        response = http.cache(1.minute).get("#{page_url}?enterAgree=1")
        return nil unless response.status == 200

        response.parse
      end

      def tags
        tags = page&.search(".boxbody [rel='tag']") || []

        tags.map do |tag|
          [tag.text, URI.join(page_url, tag.attr("href")).to_s]
        end
      end

      def artist_name
        parsed_url.username || parsed_referer&.username
      end

      def profile_url
        return nil if artist_name.blank?
        "https://www.hentai-foundry.com/user/#{artist_name}"
      end

      def artist_commentary_title
        page&.search("#picBox .imageTitle")&.text
      end

      def artist_commentary_desc
        page&.search("#descriptionBox .picDescript")&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc).gsub(/\A[[:space:]]+|[[:space:]]+\z/, "").gsub(/\n+/, "\n")
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      memoize :page
    end
  end
end
