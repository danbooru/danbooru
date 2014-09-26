# encoding: UTF-8

require 'csv'

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
        agent.get(spapi_url) do |page|
          rows = CSV.parse(page.content.force_encoding("UTF-8"))
          metadata = rows[0]

          illust_id       = metadata[0]
          pixiv_artist_id = metadata[1]
          file_ext        = metadata[2]

          # We want "img04", not "img4"
          image_directory = "img" + metadata[4].rjust(2, "0")

          @artist_name = metadata[5]
          @profile_url = "http://www.pixiv.net/member.php?id=#{pixiv_artist_id}"
          @pixiv_moniker = metadata[24]

          @tags = metadata[13].split(/\s+/).map do |tag|
              [tag, "http://www.pixiv.net/search.php?s_mode=s_tag_full&word=#{tag}"]
          end

          # Is this image in a gallery?
          if not metadata[19].nil?
            @page_count = metadata[19]
            @image_url  = "http://i1.pixiv.net/#{image_directory}/img/#{@pixiv_moniker}/#{illust_id}_big_p#{gallery_index_from_url}.#{file_ext}"
          else
            @page_count = 1
            @image_url  = "http://i1.pixiv.net/#{image_directory}/img/#{@pixiv_moniker}/#{illust_id}.#{file_ext}"
          end
        end
      end

      protected

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

      # Pixiv's API requires the PHPSESSID to be passed as a query parameter
      # instead of in a cookie. If PHPSESSID isn't passed then the API
      # won't return results for R-18 images.
      def spapi_url
        "http://spapi.pixiv.net/iphone/illust.php?illust_id=#{illust_id_from_url}&PHPSESSID=#{phpsessid}"
      end

      def phpsessid
        agent.cookies.select do |cookie| cookie.name == "PHPSESSID" end.first.value
      end

      def illust_id_from_url
        # http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_p0.jpg
        # http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg
        # http://i2.pixiv.net/img04/img/syounen_no_uta/mobile/46170939_480mw.jpg
        # http://i2.pixiv.net/img04/img/syounen_no_uta/mobile/46170939_480mw_p0.jpg
        # http://i2.pixiv.net/img78/img/demekyon/46187950.jpg?1411668966
        # http://img04.pixiv.net/img/syounen_no_uta/46170939_p0.jpg
        # http://img04.pixiv.net/img/syounen_no_uta/46170939_m.jpg
        # http://i2.pixiv.net/img-inf/img/2014/09/25/00/48/37/46170739_s.jpg
        # http://i1.pixiv.net/c/600x600/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg
        # http://i1.pixiv.net/c/150x150/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg
        # http://i1.pixiv.net/img-original/img/2014/09/25/23/09/29/46183440_p0.jpg
        # http://i2.pixiv.net/img-inf/img/2014/09/25/00/57/24/46170939_128x128.jpg
        if url =~ /\/(\d+)(?:_big|_480mw)?(?:_s|_m|_p\d+|_\d+x\d+)?(?:_master\d+)?\.(?:jpg|jpeg|png|gif)/i
          $1

        # http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939
        # http://www.pixiv.net/member_illust.php?mode=big&illust_id=46168376
        # http://www.pixiv.net/member_illust.php?mode=manga&illust_id=46170939
        # http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46170939&page=0
        elsif url =~ /illust_id=(\d+)/i
          $1

        else
          raise "Invalid URL"
        end
      end

      def gallery_index_from_url
        # Get the page number ("p0") from the URL for images that are part of a gallery:
        # * http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_p0.jpg
        # * http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg
        # * http://i2.pixiv.net/img04/img/syounen_no_uta/mobile/46170939_480mw_p0.jpg
        # * http://img04.pixiv.net/img/syounen_no_uta/46170939_p0.jpg
        # ...but not for images that aren't part of a gallery:
        # * http://i1.pixiv.net/c/600x600/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg
        # * http://i1.pixiv.net/img-original/img/2014/09/25/23/09/29/46183440_p0.jpg
        if url =~ %r!pixiv.net/img\d+/img/\w+/(?:mobile/)?\d+(?:_big|_480mw)?_p(\d+)\.(?:jpg|jpeg|png|gif)!i
          $1

        # http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46170939&page=0
        elsif url =~ /page=(\d+)/i
          $1

        else
          0
        end
      end
    end
  end
end
