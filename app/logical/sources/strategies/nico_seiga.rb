module Sources
  module Strategies
    class NicoSeiga < Base
      extend Memoist
      
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:\w+\.)?nico(?:seiga|video)\.jp/
      end

      def referer_url
        if @referer_url =~ /seiga\.nicovideo\.jp\/seiga\/im\d+/ && @url =~ /http:\/\/lohas\.nicoseiga\.jp\/(?:priv|o)\//
          @referer_url
        else
          @url
        end
      end

      def site_name
        "Nico Seiga"
      end

      def unique_id
        profile_url =~ /\/illust\/(\d+)/
        "nicoseiga" + $1
      end

      def get
        page = load_page

        @artist_name, @profile_url = get_profile_from_api
        @image_url = get_image_url_from_page(page)
        @artist_commentary_title, @artist_commentary_desc = get_artist_commentary_from_api

        # Log out before getting the tags.
        # The reason for this is that if you're logged in and viewing a non-adult-rated work, the tags will be added with javascript after the page has loaded meaning we can't extract them easily.
        # This does not apply if you're logged out (or if you're viewing an adult-rated work).
        agent.cookie_jar.clear!
        agent.get(normalized_url) do |page|
          @tags = get_tags_from_page(page)
        end
      end

      def normalized_for_artist_finder?
        url =~ %r!https?://seiga\.nicovideo\.jp/user/illust/\d+/!i
      end

      def normalizable_for_artist_finder?
        url =~ %r!https?://seiga\.nicovideo\.jp/seiga/im\d+!i
      end

      def normalize_for_artist_finder!
        page = load_page
        @illust_id = get_illust_id_from_url
        @artist_name, @profile_url = get_profile_from_api
        @profile_url + "/"
      end

    protected

      def api_client
        NicoSeigaApiClient.new(get_illust_id_from_url)
      end

      def get_illust_id_from_url
        if normalized_url =~ %r!http://seiga.nicovideo.jp/seiga/im(\d+)!
          $1.to_i
        else
          nil
        end
      end

      def load_page
        page = agent.get(normalized_url)

        if page.search("a#link_btn_login").any?
          # Session cache is invalid, clear it and log in normally.
          Cache.delete("nico-seiga-session")
          @agent = nil
          page = agent.get(normalized_url)
        end

        page
      end

      def get_profile_from_api
        return [api_client.moniker, "http://seiga.nicovideo.jp/user/illust/#{api_client.user_id}"]
      end

      def get_image_url_from_page(page)
        link = page.search("a#illust_link")

        if link.any?
          image_url = "http://seiga.nicovideo.jp" + link[0]["href"]
          page = agent.get(image_url) # need to follow this redirect while logged in or it won't work
          if page.is_a?(Mechanize::Image)
            return page.uri.to_s
          end
          images = page.search("img").select {|x| x["src"] =~ /\/priv\//}
          if images.any?
            image_url = "http://lohas.nicoseiga.jp" + images[0]["src"]
          end
        else
          image_url = nil
        end

        return image_url
      end

      def get_tags_from_page(page)
        links = page.search("a.tag")

        links.map do |node|
          [node.text, "http://seiga.nicovideo.jp" + node.attr("href")]
        end
      end

      def get_artist_commentary_from_api
        [api_client.title, api_client.desc]
      end

      def normalized_url
        @normalized_url ||= begin
          if url =~ %r!\Ahttp://lohas\.nicoseiga\.jp/o/[a-f0-9]+/\d+/(\d+)!
            "http://seiga.nicovideo.jp/seiga/im#{$1}"
          elsif url =~ %r{\Ahttp://lohas\.nicoseiga\.jp/priv/(\d+)\?e=\d+&h=[a-f0-9]+}i
            "http://seiga.nicovideo.jp/seiga/im#{$1}"
          elsif url =~ %r{\Ahttp://lohas\.nicoseiga\.jp/priv/[a-f0-9]+/\d+/(\d+)}i
            "http://seiga.nicovideo.jp/seiga/im#{$1}"
          elsif url =~ %r{\Ahttp://lohas\.nicoseiga\.jp/priv/(\d+)}i
            "http://seiga.nicovideo.jp/seiga/im#{$1}"
          elsif url =~ %r{\Ahttp://lohas\.nicoseiga\.jp//?thumb/(\d+)}i
            "http://seiga.nicovideo.jp/seiga/im#{$1}"
          elsif url =~ %r{/seiga/im\d+}
            url
          else
            nil
          end
        end
      end

      def agent
        @agent ||= begin
          mech = Mechanize.new
          mech.keep_alive = false

          session = Cache.get("nico-seiga-session")
          if session
            cookie = Mechanize::Cookie.new("user_session", session)
            cookie.domain = ".nicovideo.jp"
            cookie.path = "/"
            mech.cookie_jar.add(cookie)
          else
            mech.get("https://secure.nicovideo.jp/secure/login_form") do |page|
              page.form_with(:id => "login_form") do |form|
                form["mail_tel"] = Danbooru.config.nico_seiga_login
                form["password"] = Danbooru.config.nico_seiga_password
              end.click_button
            end
            session = mech.cookie_jar.cookies.select{|c| c.name == "user_session"}.first
            if session
              Cache.put("nico-seiga-session", session.value, 1.month)
            else
              raise "Session not found"
            end
          end

          # This cookie needs to be set to allow viewing of adult works
          cookie = Mechanize::Cookie.new("skip_fetish_warning", "1")
          cookie.domain = "seiga.nicovideo.jp"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)

          mech
        end
      end

      memoize :api_client
    end
  end
end
