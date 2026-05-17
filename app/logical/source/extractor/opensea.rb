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
          url = asset["animationUrl"] || asset["imageUrl"]
          [Source::URL.parse(url).try(:full_image_url) || url].compact
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
        asset.dig("collection", "owner") || {}
      end

      memoize def asset
        script = page&.css("script")&.grep(/itemByIdentifier/)&.first&.text.to_s
        json = script[/\.push\((\{.*\})\)\s*\z/m, 1]&.parse_json || {}

        json[:rehydrate]&.values&.first&.dig(:data, :itemByIdentifier) || {}
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end
    end
  end
end
