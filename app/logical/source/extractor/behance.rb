# frozen_string_literal: true

# @see Source::URL::Behance
module Source
  class Extractor
    class Behance < Source::Extractor
      def self.enabled?
        SiteCredential.for_site("Behance").present?
      end

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
          url = mod.dig(:imageSizes, :allAvailable)&.max_by { |i| i[:width].to_i }&.dig(:url)
          url = Source::URL.parse(url).try(:full_image_url) || url
          [url].compact
        in "MediaCollectionModule"
          mod[:components].to_a.pluck(:imageSizes).pluck(:allAvailable).map do |images|
            url = images.max_by { |image| image[:width].to_i * image[:height].to_i }&.dig(:url)
            Source::URL.parse(url).try(:full_image_url) || url
          end
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
        Source::URL.parse(profile_url)&.username
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
        dtext = [DText.from_plaintext(artist_commentary_desc)]

        if project["modules"]&.any? { |mod| mod["__typename"].in?(%w[TextModule EmbedModule]) }
          dtext += project[:modules].to_a.map do |mod|
            case mod["__typename"]
            in "TextModule"
              DText.from_html(mod[:text], base_url: "https://www.behance.net") do |element|
                case element.name
                in "div" unless element.at("div").present?
                  element.name = "p"
                else
                  nil
                end
              end
            in "EmbedModule"
              DText.from_html(mod[:originalEmbed], base_url: "https://www.behance.net") do |element|
                if element.name == "iframe"
                  element.name = "p"
                  element.inner_html = %{<a href="#{element["src"]}">#{element["src"]}</a>}
                end
              end
            in "ImageModule" | "MediaCollectionModule"
              image_urls_from_module(mod).map do |url|
                %{"[image]":[#{url}]}
              end.join("\n")
            else
              ""
            end
          end
        end

        dtext.join("\n\n").strip
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
        parsed_get(url)
      end

      memoize def api_response
        page&.at("script#beconfig-store_state")&.text&.parse_json || {}
      end

      def http
        super.cookies(ilo0: true, iat0: credentials[:session_cookie])
      end
    end
  end
end
