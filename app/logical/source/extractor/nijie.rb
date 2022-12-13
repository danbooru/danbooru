# frozen_string_literal: true

# @see Source::URL::Nijie
module Source
  class Extractor
    class Nijie < Source::Extractor
      def self.enabled?
        Danbooru.config.nijie_login.present? && Danbooru.config.nijie_password.present?
      end

      def match?
        Source::URL::Nijie === parsed_url
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          image_urls_from_page
        end
      end

      def image_urls_from_page
        if doujin?
          images = page&.search("#dojin_left .left img").to_a.pluck("src")
          images += page&.search("#dojin_diff img.mozamoza").to_a.pluck("data-original")
        else
          images = page&.search("div#gallery a > .mozamoza").to_a.pluck("src")
        end

        images.map { |img| Source::URL.parse("https:#{img}").full_image_url }
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
        "nijie_#{artist_id}" if artist_id.present?
      end

      def other_names
        [artist_name].compact
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

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def artist_id_from_url
        parsed_url.user_id || parsed_referer&.user_id
      end

      def artist_id_from_page
        page&.search("a.name")&.first&.attr("href")&.match(/members\.php\?id=(\d+)/) { $1.to_i }
      end

      def artist_id
        artist_id_from_url || artist_id_from_page
      end

      def doujin?
        page&.at("#dojin_left").present?
      end

      def page
        return nil if page_url.blank? || client.blank?

        response = client.cache(1.minute).get(page_url)

        if response.status != 200 || response.parse.search("#login_illust").present?
          clear_cached_session_cookie!
        else
          response.parse
        end
      end
      memoize :page

      def client
        return nil if cached_session_cookie.nil?
        http.cookies(R18: 1, **cached_session_cookie)
      end

      def http
        super.timeout(60).use(retriable: { max_retries: 20 })
      end

      # { "NIJIEIJIEID" => "5ca3f816c0c1f3e647940b08b8ab7a45", "nijie_tok" => <long-base64-string> }
      def cached_session_cookie
        Cache.get("nijie-session-cookie", 60.minutes, skip_nil: true) do
          session_cookie
        end
      end

      def clear_cached_session_cookie!
        flush_cache # clear memoized session cookie
        Cache.delete("nijie-session-cookie")
      end

      def session_cookie
        login_page = http.get("https://nijie.info/login.php").parse

        form = {
          email: Danbooru.config.nijie_login,
          password: Danbooru.config.nijie_password,
          url: login_page.at("input[name='url']")&.fetch("value"),
          save: "on",
          ticket: ""
        }

        response = http.post("https://nijie.info/login_int.php", form: form)

        if response.status == 200
          response.cookies.cookies.map { |cookie| [cookie.name, cookie.value] }.to_h
        else
          DanbooruLogger.info "Nijie login failed (#{url}, #{response.status})"
          nil
        end
      end

      memoize :client, :cached_session_cookie
    end
  end
end
