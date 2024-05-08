# frozen_string_literal: true

# @see Source::URL::Plurk
module Source
  class Extractor
    class Plurk < Source::Extractor
      def image_urls
        # * Posts can have up to 10 images.
        # * Artists commonly post extra images by replying to their own post.
        # * Adult posts are hidden for logged out users. The main images can be found by
        #   scraping a <script> tag, but an API call is needed to get the images in the replies.
        #
        # Examples:
        # * https://www.plurk.com/p/om6zv4 (non-adult, single image)
        # * https://www.plurk.com/p/okxzae (non-adult, multiple images, with replies)
        # * https://www.plurk.com/p/omc64y (adult, multiple images, with replies)

        if parsed_url.image_url?
          [url]
        elsif page_json["porn"]
          # in case of adult posts, we get the main images and the replies separately
          images_from_script_tag + images_from_replies
        else
          images_from_page
        end
      end

      def page_url
        return nil if illust_id.blank?
        "https://plurk.com/p/#{illust_id}"
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      # For non-adult works, returns both the main images and the images posted by the artist in the replies.
      # For adult works, returns only the main images.
      def images_from_page
        page&.css(".bigplurk .content a img, .response.highlight_owner .content a img").to_a.pluck("alt").compact.select do |url|
          Source::URL.parse(url)&.host == "images.plurk.com"
        end
      end

      # Returns only the main images, not the images posted in the replies. Used for adult works.
      def images_from_script_tag
        URI.extract(page_json["content_raw"]).select do |url|
          Source::URL.parse(url)&.host == "images.plurk.com"
        end
      end

      # Returns images posted by the artist in the replies. Used for adult works.
      def images_from_replies
        artist_responses = api_replies["responses"].to_a.select { _1["user_id"].to_i == artist_id.to_i }
        urls = artist_responses.pluck("content_raw").flat_map { URI.extract(_1) }
        urls.select { Source::URL.parse(_1)&.host == "images.plurk.com" }.uniq
      end

      memoize def page_json
        script_text = page&.search("body script").to_a.map(&:text).grep(/plurk =/).first.to_s
        json = script_text.strip.delete_prefix("plurk = ").delete_suffix(";").gsub(/new Date\((.*?)\)/) { $1 }
        json.parse_json || {}
      end

      memoize def api_replies
        return {} if illust_id.blank?

        http.cache(1.minute).parsed_post("https://www.plurk.com/Responses/get", form: { plurk_id: illust_id.to_i(36), from_response_id: 0 }) || {}
      end

      def username
        page&.at(".bigplurk .user a")&.[](:href)&.gsub(%r{^/}, "")
      end

      def artist_name
        page&.at(".bigplurk .user a")&.text
      end

      def tag_name
        username.to_s.downcase.gsub(/\A_+|_+\z/, "").squeeze("_").presence
      end

      def other_names
        [artist_name, username].compact_blank.uniq(&:downcase)
      end

      def artist_id
        page&.at("a[data-uid]")&.attr("data-uid").to_i
      end

      def profile_url
        "https://www.plurk.com/#{username}" if username.present?
      end

      def tags
        Nokogiri::HTML5.fragment(page_json["content"]).css("span.hashtag").map do |element|
          tag = element.text.delete_prefix("#")
          [tag, "https://www.plurk.com/search?q=#{Danbooru::URL.escape(tag)}"]
        end
      end

      def artist_commentary_desc
        page&.search(".bigplurk .content .text_holder, .response.highlight_owner .content .text_holder")&.to_html
      end

      def dtext_artist_commentary_desc
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
        end.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
      end
    end
  end
end
