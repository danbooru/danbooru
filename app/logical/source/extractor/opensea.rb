# frozen_string_literal: true

# @see Source::URL::Opensea
module Source
  class Extractor
    class Opensea < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        else
          [asset["animationUrl"] || asset["imageStorageUrl"]].compact
        end
      end

      def username
        creator["displayName"] || parsed_url.username || parsed_referer&.username
      end

      def profile_url
        "https://opensea.io/#{username}" if username.present?
      end

      def creator_public_key_url
        "https://opensea.io/#{creator["address"]}" if creator["address"].present?
      end

      def profile_urls
        [profile_url, creator_public_key_url].compact
      end

      def artist_commentary_title
        asset["name"]
      end

      def artist_commentary_desc
        asset["description"]
      end

      def dtext_artist_commentary_desc
        DText.from_plaintext(artist_commentary_desc)
      end

      memoize def creator
        ref = asset.dig("creator", "__ref")
        records[ref] || {}
      end

      memoize def asset
        records.values.find { |record| record["__typename"] == "AssetType" } || {}
      end

      memoize def records
        api_response.dig("props", "pageProps", "initialRecords") || {}
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      memoize def api_response
        page&.at("#__NEXT_DATA__")&.text&.parse_json || {}
      end
    end
  end
end
