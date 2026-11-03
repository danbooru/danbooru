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
          artist_commentary_desc.to_s.parse_html.css("a.pictureservices img[alt^='https://images.plurk.com/']").pluck("alt")
        end
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def response_id
        parsed_url.response_id || parsed_referer&.response_id
      end

      memoize def page
        parsed_get("https://www.plurk.com/p/#{illust_id}") if illust_id.present?
      end

      memoize def responses
        http.cache(1.minute).parsed_post("https://www.plurk.com/Responses/get", form: { plurk_id: illust_id.to_i(36), from_response: 0, count: 100 }) if response_id.present?
      end

      memoize def response
        responses&.dig(:responses)&.find { |response| response[:id].to_s == response_id }
      end

      memoize def plurk_html
        if response.present?
          response[:content].to_s.parse_html
        else
          page&.at(".bigplurk .text_holder")
        end
      end

      memoize def user
        response.present? ? responses.dig(:users, response[:user_id].to_s) : nil
      end

      def display_name
        user ? user[:display_name] : page&.at(".bigplurk .user a.name")&.text
      end

      def username
        user ? user[:nick_name] : page&.at(".bigplurk .user a.name")&.attr("href")&.delete_prefix("/")
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
        plurk_html&.inner_html
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
        super.cookies(plurktokena: credentials[:session_cookie])
      end
    end
  end
end
