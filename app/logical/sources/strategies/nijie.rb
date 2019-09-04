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

module Sources
  module Strategies
    class Nijie < Base
      BASE_URL = %r!\Ahttps?://(?:[^.]+\.)?nijie\.info!i
      PAGE_URL = %r!#{BASE_URL}/view(?:_popup)?\.php\?id=(?<illust_id>\d+)!i
      PROFILE_URL = %r!#{BASE_URL}/members(?:_illust)?\.php\?id=(?<artist_id>\d+)\z!i

      # https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg
      # https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png
      # http://pic.nijie.net/03/nijie_picture/829001_20190620004513_0.mp4
      # https://pic05.nijie.info/nijie_picture/diff/main/559053_20180604023346_1.png
      FILENAME1 = %r!(?<artist_id>\d+)_(?<timestamp>\d{14})(?:_\d+)?!i

      # https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png
      FILENAME2 = %r!(?<illust_id>\d+)_\d+_(?<artist_id>\d+)_(?<timestamp>\d{14})!i

      # https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png
      FILENAME3 = %r!(?<illust_id>\d+)_(?<artist_id>\d+)_(?<timestamp>\d{14})_\d+!i

      IMAGE_BASE_URL = %r!\Ahttps?://(?:pic\d+\.nijie\.info|pic\.nijie\.net)!i
      DIR = %r!(?:\d+/)?(?:__rs_\w+/)?nijie_picture(?:/diff/main)?!
      IMAGE_URL = %r!#{IMAGE_BASE_URL}/#{DIR}/#{Regexp.union(FILENAME1, FILENAME2, FILENAME3)}\.\w+\z!i

      def domains
        ["nijie.info", "nijie.net"]
      end

      def site_name
        "Nijie"
      end

      def image_url
        return to_full_image_url(url) if url.match?(IMAGE_URL)
        image_urls.first
      end

      def image_urls
        images = page&.search("div#gallery a > .mozamoza").to_a.map do |img|
          "https:#{img["src"]}"
        end

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
        page&.search("a.name")&.first&.text
      end

      def artist_commentary_title
        page&.search("h2.illust_title")&.text
      end

      def artist_commentary_desc
        page&.search('meta[property="og:description"]')&.attr("content")&.value
      end

      def tags
        links = page&.search("div#view-tag a") || []

        links.select do |node|
          node["href"] =~ /search\.php/
        end.map do |node|
          [node.inner_text, "https://nijie.info" + node.attr("href")]
        end
      end

      def tag_name
        "nijie" + artist_id.to_s
      end

    public

      def self.to_dtext(text)
        text = text.to_s.gsub(/\r\n|\r/, "<br>")
        DText.from_html(text).strip
      end

      def to_full_image_url(x)
        x.gsub(%r!__rs_\w+/!i, "").gsub(/\Ahttp:/, "https:")
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

      def page
        return nil if page_url.blank?

        doc = agent.get(page_url)

        if doc.search("div#header-login-container").any?
          # Session cache is invalid, clear it and log in normally.
          Cache.delete("nijie-session")
          doc = agent.get(page_url)
        end

        return doc
      rescue Mechanize::ResponseCodeError => e
        return nil if e.response_code.to_i == 404
        raise
      end
      memoize :page

      def agent
        mech = Mechanize.new

        session = Cache.get("nijie-session")
        if session
          cookie = Mechanize::Cookie.new("NIJIEIJIEID", session)
          cookie.domain = ".nijie.info"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)
        else
          mech.get("https://nijie.info/login.php") do |page|
            page.form_with(:action => "/login_int.php") do |form|
              form['email'] = Danbooru.config.nijie_login
              form['password'] = Danbooru.config.nijie_password
            end.click_button
          end
          session = mech.cookie_jar.cookies.select{|c| c.name == "NIJIEIJIEID"}.first
          Cache.put("nijie-session", session.value, 1.day) if session
        end

        # This cookie needs to be set to allow viewing of adult works while anonymous
        cookie = Mechanize::Cookie.new("R18", "1")
        cookie.domain = ".nijie.info"
        cookie.path = "/"
        mech.cookie_jar.add(cookie)

        mech

      rescue Mechanize::ResponseCodeError => x
        if x.response_code.to_i == 429
          sleep(5)
          retry
        else
          raise
        end
      end
      memoize :agent
    end
  end
end
