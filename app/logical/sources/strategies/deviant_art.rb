module Sources
  module Strategies
    class DeviantArt < Base
      DEVIANTART_SESSION_CACHE_KEY = "deviantart-session"

      def self.url_match?(url)
        url =~ /^https?:\/\/(?:.+?\.)?deviantart\.(?:com|net)/
      end

      def referer_url
        if @referer_url =~ /deviantart\.com\/art\// && @url =~ /https?:\/\/(?:fc|th|pre|orig|img)\d{2}\.deviantart\.net\//
          @referer_url
        else
          @url
        end
      end

      def site_name
        "Deviant Art"
      end

      def unique_id
        profile_url =~ /https?:\/\/(.+?)\.deviantart\.com/
        "deviantart" + $1
      end

      def get
        agent.get(URI.parse(normalized_url)) do |page|
          page.encoding = "utf-8"
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
          @artist_commentary_title = get_artist_commentary_title_from_page(page)
          @artist_commentary_desc = get_artist_commentary_desc_from_page(page)
        end
      end

      def self.to_dtext(text)
        html = Nokogiri::HTML.fragment(text)

        dtext = html.children.map do |element|
          case element.name
          when "text"
            element.content
          when "br"
            "\n"
          when "blockquote"
            "[quote]#{to_dtext(element.inner_html)}[/quote]" if element.inner_html.present?
          when "small", "sub"
            "[tn]#{to_dtext(element.inner_html)}[/tn]" if element.inner_html.present?
          when "b"
            "[b]#{to_dtext(element.inner_html)}[/b]" if element.inner_html.present?
          when "i"
            "[i]#{to_dtext(element.inner_html)}[/i]" if element.inner_html.present?
          when "u"
            "[u]#{to_dtext(element.inner_html)}[/u]" if element.inner_html.present?
          when "strike"
            "[s]#{to_dtext(element.inner_html)}[/s]" if element.inner_html.present?
          when "li"
            "* #{to_dtext(element.inner_html)}" if element.inner_html.present?
          when "h1", "h2", "h3", "h4", "h5", "h6"
            hN = element.name
            title = to_dtext(element.inner_html)
            "#{hN}. #{title}\n"
          when "a"
            title = to_dtext(element.inner_html)
            url = element.attributes["href"].value
            url = url.gsub(%r!\Ahttps?://www\.deviantart\.com/users/outgoing\?!i, "")
            %("#{title}":[#{url}]) if title.present?
          when "img"
            element.attributes["title"] || element.attributes["alt"] || ""
          when "comment"
            # ignored
          else
            to_dtext(element.inner_html)
          end
        end.join

        dtext
      end

    protected

      def get_profile_from_page(page)
        links = page.search("div.dev-title-container a.username")

        if links.any?
          profile_url = links[0]["href"]
          artist_name = links[0].text
        else
          profile_url = nil
          artist_name = nil
        end

        return [artist_name, profile_url].compact
      end

      def get_image_url_from_page(page)
        download_link = page.link_with(:class => /dev-page-download/)

        if download_link
          download_link.click.uri.to_s # need to follow the redirect now to get the full size url, following it later seems to not work.
        else
          image = page.search("div.dev-view-deviation img.dev-content-full")

          if image.any?
            image[0]["src"]
          else
            nil
          end
        end
      end

      def get_tags_from_page(page)
        links = page.search("a.discoverytag")

        links.map do |node|
          [node.attr("data-canonical-tag"), node.attr("href")]
        end
      end

      def get_artist_commentary_title_from_page(page)
        title = page.search("div.dev-title-container a").find_all do |node|
          node["data-ga_click_event"] =~ /description_title/
        end

        if title.any?
          title[0].inner_text
        end
      end

      def get_artist_commentary_desc_from_page(page)
        desc = page.search("div.dev-description div.text.block")

        if desc.any?
          desc[0].children.to_s
        end
      end

      def normalized_url
        @normalized_url ||= begin
          if url =~ %r{\Ahttps?://(?:fc|th|pre|orig|img)\d{2}\.deviantart\.net/.+/[a-z0-9_]*_by_[a-z0-9_]+-d([a-z0-9]+)\.}i
            "http://fav.me/d#{$1}"
          elsif url =~ %r{\Ahttps?://(?:fc|th|pre|orig|img)\d{2}\.deviantart\.net/.+/[a-f0-9]+-d([a-z0-9]+)\.}i
            "http://fav.me/d#{$1}"
          elsif url =~ %r{deviantart\.com/art/}
            url
          else
            nil
          end
        end
      end

      def agent
        @agent ||= begin
          mech = Mechanize.new
          auth, userinfo = session_cookies(mech)

          # This cookie needs to be set to allow viewing of mature works
          cookie = Mechanize::Cookie.new("agegate_state", "1")
          cookie.domain = ".deviantart.com"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)

          cookie = Mechanize::Cookie.new("auth", auth)
          cookie.domain = ".deviantart.com"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)

          cookie = Mechanize::Cookie.new("userinfo", userinfo)
          cookie.domain = ".deviantart.com"
          cookie.path = "/"
          mech.cookie_jar.add(cookie)

          mech
        end
      end

      def session_cookies(mech)
        Cache.get(DEVIANTART_SESSION_CACHE_KEY, 2.hours) do
          page = mech.get("https://www.deviantart.com/users/login")
          validate_key = page.search('input[name="validate_key"]').attribute("value").value
          validate_token = page.search('input[name="validate_token"]').attribute("value").value

          mech.post("https://www.deviantart.com/users/login", {
            username: Danbooru.config.deviantart_login,
            password: Danbooru.config.deviantart_password,
            validate_key: validate_key,
            validate_token: validate_token,
            remember_me: 1,
          })

          auth = mech.cookies.find { |cookie| cookie.name == "auth" }.value
          userinfo = mech.cookies.find { |cookie| cookie.name == "userinfo" }.value
          mech.cookie_jar.clear

          [auth, userinfo]
        end
      end
    end
  end
end
