# encoding: UTF-8

require 'csv'

module Sources
  module Strategies
    class Pixiv < Base
      attr_reader :zip_url, :ugoira_frame_data, :ugoira_width, :ugoira_height
      
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

      def normalize_for_artist_finder!
        # http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_m.jpg
        if url =~ %r!/img/([^/]+)/\d+(?:_\w+)?\.(?:jpg|jpeg|png|gif)!i
          username = $1
        else
          illust_id = illust_id_from_url(url)
          get_metadata_from_spapi!(illust_id) do |metadata|
            username = metadata[24]
          end
        end

        "http://img.pixiv.net/img/#{username}"
      end

      def get
        agent.get(URI.parse(normalized_url)) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @pixiv_moniker = get_moniker_from_page(page)
          @image_url = get_image_url_from_page(page)
          @zip_url, @ugoira_frame_data, @ugoira_width, @ugoira_height = get_zip_url_from_page(page)
          @tags = get_tags_from_page(page)
          @page_count = get_page_count_from_page(page)

          is_manga   = @page_count > 1
          @image_url = get_image_url_from_page(page, is_manga)
        end
      end

      def rewrite_thumbnails(thumbnail_url, is_manga=nil)
        thumbnail_url = rewrite_new_medium_images(thumbnail_url)
        thumbnail_url = rewrite_old_small_and_medium_images(thumbnail_url, is_manga)
        return thumbnail_url
      end

      def agent
        @agent ||= PixivWebAgent.build
      end

      def file_url
        image_url || zip_url
      end
      
    protected

      # http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p1_master1200.jpg
      # => http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p1.png
      def rewrite_new_medium_images(thumbnail_url)
        if thumbnail_url =~ %r!/c/\d+x\d+/img-master/img/.*/\d+_p\d+_\w+\.jpg!i
          thumbnail_url = thumbnail_url.sub(%r!/c/\d+x\d+/img-master/!i, '/img-original/')
          # => http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p1_master1200.jpg

          page = manga_page_from_url(@url)
          thumbnail_url = thumbnail_url.sub(%r!_p(\d+)_\w+\.jpg$!i, "_p#{page}.")
          # => http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p1.

          illust_id = illust_id_from_url(@url)
          get_metadata_from_spapi!(illust_id) do |metadata|
            file_ext = metadata[2]
            thumbnail_url += file_ext
            # => http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p1.png
          end
        end

        thumbnail_url
      end

      # If the thumbnail is for a manga gallery, it needs to be rewritten like this:
      #
      # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
      # => http://i2.pixiv.net/img18/img/evazion/14901720_big_p0.png
      #
      # Otherwise, it needs to be rewritten like this:
      #
      # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
      # => http://i2.pixiv.net/img18/img/evazion/14901720.png
      #
      def rewrite_old_small_and_medium_images(thumbnail_url, is_manga)
        if thumbnail_url =~ %r!/img/[^/]+/\d+_[ms]\.(?:jpg|jpeg|png|gif)!i
          if is_manga.nil?
            illust_id = illust_id_from_url(@url)
            get_metadata_from_spapi!(illust_id) do |metadata|
              page_count = metadata[19].to_i || 1
              is_manga   = page_count > 1
            end
          end

          if is_manga
            page = manga_page_from_url(@url)
            return thumbnail_url.sub(/_[ms]\./, "_big_p#{page}.")
          else
            return thumbnail_url.sub(/_[ms]\./, ".")
          end
        end

        return thumbnail_url
      end

      def manga_page_from_url(url)
        # http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_p0.jpg
        # http://i1.pixiv.net/c/600x600/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg
        # http://i1.pixiv.net/img-original/img/2014/09/25/23/09/29/46183440_p0.jpg
        if url =~ %r!/\d+_p(\d+)(?:_\w+)?\.(?:jpg|jpeg|png|gif|zip)!i
          $1

        # http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46170939&page=0
        elsif url =~ /page=(\d+)/i
          $1

        else
          0
        end
      end

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
          raise Sources::Error.new("Couldn't find Pixiv moniker in page: #{normalized_url}")
        end
      end

      def get_image_url_from_page(page, is_manga)
        elements = page.search("div.works_display a img").find_all do |node|
          node["src"] !~ /source\.pixiv\.net/
        end

        if elements.any?
          thumbnail_url = elements.first.attr("src")
          return rewrite_thumbnails(thumbnail_url, is_manga)
        else
          raise Sources::Error.new("Couldn't find image thumbnail URL in page: #{normalized_url}")
        end
      end

      def get_zip_url_from_page(page)
        scripts = page.search("body script").find_all do |node|
          node.text =~ /_ugoira600x600\.zip/
        end

        if scripts.any?
          javascript = scripts.first.text

          json = javascript.match(/;pixiv\.context\.ugokuIllustData\s+=\s+(\{.+?\});(?:$|pixiv\.context)/)[1]
          data = JSON.parse(json)
          zip_url = data["src"].sub("_ugoira600x600.zip", "_ugoira1920x1080.zip")
          frame_data = data["frames"]

          if javascript =~ /illustSize\s*=\s*\[\s*(\d+)\s*,\s*(\d+)\s*\]/
            image_width = $1.to_i
            image_height = $2.to_i
          else
            image_width = 600
            image_height = 600
          end

          return [zip_url, frame_data, image_width, image_height]
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
        illust_id = illust_id_from_url(@url)
        "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{illust_id}"
      end

      # Refer to http://danbooru.donmai.us/wiki_pages/58938 for documentation on the Pixiv API.
      def get_metadata_from_spapi!(illust_id)
        phpsessid = agent.cookies.select do |cookie| cookie.name == "PHPSESSID" end.first.value
        spapi_url = "http://spapi.pixiv.net/iphone/illust.php?illust_id=#{illust_id}&PHPSESSID=#{phpsessid}"

        agent.get(spapi_url) do |response|
          metadata = CSV.parse(response.content.force_encoding("UTF-8")).first

          if metadata.nil?
            raise Sources::Error.new("Couldn't get Pixiv API metadata from #{spapi_url}.")
          else
            yield metadata
          end
        end
      end

      def illust_id_from_url(url)
        # http://img18.pixiv.net/img/evazion/14901720.png
        #
        # http://i2.pixiv.net/img18/img/evazion/14901720.png
        # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
        # http://i2.pixiv.net/img18/img/evazion/14901720_s.png
        # http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png
        # http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png
        #
        # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg
        # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png
        #
        # http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg
        # http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png
        #
        # http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip
        if url =~ %r!/(\d+)(?:_\w+)?\.(?:jpg|jpeg|png|gif|zip)!i
          $1

        # http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054
        # http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054
        # http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054
        # http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1
        elsif url =~ /illust_id=(\d+)/i
          $1

        # http://www.pixiv.net/i/18557054
        elsif url =~ %r!pixiv\.net/i/(\d+)!i
          $1

        else
          raise Sources::Error.new("Couldn't get illust ID from URL: #{url}")
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
