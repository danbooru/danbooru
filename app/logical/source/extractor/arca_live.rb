# frozen_string_literal: true

# @see https://arca.live
# @see Source::URL::ArcaLive
module Source
  class Extractor
    class ArcaLive < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          image_urls_from_commentary
        end
      end

      def image_urls_from_commentary
        urls = page&.css(".article-content img:not(.arca-emoticon), .article-content video:not(.arca-emoticon)")&.pluck(:src).to_a
        urls.filter_map do |url|
          url = "https:#{url}" if url.starts_with?("//")
          Source::URL.parse(url).try(:full_image_url)
        end
      end

      def profile_url
        # We do it like this we can handle users like https://arca.live/u/@크림/55256970 or https://arca.live/u/@Nauju/45320365
        url = page&.css(".member-info > .user-info > a")&.attr("href")
        Addressable::URI.join("https://arca.live", CGI.unescape(url)).to_s if url.present?
      end

      def artist_name
        page&.css(".member-info > .user-info > a")&.text
      end

      def artist_commentary_title
        page&.css(".title-row > .title")&.children&.last&.text&.strip
      end

      def artist_commentary_desc
        page&.css(".article-content")&.to_s
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://arca.live").squeeze("\n\n").strip
      end

      memoize def page
        # We need to spoof both the User-Agent (done by default in `Danbooru::Http.external`) and the Accept header,
        # otherwise we start getting hCaptchas if the request rate is too high.
        headers = { "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" }
        http.cache(1.minute).headers(headers).parsed_get(page_url)
      end
    end
  end
end
