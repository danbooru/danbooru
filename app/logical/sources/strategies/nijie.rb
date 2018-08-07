module Sources
  module Strategies
    class Nijie < Base
      PICTURE = %r{pic\d+\.nijie.info/nijie_picture/}
      PAGE = %r{\Ahttps?://nijie\.info/view\.php.+id=\d+}
      DIFF = %r!\Ahttps?://pic\d+\.nijie\.info/__rs_l120x120/nijie_picture/diff/main/[0-9_]+\.\w+\z!i

      def self.match?(*urls)
        urls.compact.any? { |x| x.match?(/^https?:\/\/(?:.+?\.)?nijie\.info/) }
      end

      def site_name
        "Nijie"
      end

      def image_urls
        if url =~ PICTURE
          return [url]
        end

        # http://pic03.nijie.info/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png
        # => http://pic03.nijie.info/nijie_picture/diff/main/218856_3_236014_20170620101331.png
        if url =~ DIFF
          return [normalize_thumbnails(url)]
        end

        page.search("div#gallery a > img").map do |img|
          # //pic01.nijie.info/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png
          # => https://pic01.nijie.info/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png
          normalize_thumbnails("https:" + img.attr("src"))
        end.uniq
      end

      def page_url
        [url, referer_url].each do |x|
          if x =~ PAGE
            return x
          end

          if x =~ %r!https?://nijie\.info/view_popup\.php.+id=(\d+)!
            return "https://nijie.info/view.php?id=#{$1}"
          end
        end

        return super
      end

      def profile_url
        links = page.search("a.name")

        if links.any?
          return "https://nijie.info/" + links[0]["href"]
        end

        return nil
      end

      def artist_name
        links = page.search("a.name")

        if links.any?
          return links[0].text
        end

        return nil
      end

      def artist_commentary_title
        page.search("h2.illust_title").text
      end

      def artist_commentary_desc
        page.search('meta[property="og:description"]').attr("content").value
      end

      def tags
        links = page.search("div#view-tag a").find_all do |node|
          node["href"] =~ /search\.php/
        end

        if links.any?
          return links.map do |node|
            [node.inner_text, "https://nijie.info" + node.attr("href")]
          end
        end

        return []
      end

      def unique_id
        profile_url =~ /nijie\.info\/members.php\?id=(\d+)/
        "nijie" + $1.to_s
      end

    public

      def self.to_dtext(text)
        text = text.gsub(/\r\n|\r/, "<br>")
        DText.from_html(text).strip
      end

      def normalize_thumbnails(x)
        x.gsub(%r!__rs_l120x120/!i, "")
      end

      def page
        doc = agent.get(page_url)

        if doc.search("div#header-login-container").any?
          # Session cache is invalid, clear it and log in normally.
          Cache.delete("nijie-session")
          doc = agent.get(page_url)
        end

        return doc
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
