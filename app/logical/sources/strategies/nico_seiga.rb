# Direct URL
# * https://lohas.nicoseiga.jp/o/971eb8af9bbcde5c2e51d5ef3a2f62d6d9ff5552/1589933964/3583893
# * http://lohas.nicoseiga.jp/priv/3521156?e=1382558156&h=f2e089256abd1d453a455ec8f317a6c703e2cedf
# * http://lohas.nicoseiga.jp/priv/b80f86c0d8591b217e7513a9e175e94e00f3c7a1/1384936074/3583893
# * https://dcdn.cdn.nimg.jp/priv/62a56a7f67d3d3746ae5712db9cac7d465f4a339/1592186183/10466669
# * https://dcdn.cdn.nimg.jp/nicoseiga/lohas/o/8ba0a9b2ea34e1ef3b5cc50785bd10cd63ec7e4a/1592187477/10466669
#
# * http://lohas.nicoseiga.jp/material/5746c5/4459092
#
# (Manga direct url)
# * https://lohas.nicoseiga.jp/priv/f5b8966fd53bf7e06cccff9fbb2c4eef62877538/1590752727/8947170
#
# Samples
# * http://lohas.nicoseiga.jp/thumb/2163478i?
# * https://lohas.nicoseiga.jp/thumb/8947170p
#
## The direct urls and samples above can belong to both illust and manga.
## There's two ways to tell them apart:
## * visit the /source/ equivalent: illusts redirect to the /o/ intermediary page, manga redirect to /priv/ directly
## * try an api call: illusts will succeed, manga will fail
#
# Source Link
# * http://seiga.nicovideo.jp/image/source?id=3312222
#
# Illust Page URL
# * https://seiga.nicovideo.jp/seiga/im3521156
# * https://seiga.nicovideo.jp/seiga/im520647 (anonymous artist)
#
# Manga Page URL
# * http://seiga.nicovideo.jp/watch/mg316708
#
# Video Page URL (not supported)
# * https://www.nicovideo.jp/watch/sm36465441
#
# Oekaki
# * https://dic.nicovideo.jp/oekaki/52833.png

module Sources
  module Strategies
    class NicoSeiga < Base
      DIRECT       = %r{\Ahttps?://lohas\.nicoseiga\.jp/(?:priv|o)/(?:\w+/\d+/)?(?<image_id>\d+)(?:\?.+)?}i
      CDN_DIRECT   = %r{\Ahttps?://dcdn\.cdn\.nimg\.jp/.+/\w+/\d+/(?<image_id>\d+)}i
      SOURCE       = %r{\Ahttps?://seiga\.nicovideo\.jp/image/source(?:/|\?id=)(?<image_id>\d+)}i

      ILLUST_THUMB = %r{\Ahttps?://lohas\.nicoseiga\.jp/thumb/(?<illust_id>\d+)i}i
      MANGA_THUMB  = %r{\Ahttps?://lohas\.nicoseiga\.jp/thumb/(?<image_id>\d+)p}i

      ILLUST_PAGE  = %r{\Ahttps?://(?:sp\.)?seiga\.nicovideo\.jp/seiga/im(?<illust_id>\d+)}i
      MANGA_PAGE   = %r{\Ahttps?://(?:sp\.)?seiga\.nicovideo\.jp/watch/mg(?<manga_id>\d+)}i

      PROFILE_PAGE = %r{\Ahttps?://seiga\.nicovideo\.jp/user/illust/(?<artist_id>\d+)}i

      def self.enabled?
        Danbooru.config.nico_seiga_login.present? && Danbooru.config.nico_seiga_password.present?
      end

      def domains
        ["nicoseiga.jp", "nicovideo.jp"]
      end

      def site_name
        "Nico Seiga"
      end

      def image_urls
        urls = []
        return urls if api_client&.api_response.blank?

        if image_id.present?
          urls << "https://seiga.nicovideo.jp/image/source/#{image_id}"
        elsif illust_id.present?
          urls << "https://seiga.nicovideo.jp/image/source/#{illust_id}"
        elsif manga_id.present? && api_client.image_ids.present?
          urls += api_client.image_ids.map { |id| "https://seiga.nicovideo.jp/image/source/#{id}" }
        end
        urls
      end

      def image_url
        return url if image_urls.blank? || api_client.blank?

        img = case url
        when DIRECT || CDN_DIRECT then "https://seiga.nicovideo.jp/image/source/#{image_id_from_url(url)}"
        when SOURCE then url
        else image_urls.first
        end

        resp = api_client.login.head(img)
        if resp.uri.to_s =~ %r{https?://.+/(\w+/\d+/\d+)\z}i
          "https://lohas.nicoseiga.jp/priv/#{$1}"
        else
          img
        end
      end

      def preview_urls
        if illust_id.present?
          ["https://lohas.nicoseiga.jp/thumb/#{illust_id}i"]
        else
          image_urls
        end
      end

      def page_url
        if illust_id.present?
          "https://seiga.nicovideo.jp/seiga/im#{illust_id}"
        elsif manga_id.present?
          "https://seiga.nicovideo.jp/watch/mg#{manga_id}"
        elsif image_id.present?
          "https://seiga.nicovideo.jp/image/source/#{image_id}"
        end
      end

      def profile_url
        user_id = api_client&.user_id
        return if user_id.blank? # artists can be anonymous

        "http://seiga.nicovideo.jp/user/illust/#{api_client.user_id}"
      end

      def artist_name
        return if api_client.blank?
        api_client.user_name
      end

      def artist_commentary_title
        return if api_client.blank?
        api_client.title
      end

      def artist_commentary_desc
        return if api_client.blank?
        api_client.description
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc).gsub(/[^\w]im(\d+)/, ' seiga #\1 ')
      end

      def normalize_for_source
        # There's no way to tell apart illust from manga from the direct image url alone. What's worse,
        # nicoseiga itself doesn't know how to normalize back to manga, so if it's not an illust type then
        # it's impossible to get the original manga page back from the image url alone.
        # /source/ links on the other hand correctly redirect, hence we use them to normalize saved direct sources.
        if url =~ DIRECT
          "https://seiga.nicovideo.jp/image/source/#{image_id}"
        else
          page_url
        end
      end

      def tag_name
        return if api_client&.user_id.blank?
        "nicoseiga#{api_client.user_id}"
      end

      def tags
        return [] if api_client.blank?

        base_url = "https://seiga.nicovideo.jp/"
        base_url += "manga/" if manga_id.present?
        base_url += "tag/"

        api_client.tags.map do |name|
          [name, base_url + CGI.escape(name)]
        end
      end

      def image_id
        image_id_from_url(url)
      end

      def image_id_from_url(url)
        url[DIRECT, :image_id] || url[SOURCE, :image_id] || url[MANGA_THUMB, :image_id] || url[CDN_DIRECT, :image_id]
      end

      def illust_id
        urls.map { |u| u[ILLUST_PAGE, :illust_id] || u[ILLUST_THUMB, :illust_id] }.compact.first
      end

      def manga_id
        urls.compact.map { |u| u[MANGA_PAGE, :manga_id] }.compact.first
      end

      def api_client
        if illust_id.present?
          NicoSeigaApiClient.new(work_id: illust_id, type: "illust", http: http)
        elsif manga_id.present?
          NicoSeigaApiClient.new(work_id: manga_id, type: "manga", http: http)
        elsif image_id.present?
          # We default to illust to attempt getting the api anyway
          NicoSeigaApiClient.new(work_id: image_id, type: "illust", http: http)
        end
      end
      memoize :api_client
    end
  end
end
