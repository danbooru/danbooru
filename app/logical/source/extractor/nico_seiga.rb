# frozen_string_literal: true

# @see Source::URL::NicoSeiga
module Source
  class Extractor
    class NicoSeiga < Source::Extractor
      def self.enabled?
        Danbooru.config.nico_seiga_user_session.present?
      end

      def image_urls
        if image_id.present?
          [image_url_for("https://seiga.nicovideo.jp/image/source/#{image_id}") || url]
        elsif illust_id.present?
          [image_url_for("https://seiga.nicovideo.jp/image/source/#{illust_id}") || url]
        elsif manga_id.present?
          manga_api_response.pluck("meta").pluck("source_url").map do |url|
            manga_image_url_for(url)
          end
        else
          [image_url_for(url) || url]
        end
      end

      def image_url_for(url)
        if http.redirect_url(url).to_s =~ %r{https?://.+/(\w+/\d+/\d+)\z}i
          "https://lohas.nicoseiga.jp/priv/#{$1}"
        else
          nil
        end
      end

      # Try to convert a https://deliver.cdn.nicomanga.jp/thumb/:id URL to the full size image. Not always possible.
      #
      # Doesn't work (redirects to a totally different image):
      #
      #   https://deliver.cdn.nicomanga.jp/thumb/10543313p?1592370039
      #   => https://seiga.nicovideo.jp/image/source/10543313
      #   => https://lohas.nicoseiga.jp/o/a6aaf607d27e9377a62a4353f73671c2138a6190/1704167420/10543313
      #   => https://lohas.nicoseiga.jp/priv/a6aaf607d27e9377a62a4353f73671c2138a6190/1704167420/10543313
      #
      # Works (redirects to the right image):
      #
      #   https://deliver.cdn.nicomanga.jp/thumb/10315315p?1586768900
      #   => https://seiga.nicovideo.jp/image/source/10315315
      #   => https://lohas.nicoseiga.jp/priv/a9969a0177a30d21aa57720b9afa6b3f0a59dd7e/1704167121/10315315
      def manga_image_url_for(manga_sample_url)
        image_id = Source::URL.parse(manga_sample_url).image_id
        return manga_sample_url if image_id.nil?

        candidate_url = "https://seiga.nicovideo.jp/image/source/#{image_id}"
        redirected_url = Source::URL.parse(http.redirect_url(candidate_url))

        if redirected_url.to_s.match?("/priv/")
          redirected_url.to_s
        else
          manga_sample_url
        end
      end

      def page_url
        parsed_referer&.page_url || parsed_url.page_url
      end

      def profile_url
        "https://seiga.nicovideo.jp/user/illust/#{artist_id}" if artist_id.present?
      end

      def display_name
        api_response["nickname"] || user_api_response["nickname"]
      end

      def artist_commentary_title
        api_response[:title]
      end

      def artist_commentary_desc
        api_response[:description]
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://seiga.nicovideo.jp") do |element|
          if element.name == "font" && element["color"] == "white"
            element.name = "block-spoiler"
          end
        end.gsub(/[^\w]im(\d+)/, ' seiga #\1 ').chomp
      end

      def tag_name
        "nicoseiga_#{artist_id}" if artist_id.present?
      end

      def tags
        tags = api_response.dig("tag_list", "tag")

        # We Array.wrap the tags because when a manga post has a single tag, the XML parser returns a hash instead of an array of hashes.
        # Example: https://seiga.nicovideo.jp/watch/mg302561
        Array.wrap(tags).pluck("name").map do |name|
          [name, "https://seiga.nicovideo.jp/#{"manga/" if manga_id}tag/#{Danbooru::URL.escape(name)}"]
        end
      end

      def image_id
        parsed_url.image_id || parsed_referer&.image_id
      end

      def illust_id
        parsed_url.illust_id || parsed_referer&.illust_id
      end

      def manga_id
        parsed_url.manga_id || parsed_referer&.manga_id
      end

      def artist_id
        # anonymous users have a user_id of 0: https://nico.ms/mg310193
        api_response["user_id"] unless api_response["user_id"].to_i == 0
      end

      def http
        if parsed_url.oekaki_id.present?
          super.with_legacy_ssl.cookies(skip_fetish_warning: "1", user_session: Danbooru.config.nico_seiga_user_session)
        else
          super.cookies(skip_fetish_warning: "1", user_session: Danbooru.config.nico_seiga_user_session)
        end
      end

      memoize def api_response
        if illust_id.present? || image_id.present?
          # curl "https://sp.seiga.nicovideo.jp/ajax/seiga/im4937663" | jq
          work_id = illust_id || image_id
          http.cache(1.minute).parsed_get("https://sp.seiga.nicovideo.jp/ajax/seiga/im#{work_id}")&.dig("target_image") || {}
        elsif manga_id.present?
          # curl "https://seiga.nicovideo.jp/api/theme/info?id=470189"
          http.cache(1.minute).parsed_get("https://seiga.nicovideo.jp/api/theme/info?id=#{manga_id}")&.dig("response", "theme") || {}
        else
          {}
        end
      end

      memoize def manga_api_response
        return {} unless manga_id.present?

        # curl "https://api.nicomanga.jp/api/v1/app/manga/episodes/470189/frames?enable_webp=false" | jq
        json = http.cache(1.minute).parsed_get("https://api.nicomanga.jp/api/v1/app/manga/episodes/#{manga_id}/frames?enable_webp=false")
        json.dig("data", "result") || {}
      end

      memoize def user_api_response
        return {} unless artist_id.present?

        # curl "https://seiga.nicovideo.jp/api/user/info?id=123720050"
        xml = http.cache(1.minute).parsed_get("https://seiga.nicovideo.jp/api/user/info?id=#{artist_id}")
        xml.dig("response", "user") || {}
      end
    end
  end
end
