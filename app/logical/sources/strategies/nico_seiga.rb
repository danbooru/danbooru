module Sources
  module Strategies
    class NicoSeiga < Base
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:\w+\.)?nico(?:seiga|video)\.jp/
      end

      def site_name
        "Nico Seiga"
      end

      def unique_id
        profile_url =~ /\/illust\/(\d+)/
        "nicoseiga" + $1
      end

      def get
        agent.get(normalized_url) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
        end
      end

    protected

      def get_profile_from_page(page)
        links = page.search("li a").select {|x| x["href"] =~ /user\/illust/}

        if links.any?
          profile_url = "http://seiga.nicovideo.jp" + links[0]["href"]
          artist_name = links[0].text.gsub(/<\/?strong>/, "")
        else
          profile_url = nil
          artist_name = nil
        end

        return [artist_name, profile_url].compact
      end

      def get_image_url_from_page(page)
        link = page.search("a#illust_link")

        if link.any?
          "http://seiga.nicovideo.jp" + link[0]["href"]
        else
          nil
        end
      end

      def get_tags_from_page(page)
        links = page.search("a.tag")

        links.map do |node|
          [node.text, "http://seiga.nicovideo.jp" + node.attr("href")]
        end
      end

      def normalized_url
        @normalized_url ||= begin
          if url =~ %r{\Ahttp://lohas\.nicoseiga\.jp/priv/(\d+)\?e=\d+&h=[a-f0-9]+}i
            "http://seiga.nicovideo.jp/seiga/im#{$1}"
          elsif url =~ %r{\Ahttp://lohas\.nicoseiga\.jp/priv/[a-f0-9]+/\d+/(\d+)}i
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

          mech.get("https://secure.nicovideo.jp/secure/login_form") do |page|
            page.form_with do |form|
              form["mail_tel"] = Danbooru.config.nico_seiga_login
              form["password"] = Danbooru.config.nico_seiga_password
            end.click_button
          end

          # This cookie needs to be set to allow viewing of adult works
          cookie = Mechanize::Cookie.new("skip_fetish_warning", "1")
          cookie.domain = "seiga.nicovideo.jp"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)

          mech
        end
      end
    end
  end
end
