# frozen_string_literal: true

# A generic source extractor for URLs from unrecognized sites.
module Source
  class Extractor
    class Null < Source::Extractor
      extend Memoist

      # Don't ignore the referer URL if it comes from a different site, since we may need it to figure out which site the image URL is from.
      def allow_referer?
        true
      end

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

      def display_name
        sub_extractor&.display_name
      end

      def username
        sub_extractor&.username
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

      memoize def referer_page
        http.cache(1.minute).parsed_get(parsed_referer) if parsed_referer.present?
      end

      memoize def sub_extractor
        if parsed_url.nil? || !parsed_url.scheme.in?(%w[http https])
          nil
        elsif tumblr_url.present?
          Source::URL::Tumblr.new(tumblr_url).extractor(parent_extractor: self)
        elsif Source::URL::MyPortfolio.new(url).page_url? && twitter_site == "@AdobePortfolio"
          Source::URL::MyPortfolio.new(url).extractor(parent_extractor: self)
        elsif Source::URL::Note.new(url).page_url? && twitter_site == "@note_PR"
          Source::URL::Note.new(url).extractor(parent_extractor: self)
        elsif Source::URL::Blogger.new(url).page_url? && page&.at('meta[name="generator"]')&.attr("content") == "blogger"
          Source::URL::Blogger.new(url).extractor(parent_extractor: self)
        elsif Source::URL::Tistory.new(url).page_url? && twitter_site == "@TISTORY"
          Source::URL::Tistory.new(url).extractor(parent_extractor: self)
        elsif is_misskey?
          misskey_referer = Source::URL::Misskey.new(referer_url) unless referer_url.nil?
          Source::URL::Misskey.new(url).extractor(referer_url: misskey_referer, parent_extractor: self)
        elsif is_carrd?
          carrd_referer = Source::URL::Carrd.new(referer_url) unless referer_url.nil?
          Source::URL::Carrd.new(url).extractor(referer_url: carrd_referer, parent_extractor: self)
        end
      end

      def is_carrd?
        # https://hyphensam.com/#test-image
        if Source::URL::Carrd.new(url).page_url?
          page&.at("body.is-loading > div#wrapper > div#main > div.inner").present?
        # https://hyphensam.com/assets/images/image04.jpg?v=208ad020
        elsif Source::URL::Carrd.new(url).image_url? && referer_url.present? && Source::URL::Carrd.new(referer_url).page_url?
          referer_page&.at("body.is-loading > div#wrapper > div#main > div.inner").present?
        else
          false
        end
      end

      def is_misskey?
        # https://mk.yopo.work/notes/995ig09wop
        if Source::URL::Misskey.new(url).page_url?
          page&.at('meta[name="application-name"]')&.attr("content") == "Misskey"
        # https://mk.yopo.work/files/webpublic-dcab49b3-4ad3-4455-aea0-28aa81ecca48
        elsif Source::URL::Misskey.new(url).image_url? && referer_url.present? && Source::URL::Misskey.new(referer_url).page_url?
          referer_page&.at('meta[name="application-name"]')&.attr("content") == "Misskey"
        else
          false
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
          "https://www.tumblr.com/#{tumblr_name}/#{tumblr_post_id}" if tumblr_post_id.present? && tumblr_name.present?
        end

        memoize def tumblr_post_id
          # https://yra.sixc.me/post/736364675654123520/the-divorce-is-going-well-original
          Source::URL::Tumblr.new(url)&.work_id
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
