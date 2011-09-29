module Sources
  module Strategies
    class Pixa < Base
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:\w+\.)?pixa\.cc/
      end

      def site_name
        "Pixa"
      end
      
      def unique_id
        profile_url =~ /\/show\/([^\/]+)/
        "pixa" + $1
      end
      
      def get
        agent.get(URI.parse(url).request_uri) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
        end
      end
      
    protected
    
      def get_profile_from_page(page)
        links = page.search("p.profile_name a")

        if links.any?
          profile_url = "http://www.pixa.cc" + links[0]["href"]
          artist_name = links[0].text
          return [artist_name, profile_url]
        else
          return []
        end
      end
    
      def get_image_url_from_page(page)
        img = page.search("img.illust_image").first
        if img
          img.attr("src")
        else
          nil
        end
      end
    
      def get_tags_from_page(page)
        links = page.search("div#tag_list a")

        if links.any?
          links.map do |node|
            [node.inner_text, "http://www.pixa.cc" + node.attr("href")]
          end
        else
          []
        end
      end
    
      def agent
        @agent ||= begin
          mech = Mechanize.new

          mech.get("http://www.pixa.cc") do |page|
            page.form_with(:action => "/session") do |form|
              form['email'] = Danbooru.config.pixa_login
              form['password'] = Danbooru.config.pixa_password
            end.click_button
          end

          mech
        end
      end
    end
  end
end
