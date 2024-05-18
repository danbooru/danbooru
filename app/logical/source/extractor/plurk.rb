# frozen_string_literal: true

# @see https://www.plurk.com/API/
# @see https://www.plurk.com/OAuth/test
# @see Source::URL::Plurk
module Source
  class Extractor
    class Plurk < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [url]
        else
          artist_commentary_desc.to_s.parse_html.css("a.pictureservices img").pluck("alt")
        end
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def response_id
        parsed_url.response_id || parsed_referer&.response_id
      end

      memoize def response
        page&.at("div[data-rid=#{response_id}]") if response_id.present?
      end

      memoize def page
        http.cache(1.minute).parsed_get("https://www.plurk.com/s/p/#{illust_id}") if illust_id.present?
      end

      memoize def plurk_html
        if response_id.present?
          response
        else
          page&.at(".bigplurk")
        end
      end

      def display_name
        plurk_html&.at(".nick")&.text&.strip
      end

      def username
        plurk_html&.attr("data-nick")
      end

      def profile_url
        "https://www.plurk.com/#{username}" if username.present?
      end

      def tags
        plurk_html&.css("span.hashtag").to_a.map do |element|
          tag = element.text.delete_prefix("#")
          [tag, "https://www.plurk.com/search?q=#{Danbooru::URL.escape(tag)}"]
        end
      end

      def artist_commentary_desc
        plurk_html&.at(".plurk_content")&.to_html
      end

      def dtext_artist_commentary_desc
        return "" if artist_commentary_desc.to_s.parse_html.text.blank?

        DText.from_html(artist_commentary_desc, base_url: "https://www.plurk.com") do |element|
          case element.name
          # Put image links on a line by themselves. Ex: https://www.plurk.com/p/omc64y.
          in "a" if element.css("img").present?
            element.name = "p"
            element.inner_html = %{<a href="#{element["href"]}">#{element["href"]}</a>}

          # Replace external link card previews with just the link. Ex: https://www.plurk.com/p/3fqo1xpr2g.
          in "a" if element.classes.include?("meta")
            element.content = element[:href]

          else
            nil
          end
        end
      end

      def http
        super.cookies(plurktokena: Danbooru.config.plurk_session_cookie)
      end
    end
  end
end
