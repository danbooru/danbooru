# frozen_string_literal: true

# @see Source::URL::Minitokyo
module Source
  class Extractor
    class Minitokyo < Source::Extractor
      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        elsif parsed_url.work_id.present?
          alternate_image_urls.presence || [full_image_url].compact
        else
          []
        end
      end

      def full_image_url
        # XXX Minitokyo returns malformed HTML that Nokogiri can't parse, so we have to extract it from the raw HTML.
        image_url = page_html[%r{https?://static\d*\.minitokyo\.net/downloads/\d+/\d+/\d+\.[a-z]+}i]
        image_url&.to_s&.encode("UTF-8", invalid: :replace, undef: :replace)
      end

      def alternate_image_urls
        page&.css("#alts a[style]")&.to_a&.filter_map do |link|
          thumb_url = link[:style].to_s[/url\(([^)]+)\)/i, 1]&.strip
          Source::URL.parse(thumb_url)&.full_image_url
        end&.uniq.to_a
      end

      def display_name
        page&.at("#menu > h2 > a")&.text&.strip
      end

      def profile_url
        parsed_url.profile_url || page&.at("#menu > h2 > a")&.attr(:href)&.downcase
      end

      def tags
        page&.css("#tag-cloud a").to_a.map do |link|
          [link.text.strip, link[:href]]
        end
      end

      def published_at
        return nil if parsed_url.image_url?

        # Format is Sep 28, 2016, timezone is unknown
        date = page&.at("#menu dt:contains('Timestamp') + dd")&.text
        Time.parse(date).utc if date.present?
      end

      def artist_commentary_title
        page&.at("h1")&.text&.strip
      end

      def artist_commentary_desc
        page&.at("#description > div[style*='min-height']")&.inner_html
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: page_url) if artist_commentary_desc.present?
      end

      # @return [Nokogiri::HTML::Document] The parsed page HTML
      memoize def page
        page_html&.parse_html
      end

      # @return [String] The raw page HTML
      memoize def page_html
        http.cache(1.minute).get(page_url).to_s if page_url.present?
      end
    end
  end
end
