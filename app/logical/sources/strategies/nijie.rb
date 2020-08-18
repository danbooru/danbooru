# Image URLs:
#
# * https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg (page: https://www.nijie.info/view.php?id=64240)
# * https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png (page: https://www.nijie.info/view.php?id=218856)
# * https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png (page: http://nijie.info/view.php?id=218856)
# * https://pic01.nijie.info/nijie_picture/diff/main/218856_1_236014_20170620101330.png
# * https://pic05.nijie.info/nijie_picture/diff/main/559053_20180604023346_1.png (page: http://nijie.info/view_popup.php?id=265428#diff_2)
# * https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png (page: http://nijie.info/view_popup.php?id=287736#diff_2)
#
# * https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png (page: https://www.nijie.info/view.php?id=218856)
#
# Unhandled:
#
# * https://pic01.nijie.info/nijie_picture/20120211210359.jpg
# * https://pic01.nijie.info/nijie_picture/2012021022424020120210.jpg
# * https://pic01.nijie.info/nijie_picture/diff/main/2012061023480525712_0.jpg
# * https://pic05.nijie.info/dojin_main/dojin_sam/1_2768_20180429004232.png
# * https://pic04.nijie.info/horne_picture/diff/main/56095_20160403221810_0.jpg
# * https://pic04.nijie.info/omata/4829_20161128012012.png (page: http://nijie.info/view_popup.php?id=33224#diff_3)
#
# Preview URLs:
#
# * https://pic01.nijie.info/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png
# * https://pic03.nijie.info/__rs_l120x120/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/__rs_l170x170/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/__rs_l650x650/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/__rs_cns350x350/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/small_light(dh=150,dw=150,q=100)/nijie_picture/236014_20170620101426_0.png
#
# Page URLs:
#
# * https://nijie.info/view.php?id=167755 (deleted post)
# * https://nijie.info/view.php?id=218856
# * https://nijie.info/view_popup.php?id=218856
# * https://nijie.info/view_popup.php?id=218856#diff_1
# * https://www.nijie.info/view.php?id=218856
# * https://sp.nijie.info/view.php?id=218856
#
# Profile URLs
#
# * https://nijie.info/members.php?id=236014
# * https://nijie.info/members_illust.php?id=236014
#
# Doujin
# http://nijie.info/view.php?id=384548
# http://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg (NSFW)
# http://pic.nijie.net/01/__rs_l120x120/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg

module Sources
  module Strategies
    class Nijie < Base
      BASE_URL = %r{\Ahttps?://(?:[^.]+\.)?nijie\.info}i
      PAGE_URL = %r{#{BASE_URL}/view(?:_popup)?\.php\?id=(?<illust_id>\d+)}i
      PROFILE_URL = %r{#{BASE_URL}/members(?:_illust)?\.php\?id=(?<artist_id>\d+)\z}i

      # https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg
      # https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png
      # http://pic.nijie.net/03/nijie_picture/829001_20190620004513_0.mp4
      # https://pic05.nijie.info/nijie_picture/diff/main/559053_20180604023346_1.png
      FILENAME1 = /(?<artist_id>\d+)_(?<timestamp>\d{14})(?:_\d+)?/i

      # https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png
      FILENAME2 = /(?<illust_id>\d+)_\d+_(?<artist_id>\d+)_(?<timestamp>\d{14})/i

      # https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png
      FILENAME3 = /(?<illust_id>\d+)_(?<artist_id>\d+)_(?<timestamp>\d{14})_\d+/i

      IMAGE_BASE_URL = %r{\Ahttps?://(?:pic\d+\.nijie\.info|pic\.nijie\.net)}i
      DIR = %r{(?:\d+/)?(?:__rs_\w+/)?nijie_picture(?:/diff/main)?}
      IMAGE_URL = %r{#{IMAGE_BASE_URL}/#{DIR}/#{Regexp.union(FILENAME1, FILENAME2, FILENAME3)}\.\w+\z}i

      DOJIN_DIR = %r{(?:\d+/)?(?:__rs_\w+/)?dojin_main(?:/dojin_sam)?}i
      DOJIN_URL = %r{#{IMAGE_BASE_URL}/#{DOJIN_DIR}/.*\.\w+\z}i

      def self.enabled?
        Danbooru.config.nijie_login.present? && Danbooru.config.nijie_password.present?
      end

      def domains
        ["nijie.info", "nijie.net"]
      end

      def site_name
        "Nijie"
      end

      def image_url
        return to_full_image_url(url) if url =~ IMAGE_URL || url =~ DOJIN_URL
        image_urls.first
      end

      def image_urls
        if doujin?
          images = page&.search("#dojin_left .left img").to_a.map { |img| img["src"] }
          images += page&.search("#dojin_diff img.mozamoza").to_a.map { |img| img["data-original"] }
        else
          images = page&.search("div#gallery a > .mozamoza").to_a.map { |img| img["src"] }
        end

        # Can't use URI.join here because nijie urls may contain japanese characters
        images = images.map { |img| "https:#{img}" }
        images = [url] if url.match?(IMAGE_URL) && images.empty?
        images.map(&method(:to_full_image_url)).uniq
      end

      def preview_url
        return nil if image_url.blank?
        to_preview_url(image_url)
      end

      def preview_urls
        image_urls.map(&method(:to_preview_url))
      end

      def page_url
        return nil if illust_id.blank?
        "https://nijie.info/view.php?id=#{illust_id}"
      end

      def profile_url
        return nil if artist_id.blank?
        "https://nijie.info/members.php?id=#{artist_id}"
      end

      def artist_name
        if doujin?
          page&.at("#dojin_left .right a[href*='members.php?id=']")&.text
        else
          page&.at("a.name")&.text
        end
      end

      def artist_commentary_title
        if doujin?
          page&.search("#dojin_text p.title")&.text
        else
          page&.search("h2.illust_title")&.text
        end
      end

      def artist_commentary_desc
        if doujin?
          page&.search("#dojin_text p:not(.title)")&.to_html
        else
          page&.search('#illust_text > p')&.to_html
        end
      end

      def tags
        links = page&.search("div#view-tag a") || []

        search_links = links.select do |node|
          node["href"] =~ /search(?:_dojin)?\.php/
        end

        search_links.map do |node|
          [node.inner_text, "https://nijie.info" + node.attr("href")]
        end
      end

      def tag_name
        "nijie" + artist_id.to_s
      end

      def self.to_dtext(text)
        text = text.to_s.gsub(/\r\n|\r/, "<br>")

        dtext = DText.from_html(text) do |element|
          if element.name == "a" && element["href"]&.start_with?("/jump.php")
            element["href"] = element.text
          end
        end

        dtext.strip
      end

      def to_full_image_url(x)
        x.gsub(%r{__rs_\w+/}i, "").gsub(/\Ahttp:/, "https:")
      end

      def to_preview_url(url)
        url.gsub(/nijie_picture/, "__rs_l170x170/nijie_picture").gsub(/\Ahttp:/, "https:")
      end

      def illust_id
        urls.map { |url| url[PAGE_URL, :illust_id] || url[IMAGE_URL, :illust_id] }.compact.first
      end

      def artist_id_from_url
        urls.map { |url| url[IMAGE_URL, :artist_id] || url[PROFILE_URL, :artist_id] }.compact.first
      end

      def artist_id_from_page
        page&.search("a.name")&.first&.attr("href")&.match(/members\.php\?id=(\d+)/) { $1.to_i }
      end

      def artist_id
        artist_id_from_url || artist_id_from_page
      end

      def normalize_for_source
        return if illust_id.blank?

        "https://nijie.info/view.php?id=#{illust_id}"
      end

      def doujin?
        page&.at("#dojin_left").present?
      end

      def page
        return nil if page_url.blank? || client.blank?

        response = client.cache(1.minute).get(page_url)
        return nil unless response.status == 200

        response&.parse
      end
      memoize :page

      def client
        nijie = http.timeout(60).use(retriable: { max_retries: 20 })

        cookie = Cache.get("nijie-session-cookie", 1.week) do
          login_page = nijie.get("https://nijie.info/login.php").parse
          form = {
            email: Danbooru.config.nijie_login,
            password: Danbooru.config.nijie_password,
            url: login_page.at("input[name='url']")["value"],
            save: "on",
            ticket: ""
          }
          response = nijie.post("https://nijie.info/login_int.php", form: form)
          DanbooruLogger.info "Nijie login failed (#{url}, #{response.status})" if response.status != 200
          return nil unless response.status == 200

          response.cookies.select { |c| c.name == "NIJIEIJIEID" }.compact.first
        end

        nijie.cookies(NIJIEIJIEID: cookie, R18: 1)
      end
      memoize :client
    end
  end
end
