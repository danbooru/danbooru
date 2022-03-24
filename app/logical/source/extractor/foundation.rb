# frozen_string_literal: true

# @see Source::URL::Foundation
module Source
  class Extractor
    class Foundation < Source::Extractor
      def match?
        Source::URL::Foundation === parsed_url
      end

      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif image_url = page&.at(".fullscreen img, .fullscreen video")&.attr(:src)
          [Source::URL.parse(image_url).full_image_url].compact
        else
          []
        end
      end

      def page_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def page
        return nil if page_url.blank?

        response = http.cache(1.minute).get(page_url)
        return nil unless response.status == 200

        response.parse
      end

      def tags
        tags = api_response.dig("props", "pageProps", "artwork", "tags").to_a

        tags.map do |tag|
          [tag, "https://foundation.app/tags/#{tag}"]
        end
      end

      def artist_name
        parsed_url.username || parsed_referer&.username || api_response.dig("props", "pageProps", "artwork", "creator", "username")
      end

      def profile_url
        return nil if artist_name.blank?
        "https://foundation.app/@#{artist_name}"
      end

      def profile_urls
        [profile_url, creator_public_key_url].compact
      end

      def creator_public_key_url
        return nil if creator_public_key.nil?
        "https://foundation.app/#{creator_public_key}"
      end

      def creator_public_key
        api_response.dig("props", "pageProps", "artwork", "creator", "publicKey")
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

      def api_response
        return {} if page.nil?

        data = page.at("#__NEXT_DATA__")&.text
        return {} if data.blank?

        JSON.parse(data).with_indifferent_access
      end

      memoize :api_response
    end
  end
end
