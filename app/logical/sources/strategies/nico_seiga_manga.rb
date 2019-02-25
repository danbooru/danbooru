module Sources
  module Strategies
    class NicoSeigaManga < Base
      PAGE_URL = %r!\Ahttps?://seiga\.nicovideo\.jp/watch/mg(\d+)!i

      def domains
        ["nicoseiga.jp", "nicovideo.jp"]
      end

      def site_name
        "Nico Seiga (manga)"
      end

      def image_urls       
        api_client.image_ids.map do |image_id|
          "https://seiga.nicovideo.jp/image/source/#{image_id}"
        end
      end

      def page_url
        [url, referer_url].each do |x|
          if x =~ PAGE_URL
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

      def headers
        super.merge(
          "Referer" => "https://seiga.nicovideo.jp"
        )
      end
      
      def theme_id
        if page_url =~ PAGE_URL
          return $1
        end
      end

      def api_client
        NicoSeigaMangaApiClient.new(theme_id)
      end
    end
  end
end
