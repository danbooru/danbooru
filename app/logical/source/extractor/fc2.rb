# frozen_string_literal: true

# @see Source::URL::Fc2
module Source
  class Extractor
    class Fc2 < Source::Extractor
      def image_urls
        if parsed_url.candidate_full_image_url.present?
          [parsed_url.candidate_full_image_url.then.find { |url| http_exists?(url) } || url.to_s]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        else
          blog_page&.css(".entry_body img")&.pluck("src").to_a.map do |url|
            candidate_full_image_url = Source::URL.parse(url).try(:candidate_full_image_url)
            candidate_full_image_url.then.find { |url| http_exists?(url) } || url.to_s
          end
        end
      end

      def page_url
        if parsed_url.candidate_page_urls.present?
          parsed_url.candidate_page_urls.find { |url| http_exists?(url) }
        else
          parsed_url.page_url || parsed_referer&.page_url
        end
      end

      def artist_name
        parsed_url.username || parsed_referer&.username
      end

      def other_names
        [artist_name, blog_name].compact_blank.uniq
      end

      def profile_url
        parsed_url.profile_url || parsed_referer&.profile_url
      end

      def artist_commentary_title
        blog_page&.at(".entry_title h1 strong")&.text
      end

      def artist_commentary_desc
        blog_page&.at(".entry_body")&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: profile_url) do |element|
          case element.name
          in "img"
            element["alt"] = "[image]"

            if element.ancestors.none? { |e| e.name == "a" }
              element.content = %{<a href="#{element["src"]}">#{element.content}</a>}
            end

          in "div" if element.classes.include?("fc2_footer")
            element.content = nil

          else
            nil
          end
        end
      end

      def blog_name
        blog_page&.at("#header h1 a")&.text
      end

      def blog_entry
        parsed_url.blog_entry || parsed_referer&.blog_entry
      end

      memoize def blog_page
        return nil if blog_entry.blank?

        # curl -H "User-Agent: Android Mobile" http://afice.blog131.fc2.com/img/20170129ss.png/
        # curl http://afice.blog131.fc2.com/img/20170129ss.png/?sp
        page = http.headers("User-Agent": "Android Mobile").cache(1.minute).parsed_get(page_url)
        return nil if page&.css("script")&.none? { |script| script["src"] == "https://static.fc2.com/js/blog/sp_autopager.js" }

        page
      end
    end
  end
end
