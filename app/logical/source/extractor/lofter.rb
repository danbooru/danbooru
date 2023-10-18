# frozen_string_literal: true

# @see Source::URL::Lofter
module Source
  class Extractor
    class Lofter < Source::Extractor
      def match?
        Source::URL::Lofter === parsed_url
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          images = page&.search(".imgclasstag img, .ct .txtcont img")
          images.to_a.pluck("src").map { |url| Source::URL.parse(url).full_image_url }
        end
      end

      def profile_url
        return nil if artist_name.blank?
        "https://#{artist_name}.lofter.com"
      end

      def page_url
        return nil if illust_id.blank? || profile_url.blank?

        "#{profile_url}/post/#{illust_id}"
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      def tags
        return [] if artist_name.blank?
        page&.search("[href*='#{artist_name}.lofter.com/tag/']").to_a.map do |tag|
          href = tag.attr("href")
          [Source::URL.parse(href).unescaped_tag.encode!("UTF-8", :invalid => :replace, :replace => ""), href]
          # nasty surprise from some posts like https://xingfulun16203.lofter.com/post/77a68dc4_2b9f0f00c
          # if 0xA0 is present in a tag, it seems the tag search will crash, so not even lofter can handle these properly
        end
      end

      def artist_commentary_title
        title_selectors = ".ct .ttl"
        page&.search(title_selectors).to_a.compact.first&.to_html
      end

      def artist_commentary_desc
        commentary_selectors = [
          ".ct .text",
          ".ct .txtcont",
          ".content .text",
          ".posts .photo .text",
          "#post .description",
          ".m-post .cont .text",
          ".cnwrapper > p:nth-child(2)",
        ].join(", ")

        page&.search(commentary_selectors).to_a.compact.first&.to_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc)&.normalize_whitespace&.gsub(/\r\n/, "\n")&.gsub(/ *\n */, "\n")&.strip
      end

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def artist_name
        parsed_url.username || parsed_referer&.username
      end
    end
  end
end
