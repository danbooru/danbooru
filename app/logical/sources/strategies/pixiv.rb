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
        image_url =~ /\/img\/([^\/]+)/
        $1
      end

      def get
        agent.get(URI.parse(normalized_url).request_uri) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
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

      def get_image_url_from_page(page)
        element = page.search("div.works_display a img").first
        if element
          element.attr("src").sub(/_[ms]\./, ".")
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

          mech.get("http://www.pixiv.net") do |page|
            page.form_with(:action => "/login.php") do |form|
              form['pixiv_id'] = Danbooru.config.pixiv_login
              form['pass'] = Danbooru.config.pixiv_password
            end.click_button
          end

          mech
        end
      end
    end
  end
end
