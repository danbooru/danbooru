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
        @pixiv_username
      end

      def get
        get_metadata_from_spapi do |metadata|
          @artist_name = metadata[5]
          @profile_url = "http://www.pixiv.net/member.php?id=#{metadata[1]}"
          @image_url   = build_image_url(metadata)
          @tags        = get_tags(metadata[13])
          @page_count  = metadata[19] || 1

          @pixiv_username = metadata[24]
        end
      end

      def get_image_url
        get_metadata_from_spapi do |metadata|
          @image_url = build_image_url(metadata)
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

      # Refer to http://danbooru.donmai.us/wiki_pages/58938 for documentation on the Pixiv API.
      def get_metadata_from_spapi
        phpsessid = agent.cookies.select do |cookie| cookie.name == "PHPSESSID" end.first.value
        spapi_url = "http://spapi.pixiv.net/iphone/illust.php?illust_id=#{illust_id_from_url}&PHPSESSID=#{phpsessid}"

        agent.get(spapi_url) do |response|
          metadata = CSV.parse(response.content.force_encoding("UTF-8")).first

          if metadata.nil?
            raise "Couldn't get metadata from Pixiv API."
          else
            yield metadata
          end
        end
      end

      def build_image_url(metadata)
        file_ext = metadata[2]
        pixiv_username = metadata[24]

        # We want "img04", not "img4"
        image_directory = "img" + metadata[4].rjust(2, "0")

        manga_page_count = metadata[19]
        if manga_page_count.nil?
          image_url = "http://i1.pixiv.net/#{image_directory}/img/#{pixiv_username}/#{illust_id_from_url}.#{file_ext}"
        else
          image_url = "http://i1.pixiv.net/#{image_directory}/img/#{pixiv_username}/#{illust_id_from_url}_big_p#{gallery_index_from_url}.#{file_ext}"
        end

        # http://i1.pixiv.net/img35/img/kinokoyarou/mobile/46165361_480mw.jpg?1411573716
        metadata[9] =~ /(?:jpg|jpeg|png|gif)\?(\d+)$/i
        revision = $1

        image_url += "?#{revision}" unless revision.nil?

        image_url
      end

      def get_tags(pixiv_tag_string)
        pixiv_tags = pixiv_tag_string.split(/\s+/)

        tags = pixiv_tags.map do |tag|
            [tag, "http://www.pixiv.net/search.php?s_mode=s_tag_full&word=#{tag}"]
        end

        tags
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
        if url =~ %r!/(\d+)(?:_\w+)?\.(?:jpg|jpeg|png|gif)!i
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
        if url =~ %r!/img/[^/]+/(?:mobile/)?\d+(?:_big|_480mw)?_p(\d+)\.(?:jpg|jpeg|png|gif)!i
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
