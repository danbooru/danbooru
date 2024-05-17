# frozen_string_literal: true

# @see Source::URL::Foundation
module Source
  class Extractor
    class Foundation < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif nft.dig("media", "url").present?
          url = nft.dig("media", "url")
          [Source::URL.parse(url).full_image_url].compact
        else
          []
        end
      end

      def page_url
        if nft["contractAddress"].present? && nft["tokenId"].present?
          "https://foundation.app/mint/eth/#{nft["contractAddress"]}/#{nft["tokenId"]}"
        else
          parsed_url.page_url || parsed_referer&.page_url
        end
      end

      memoize def page
        url = parsed_url.page_url || parsed_referer&.page_url
        http.cache(1.minute).parsed_get(url)
      end

      def display_name
        nft.dig("creator", "name")
      end

      def username
        parsed_url.username || parsed_referer&.username || nft.dig("creator", "username")
      end

      def profile_url
        "https://foundation.app/@#{username}" if username.present?
      end

      def profile_urls
        [profile_url, creator_public_key_url].compact
      end

      def creator_public_key_url
        "https://foundation.app/#{creator_public_key}" if creator_public_key.present?
      end

      def creator_public_key
        nft.dig("creator", "publicKey")
      end

      def artist_commentary_title
        nft["name"]
      end

      def artist_commentary_desc
        nft["description"]
      end

      def dtext_artist_commentary_desc
        DText.from_plaintext(artist_commentary_desc)
      end

      memoize def nft
        api_response.dig("props", "pageProps", "pageData", "token") || {}
      end

      memoize def api_response
        page&.at("#__NEXT_DATA__")&.text&.parse_json || {}
      end
    end
  end
end
