module Sources
  module Strategies
    class NicoSeiga < Base
      URL = %r!\Ahttps?://(?:\w+\.)?nico(?:seiga|video)\.jp!
      DIRECT1 = %r!\Ahttps?://lohas\.nicoseiga\.jp/priv/[0-9a-f]+!
      DIRECT2 = %r!\Ahttps?://lohas\.nicoseiga\.jp/o/[0-9a-f]+/\d+/\d+!
      DIRECT3 = %r!\Ahttps?://seiga\.nicovideo\.jp/images/source/\d+!
      PAGE = %r!\Ahttps?://seiga\.nicovideo\.jp/seiga/im(\d+)!i
      PROFILE = %r!\Ahttps?://seiga\.nicovideo\.jp/user/illust/(\d+)!i
      MANGA_PAGE = %r!\Ahttps?://seiga\.nicovideo\.jp/watch/mg(\d+)!i

      def domains
        ["nicoseiga.jp", "nicovideo.jp"]
      end

      def site_name
        "Nico Seiga"
      end

      def image_urls
        if url =~ DIRECT1
          return [url]
        end

        if theme_id
          return api_client.image_ids.map do |image_id|
            "https://seiga.nicovideo.jp/image/source/#{image_id}"
          end
        end

        link = page.search("a#illust_link")

        if link.any?
          image_url = "http://seiga.nicovideo.jp" + link[0]["href"]
          page = agent.get(image_url) # need to follow this redirect while logged in or it won't work

          if page.is_a?(Mechanize::Image)
            return [page.uri.to_s]
          end

          images = page.search("div.illust_view_big").select {|x| x["data-src"] =~ /\/priv\//}

          if images.any?
            return ["http://lohas.nicoseiga.jp" + images[0]["data-src"]]
          end
        end

        raise "image url not found for (#{url}, #{referer_url})"
      end

      def page_url
        [url, referer_url].each do |x|
          if x =~ %r!\Ahttps?://lohas\.nicoseiga\.jp/o/[a-f0-9]+/\d+/(\d+)!
            return "http://seiga.nicovideo.jp/seiga/im#{$1}"
          end

          if x =~ %r{\Ahttps?://lohas\.nicoseiga\.jp/priv/(\d+)\?e=\d+&h=[a-f0-9]+}i
            return "http://seiga.nicovideo.jp/seiga/im#{$1}"
          end

          if x =~ %r{\Ahttps?://lohas\.nicoseiga\.jp/priv/[a-f0-9]+/\d+/(\d+)}i
            return "http://seiga.nicovideo.jp/seiga/im#{$1}"
          end

          if x =~ %r{\Ahttps?://lohas\.nicoseiga\.jp/priv/(\d+)}i
            return "http://seiga.nicovideo.jp/seiga/im#{$1}"
          end

          if x =~ %r{\Ahttps?://lohas\.nicoseiga\.jp//?thumb/(\d+)i?}i
            return "http://seiga.nicovideo.jp/seiga/im#{$1}"
          end

          if x =~ %r{/seiga/im\d+}
            return x
          end

          if x =~ %r{/watch/mg\d+}
            return x
          end
        end

        return super
      end

      def canonical_url
        image_url
      end

      def profile_url
        if url =~ PROFILE
          return url
        end

        "http://seiga.nicovideo.jp/user/illust/#{api_client.user_id}"
      end

      def artist_name
        api_client.moniker
      end

      def artist_commentary_title
        api_client.title
      end

      def artist_commentary_desc
        api_client.desc
      end

      def normalized_for_artist_finder?
        url =~ PROFILE
      end

      def normalizable_for_artist_finder?
        url =~ PAGE || url =~ MANGA_PAGE || url =~ PROFILE || url =~ DIRECT1 || url =~ DIRECT2
      end

      def normalize_for_artist_finder
        "#{profile_url}/"
      end

      def tag_name
        "nicoseiga#{api_client.user_id}"
      end

      def tags
        string = page.at("meta[name=keywords]").try(:[], "content") || ""
        string.split(/,/).map do |name|
          [name, "https://seiga.nicovideo.jp/tag/#{CGI.escape(name)}"]
        end
      end
      memoize :tags

      def api_client
        if illust_id
          NicoSeigaApiClient.new(illust_id: illust_id)
        elsif theme_id
          NicoSeigaMangaApiClient.new(theme_id)
        end
      end
      memoize :api_client

      def illust_id
        if page_url =~ PAGE
          return $1.to_i
        end

        return nil
      end

      def theme_id
        if page_url =~ MANGA_PAGE
          return $1.to_i
        end

        return nil
      end

      def page
        doc = agent.get(page_url)

        if doc.search("a#link_btn_login").any?
          # Session cache is invalid, clear it and log in normally.
          Cache.delete("nico-seiga-session")
          doc = agent.get(page_url)
        end

        doc
      end
      memoize :page

      def agent
        NicoSeigaApiClient.agent
      end
      memoize :agent
    end
  end
end
