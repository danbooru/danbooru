module Sources
  module Strategies
    class NicoSeiga < Base
      URL = %r!\Ahttps?://(?:\w+\.)?nico(?:seiga|video)\.jp!
      DIRECT1 = %r!\Ahttps?://lohas\.nicoseiga\.jp/priv/[0-9a-f]+!
      DIRECT2 = %r!\Ahttps?://lohas\.nicoseiga\.jp/o/[0-9a-f]+/\d+/\d+!
      PAGE = %r!\Ahttps?://seiga\.nicovideo\.jp/seiga/im(\d+)!i
      PROFILE = %r!\Ahttps?://seiga\.nicovideo\.jp/user/illust/(\d+)!i

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

      def normalized_for_artist_finder?
        url =~ PROFILE
      end

      def normalizable_for_artist_finder?
        url =~ PAGE || url =~ PROFILE || url =~ DIRECT1 || url =~ DIRECT2
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

    public

      def api_client
        NicoSeigaApiClient.new(illust_id: illust_id)
      end
      memoize :api_client

      def illust_id
        if page_url =~ PAGE
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
        mech = Mechanize.new
        mech.redirect_ok = false
        mech.keep_alive = false

        session = Cache.get("nico-seiga-session")
        if session
          cookie = Mechanize::Cookie.new("user_session", session)
          cookie.domain = ".nicovideo.jp"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)
        else
          mech.get("https://account.nicovideo.jp/login") do |page|
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

        mech.redirect_ok = true
        mech
      end
      memoize :agent
    end
  end
end
