# frozen_string_literal: true

# @see Source::URL::Behance
module Source
  class Extractor
    class Behance < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        else
          project["modules"].to_a.flat_map do |mod|
            image_urls_from_module(mod)
          end
        end
      end

      def image_urls_from_module(mod)
        case mod["__typename"]
        in "ImageModule"
          [mod.dig("imageSizes", "size_original", "url")].compact
        in "MediaCollectionModule"
          urls = mod["components"].to_a.pluck("imageSizes").pluck("size_max_1200").pluck("url")
          urls.map { |url| Source::URL.parse(url).try(:full_image_url) || url }
        else
          []
        end
      end

      def page_url
        project["url"] || parsed_url.page_url || parsed_referer&.page_url
      end

      def display_name
        project.dig("creator", "displayName")
      end

      def username
        project.dig("creator", "username")
      end

      def profile_url
        project.dig("creator", "url") || parsed_url.profile_url || parsed_referer&.profile_url
      end

      def artist_commentary_title
        project["name"]
      end

      def artist_commentary_desc
        project["description"]
      end

      def dtext_artist_commentary_desc
        DText.from_plaintext(artist_commentary_desc)
      end

      def tags
        project["tags"].to_a.map do |tag|
          [tag["title"], "https://www.behance.net/search/projects/#{Danbooru::URL.escape(tag["title"])}"]
        end
      end

      memoize def project
        api_response.dig("project", "project") || {}
      end

      memoize def page
        url = parsed_url.page_url || parsed_referer&.page_url
        http.cookies(ilo0: true, iat0: Danbooru.config.behance_session_cookie).cache(1.minute).parsed_get(url)
      end

      memoize def api_response
        page&.at("script#beconfig-store_state")&.text&.parse_json || {}
      end
    end
  end
end
