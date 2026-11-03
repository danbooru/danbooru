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
        creator["username"] || parsed_url.username || parsed_referer&.username
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
        address = collection.dig("owner", "address")
        account = urql_data(profile_page(address)).filter_map { |data| data.dig("profilesByAccount", "account") }.first if address.present?

        account || { "address" => address }.compact
      end

      memoize def collection
        slug = asset.dig("collection", "slug")
        return {} if slug.blank?

        urql_data(collection_page(slug)).filter_map { |data| data["collectionBySlug"] }.find { |collection| collection["owner"] } || {}
      end

      memoize def asset
        urql_data(page).filter_map { |data| data["itemByIdentifier"] }.first || {}
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      memoize def collection_page(slug)
        http.cache(1.minute).parsed_get("https://opensea.io/collection/#{slug}")
      end

      memoize def profile_page(address)
        http.cache(1.minute).parsed_get("https://opensea.io/#{address}")
      end

      def urql_data(document)
        scripts = document&.css("script")&.grep(/urql_transport/).to_a

        scripts.flat_map do |script|
          json = script.text[/\.push\((\{.*\})\)\s*\z/m, 1]&.parse_json
          json&.dig("rehydrate")&.values&.filter_map { |result| result["data"] }.to_a
        end
      end
    end
  end
end
