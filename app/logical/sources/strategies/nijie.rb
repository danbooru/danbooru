module Sources
  module Strategies
    class Nijie < Base
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:.+?\.)?nijie\.info/
      end

      def initialize(url, referer_url=nil)
        super(normalize_url(url), normalize_url(referer_url))
      end

      def referer_url
        if @referer_url =~ /nijie\.info\/view\.php.+id=\d+/ && @url =~ /pic\d+\.nijie.info\/nijie_picture\//
          @referer_url
        else
          @url
        end
      end

      def site_name
        "Nijie"
      end

      def unique_id
        profile_url =~ /nijie\.info\/members.php\?id=(\d+)/
        "nijie" + $1.to_s
      end

      def get
        page = agent.get(referer_url)

        if page.search("div#header-login-container").any?
          # Session cache is invalid, clear it and log in normally.
          Cache.delete("nijie-session")
          @agent = nil
          page = agent.get(referer_url)
        end

        @artist_name, @profile_url = get_profile_from_page(page)
        @image_url = get_image_url_from_page(page)
        @tags = get_tags_from_page(page)
      end

    protected

      def get_profile_from_page(page)
        links = page.search("a.name")

        if links.any?
          profile_url = "http://nijie.info/" + links[0]["href"]
          artist_name = links[0].text
        else
          profile_url = nil
          artist_name = nil
        end

        return [artist_name, profile_url].compact
      end

      def get_image_url_from_page(page)
        image = page.search("div#gallery a img")

        if image.any?
          image[0]["src"].try(:sub, %r!^//!, "http://")
        else
          nil
        end
      end

      def get_tags_from_page(page)
        # puts page.root.to_xhtml

        links = page.search("div#view-tag a").find_all do |node|
          node["href"] =~ /search\.php/
        end

        if links.any?
          links.map do |node|
            [node.inner_text, "http://nijie.info" + node.attr("href")]
          end
        else
          []
        end
      end

      def normalize_url(url)
        if url =~ %r!https?://nijie\.info/view_popup\.php.+id=(\d+)!
          return "http://nijie.info/view.php?id=#{$1}"
        else
          return url
        end
      end

      def agent
        @agent ||= begin
          mech = Mechanize.new

          session = Cache.get("nijie-session")
          if session
            cookie = Mechanize::Cookie.new("NIJIEIJIEID", session)
            cookie.domain = ".nijie.info"
            cookie.path = "/"
            mech.cookie_jar.add(cookie)
          else
            mech.get("http://nijie.info/login.php") do |page|
              page.form_with(:action => "/login_int.php") do |form|
                form['email'] = Danbooru.config.nijie_login
                form['password'] = Danbooru.config.nijie_password
              end.click_button
            end
            session = mech.cookie_jar.cookies.select{|c| c.name == "NIJIEIJIEID"}.first
            Cache.put("nijie-session", session.value, 1.month) if session
          end

          # This cookie needs to be set to allow viewing of adult works while anonymous
          cookie = Mechanize::Cookie.new("R18", "1")
          cookie.domain = ".nijie.info"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)

          mech
        end
      end
    end
  end
end
