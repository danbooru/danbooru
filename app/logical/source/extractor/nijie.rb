# frozen_string_literal: true

# @see Source::URL::Nijie
module Source
  class Extractor
    class Nijie < Source::Extractor
      def self.enabled?
        SiteCredential.for_site("Nijie").present?
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url]
        else
          image_urls_from_popup
        end
      end

      def image_urls_from_popup
        popup&.search("#img_window .box-shadow999").to_a.pluck("src").map do |img|
          Source::URL.parse("https:#{img}").full_image_url
        end
      end

      def page_url
        return nil if illust_id.blank?
        "https://nijie.info/view.php?id=#{illust_id}"
      end

      def profile_url
        return nil if artist_id.blank?
        "https://nijie.info/members.php?id=#{artist_id}"
      end

      def popup_url
        return nil if illust_id.blank?
        "https://nijie.info/view_popup.php?id=#{illust_id}"
      end

      def artist_anchor
        if doujin?
          page&.at("#dojin_left .right a[href*='members.php?id=']")
        else
          page&.at("a.name")
        end
      end

      def display_name
        artist_anchor&.text
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
          page&.css("#dojin_text p:not(.title)")&.to_html
        else
          page&.css("#illust_text > p")&.to_html
        end
      end

      def tags
        links = page&.search("div#view-tag a") || []

        search_links = links.select do |node|
          node["href"] =~ /search(?:_dojin)?\.php/
        end

        search_links.map do |node|
          [node.inner_text, "https://nijie.info#{node.attr("href")}"]
        end
      end

      def tag_name
        "nijie_#{artist_id}" if artist_id.present?
      end

      def self.to_dtext(text)
        text = text.to_s.gsub(/\r\n|\r/, "<br>")

        dtext = DText.from_html(text, base_url: "https://nijie.info") do |element|
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
        artist_anchor&.attr("href")&.match(/members\.php\?id=(\d+)/) { $1.to_i }
      end

      def artist_id
        artist_id_from_url || artist_id_from_page
      end

      def doujin?
        page&.at("#dojin_left").present?
      end

      memoize def page
        request page_url
      end

      memoize def popup
        request popup_url
      end

      def request(url)
        return nil if url.blank?

        response = http.cache(1.minute).get(url)
        return nil if response.status != 200

        # When logged out, view.php shows a login prompt (#login_illust) instead of the artist, commentary, and tags.
        if response.parse&.at("#login_illust").present?
          site_credential&.error!(:expired)
          nil
        else
          update_credentials!(response)
          save_nijie_tok!(response)
          response.parse
        end
      end

      def http
        cookies = { R18: 1, NIJIEIJIEID: credentials[:session_id], nijie_tok: nijie_tok }.compact
        super.timeout(60).use(retriable: { max_retries: 20 }).cookies(**cookies)
      end

      # Nijie sends a new nijie_tok cookie with each response, which expires 60 days later. Cache the newest one so the
      # login stays alive past the expiry of the nijie_tok cookie in the site credential.
      def nijie_tok
        (Cache.get(nijie_tok_cache_key) if nijie_tok_cache_key.present?) || credentials[:nijie_tok]
      end

      def save_nijie_tok!(response)
        cookie = response.cookies.find { |c| c.name == "nijie_tok" }
        return if cookie&.value.blank? || cookie.expires.nil? || cookie.expires <= Time.zone.now || nijie_tok_cache_key.nil?

        Cache.put(nijie_tok_cache_key, cookie.value, cookie.expires - Time.zone.now)
      end

      def nijie_tok_cache_key
        "nijie-tok:#{Cache.hash(credentials[:session_id])}" if credentials[:session_id].present?
      end
    end
  end
end
