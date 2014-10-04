# encoding: UTF-8

module Sources
  module Strategies
    class Pixiv < Base
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:\w+\.)?pixiv\.net/
      end

      def referer_url(template)
        if template.params[:ref] =~ /pixiv\.net\/member_illust/ && template.params[:ref] =~ /mode=medium/
          template.params[:ref]
        else
          template.params[:url]
        end
      end

      def site_name
        "Pixiv"
      end

      def unique_id
        @pixiv_moniker
      end

      def get
        agent.get(URI.parse(normalized_url)) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @pixiv_moniker = get_moniker_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
          @page_count = get_page_count_from_page(page)
        end
      end

    protected

      def get_profile_from_page(page)
        profile_url = page.search("a.user-link").first
        if profile_url
          profile_url = "http://www.pixiv.net" + profile_url["href"]
        end

        artist_name = page.search("h1.user").first
        if artist_name
          artist_name = artist_name.inner_text
        end

        return [artist_name, profile_url]
      end

      def get_moniker_from_page(page)
        # <a class="tab-feed" href="/stacc/gennmai-226">Feed</a>
        stacc_link = page.search("a.tab-feed").first

        if not stacc_link.nil?
          stacc_link.attr("href").sub(%r!^/stacc/!i, '')
        else
          raise "Couldn't find Pixiv moniker in page: #{normalized_url}"
        end
      end

      def get_image_url_from_page(page)
        elements = page.search("div.works_display a img").find_all do |node|
          node["src"] !~ /source\.pixiv\.net/
        end

        if elements.any?
          elements.first.attr("src").sub(/_[ms]\./, ".")
        else
          nil
        end
      end

      def get_tags_from_page(page)
        # puts page.root.to_xhtml

        links = page.search("ul.tags a.text").find_all do |node|
          node["href"] =~ /search\.php/
        end

        original_flag = page.search("a.original-works")

        if links.any?
          links.map! do |node|
            [node.inner_text, "http://www.pixiv.net" + node.attr("href")]
          end

          if original_flag.any?
            links << ["オリジナル", "http://www.pixiv.net/search.php?s_mode=s_tag_full&word=%E3%82%AA%E3%83%AA%E3%82%B8%E3%83%8A%E3%83%AB"]
          end

          links
        else
          []
        end
      end

      def get_page_count_from_page(page)
        elements = page.search("ul.meta li").find_all do |node|
          node.text =~ /Manga|漫画|複数枚投稿/
        end

        if elements.any?
          elements[0].text =~ /(?:Manga|漫画|複数枚投稿) (\d+)P/
          $1.to_i
        else
          1
        end
      end

      def normalized_url
        @normalized_url ||= begin
          if url =~ /\/(\d+)(?:_big)?(?:_m|_p\d+)?\.(?:jpg|jpeg|png|gif)/i
            "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{$1}"
          elsif url =~ /mode=big/
            url.sub(/mode=big/, "mode=medium")
          elsif url =~ /member_illust\.php/ && url =~ /illust_id=/
            url
          else
            nil
          end
        end
      end

      def agent
        @agent ||= begin
          mech = Mechanize.new

          phpsessid = Cache.get("pixiv-phpsessid")
          if phpsessid
            cookie = Mechanize::Cookie.new("PHPSESSID", phpsessid)
            cookie.domain = ".pixiv.net"
            cookie.path = "/"
            mech.cookie_jar.add(cookie)
          else
            mech.get("http://www.pixiv.net") do |page|
              page.form_with(:action => "/login.php") do |form|
                form['pixiv_id'] = Danbooru.config.pixiv_login
                form['pass'] = Danbooru.config.pixiv_password
              end.click_button
            end
            phpsessid = mech.cookie_jar.cookies.select{|c| c.name == "PHPSESSID"}.first
            Cache.put("pixiv-phpsessid", phpsessid.value, 1.month) if phpsessid
          end

          mech
        end
      end
    end
  end
end
