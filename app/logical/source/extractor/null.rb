# frozen_string_literal: true

# A generic source extractor for URLs from unrecognized sites.
module Source
  class Extractor
    class Null < Source::Extractor
      extend Memoist

      def image_urls
        sub_extractor&.image_urls || [parsed_url.to_s].compact_blank
      end

      def page_url
        sub_extractor&.page_url
      end

      def profile_url
        sub_extractor&.profile_url
      end

      def profile_urls
        sub_extractor&.profile_urls || []
      end

      def artist_name
        sub_extractor&.artist_name
      end

      def tag_name
        sub_extractor&.tag_name
      end

      def other_names
        sub_extractor&.other_names || []
      end

      def tags
        sub_extractor&.tags || []
      end

      def artist_commentary_title
        sub_extractor&.artist_commentary_title
      end

      def artist_commentary_desc
        sub_extractor&.artist_commentary_desc
      end

      def dtext_artist_commentary_title
        sub_extractor&.dtext_artist_commentary_title
      end

      def dtext_artist_commentary_desc
        sub_extractor&.dtext_artist_commentary_desc
      end

      def artists
        sub_extractor&.artists || super
      end

      memoize def response
        http.cache(1.minute).get(url) if parsed_url.present? && !parsed_url.file_ext&.in?(%w[jpg jpeg png gif avif webp webm mp4])
      end

      memoize def page
        response&.parse if response&.mime_type == "text/html"
      end

      memoize def sub_extractor
        if tumblr_url.present?
          Source::URL::Tumblr.new(tumblr_url).extractor(parent_extractor: self)
        elsif twitter_site == "@AdobePortfolio"
          Source::URL::MyPortfolio.new(url).extractor(parent_extractor: self)
        elsif twitter_site == "@note_PR"
          Source::URL::Note.new(url).extractor(parent_extractor: self)
        end
      end

      memoize def twitter_site
        # <meta name="twitter:site" content="@AdobePortfolio" />
        # <meta data-n-head="ssr" data-hid="twitter:site" property="twitter:site" content="@note_PR">
        page&.at('meta[name="twitter:site"], meta[property="twitter:site"]')&.attr("content")
      end

      concerning :TumblrMethods do
        extend Memoist

        memoize def tumblr_url
          "https://www.tumblr.com/#{tumblr_name}/#{tumblr_post_id}" if tumblr_name.present? && tumblr_post_id.present?
        end

        memoize def tumblr_post_id
          # https://yra.sixc.me/post/736364675654123520/the-divorce-is-going-well-original
          parsed_url.path_segments => ["post", /\A\d+\z/ => post_id, *]
          post_id
        end

        memoize def tumblr_name
          tumblr_data.dig("Components", "TumblelogIframe", "tumblelogName")
        end

        memoize def tumblr_data
          page&.at("noscript#bootloader")&.attr("data-bootstrap")&.parse_json || {}
        end
      end
    end
  end
end
