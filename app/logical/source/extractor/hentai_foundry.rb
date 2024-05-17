# frozen_string_literal: true

# @see Source::URL::HentaiFoundry
module Source
  class Extractor
    class HentaiFoundry < Source::Extractor
      def image_urls
        image = page&.search("#picBox img")

        return [] unless image

        image.to_a.map { |img| URI.join(page_url, img["src"]).to_s }
      end

      def page_url
        if username.present? && illust_id.present?
          "https://www.hentai-foundry.com/pictures/user/#{username}/#{illust_id}"
        elsif illust_id.present?
          "https://www.hentai-foundry.com/pic-#{illust_id}"
        end
      end

      memoize def page
        return nil if page_url.blank?

        http.cache(1.minute).parsed_get("#{page_url}?enterAgree=1")
      end

      def tags
        tags = page&.search(".boxbody [rel='tag']").to_a.map(&:text)

        tags.map do |tag|
          [tag, "https://www.hentai-foundry.com/pictures/tagged/#{Danbooru::URL.escape(tag)}"]
        end
      end

      def username
        parsed_url.username || parsed_referer&.username
      end

      def profile_url
        "https://www.hentai-foundry.com/user/#{username}" if username.present?
      end

      def artist_commentary_title
        page&.search("#picBox .imageTitle")&.text
      end

      def artist_commentary_desc
        page&.search("#descriptionBox .picDescript")&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://www.hentai-foundry.com").gsub(/\A[[:space:]]+|[[:space:]]+\z/, "").gsub(/\n+/, "\n")
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end
    end
  end
end
