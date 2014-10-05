module Sources
  module Strategies
    class Nijie < Base
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:.+?\.)?nijie\.info/
      end

      def referer_url(template)
        if template.params[:ref] =~ /nijie\.info\/view\.php/ && template.params[:ref] =~ /id=\d+/
          template.params[:ref]
        else
          template.params[:url]
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
        agent.get(url) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
        end
      end

    protected

      def get_profile_from_page(page)
        links = page.search("a.name")

        if links.any?
          profile_url = "http://nijie.info" + links[0]["href"]
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
          image[0]["src"]
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
