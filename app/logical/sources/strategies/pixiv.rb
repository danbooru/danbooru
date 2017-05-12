# encoding: UTF-8

require 'csv'

module Sources
  module Strategies
    class Pixiv < Base
      attr_reader :zip_url, :ugoira_frame_data, :ugoira_content_type

      MONIKER   = '(?:[a-zA-Z0-9_-]+)'
      TIMESTAMP = '(?:[0-9]{4}/[0-9]{2}/[0-9]{2}/[0-9]{2}/[0-9]{2}/[0-9]{2})'
      EXT = "(?:jpg|jpeg|png|gif)"

      WEB =   "^(?:https?://)?www\\.pixiv\\.net"
      I12 =   "^(?:https?://)?i[0-9]+\\.pixiv\\.net"
      IMG =   "^(?:https?://)?img[0-9]*\\.pixiv\\.net"
      PXIMG = "^(?:https?://)?i\\.pximg\\.net"
      TOUCH = "^(?:https?://)?touch\\.pixiv\\.net"

      def self.url_match?(url)
        url =~ /#{WEB}|#{IMG}|#{I12}|#{TOUCH}|#{PXIMG}/i
      end

      def referer_url
        if @referer_url =~ /pixiv\.net\/member_illust.+mode=medium/ && @url =~ /#{IMG}|#{I12}/
          @referer_url
        else
          @url
        end
      end

      def site_name
        "Pixiv"
      end

      def unique_id
        @pixiv_moniker
      end

      def fake_referer
        "http://www.pixiv.net"
      end

      def normalized_for_artist_finder?
        url =~ %r!https?://img\.pixiv\.net/img/#{MONIKER}/?$!i
      end

      def normalizable_for_artist_finder?
        has_moniker? || sample_image? || full_image? || work_page?
      end

      def normalize_for_artist_finder!
        if has_moniker?
          moniker = get_moniker_from_url
        else
          @illust_id = illust_id_from_url!
          @metadata = get_metadata_from_papi(@illust_id)
          moniker = @metadata.moniker
        end

        "http://img.pixiv.net/img/#{moniker}/"
      end

      def get
        return unless illust_id_from_url
        @illust_id = illust_id_from_url
        @metadata = get_metadata_from_papi(@illust_id)

        page = agent.get(URI.parse(normalized_url))
        
        if page.search("body.not-logged-in").any?
          # Session cache is invalid, clear it and log in normally.
          Cache.delete("pixiv-phpsessid")
          @agent = nil
          page = agent.get(URI.parse(normalized_url))
        end
        
        @artist_name = @metadata.name
        @profile_url = get_profile_from_page(page)
        @pixiv_moniker = @metadata.moniker
        @zip_url, @ugoira_frame_data, @ugoira_content_type = get_zip_url_from_page(page)
        @tags = @metadata.tags
        @page_count = @metadata.page_count
        @artist_commentary_title = @metadata.artist_commentary_title
        @artist_commentary_desc = @metadata.artist_commentary_desc

        is_manga = @page_count > 1

        if !@zip_url
          @image_url = get_image_url_from_page(page, is_manga)
        end
      end

      def rewrite_thumbnails(thumbnail_url, is_manga=nil)
        thumbnail_url = rewrite_new_medium_images(thumbnail_url)
        thumbnail_url = rewrite_medium_ugoiras(thumbnail_url)
        thumbnail_url = rewrite_old_small_and_medium_images(thumbnail_url, is_manga)
        return thumbnail_url
      end

      def agent
        @agent ||= PixivWebAgent.build
      end

      def file_url
        image_url || zip_url
      end

      def image_urls
        @metadata.pages
      end

      def illust_id_from_url
        if sample_image? || full_image? || work_page?
          illust_id_from_url!
        else
          nil
        end
      rescue Sources::Error
        nil
      end

      def illust_id_from_url!
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

      # http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p1_master1200.jpg
      # => http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p1.png
      #
      # http://i.pximg.net/img-master/img/2014/05/15/23/53/59/43521009_p1_master1200.jpg
      # => http://i.pximg.net/img-original/img/2014/05/15/23/53/59/43521009_p1.jpg
      def rewrite_new_medium_images(thumbnail_url)
        if thumbnail_url =~ %r!/c/\d+x\d+/img-master/img/#{TIMESTAMP}/\d+_p\d+_\w+\.jpg!i ||
           thumbnail_url =~ %r!/img-master/img/#{TIMESTAMP}/\d+_p\d+_\w+\.jpg!i
          page = manga_page_from_url(@url).to_i
          thumbnail_url = @metadata.pages[page]
        end

        thumbnail_url
      end

      # http://i3.pixiv.net/img-zip-ugoira/img/2014/12/03/04/58/24/47378698_ugoira600x600.zip
      # => http://i3.pixiv.net/img-zip-ugoira/img/2014/12/03/04/58/24/47378698_ugoira1920x1080.zip
      def rewrite_medium_ugoiras(thumbnail_url)
        if thumbnail_url =~ %r!/img-zip-ugoira/img/.*/\d+_ugoira600x600.zip!i
          thumbnail_url = thumbnail_url.sub("_ugoira600x600.zip", "_ugoira1920x1080.zip")
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
        if thumbnail_url =~ %r!/img/#{MONIKER}/\d+_[ms]\.#{EXT}!i
          if is_manga.nil?
            page_count = @metadata.page_count
            is_manga = page_count > 1
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
        if url =~ %r!/\d+_p(\d+)(?:_\w+)?\.#{EXT}!i
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
        end
      end

      def get_moniker_from_url
        case url
        when %r!#{IMG}/img/(#{MONIKER})!i
          $1
        when %r!#{I12}/img[0-9]+/img/(#{MONIKER})!i
          $1
        when %r!#{WEB}/stacc/(#{MONIKER})/?$!i
          $1
        else
          false
        end
      end

      def has_moniker?
        get_moniker_from_url != false
      end

      def get_image_url_from_page(page, is_manga)
        if is_manga
          elements = page.search("div.works_display a img").find_all do |node|
            node["src"] !~ /source\.pixiv\.net/
          end
        else
          elements = page.search("div.works_display div img.big")
          elements = page.search("div.works_display div img") if elements.empty?
        end

        if elements.any?
          element = elements.first
          thumbnail_url = element.attr("src") || element.attr("data-src")
          return rewrite_thumbnails(thumbnail_url, is_manga)
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
          content_type = data["mime_type"]

          return [zip_url, frame_data, content_type]
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
          node.text =~ /Manga|漫画|複数枚投稿|Multiple images/
        end

        if elements.any?
          elements[0].text =~ /(?:Manga|漫画|複数枚投稿|Multiple images):? (\d+)P/
          $1.to_i
        else
          1
        end
      end

      def normalized_url
        "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{@illust_id}"
      end

      def get_metadata_from_papi(illust_id)
        @metadata ||= PixivApiClient.new.works(illust_id)
      end

      def work_page?
        return true if url =~ %r!(?:#{WEB}|#{TOUCH})/member_illust\.php\?mode=(?:medium|big|manga|manga_big)&illust_id=\d+!i
        return true if url =~ %r!(?:#{WEB}|#{TOUCH})/i/\d+$!i
        return false
      end

      def full_image?
        # http://img18.pixiv.net/img/evazion/14901720.png?1234
        return true if url =~ %r!#{IMG}/img/#{MONIKER}/\d+(?:_big_p\d+)?\.#{EXT}!i

        # http://i2.pixiv.net/img18/img/evazion/14901720.png
        # http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png
        return true if url =~ %r!#{I12}/img\d+/img/#{MONIKER}/\d+(?:_big_p\d+)?\.#{EXT}!i

        # http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png
        return true if url =~ %r!#{I12}/img-original/img/#{TIMESTAMP}/\d+_p\d+\.#{EXT}$!i

        # http://i.pximg.net/img-original/img/2017/03/22/17/40/51/62041488_p0.jpg
        return true if url =~ %r!#{PXIMG}/img-original/img/#{TIMESTAMP}/\d+_\w+\.#{EXT}!i

        # http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip
        return true if url =~ %r!#{I12}/img-zip-ugoira/img/#{TIMESTAMP}/\d+_ugoira\d+x\d+\.zip$!i

        return false
      end

      def sample_image?
        # http://img18.pixiv.net/img/evazion/14901720_m.png
        return true if url =~ %r!#{IMG}/img/#{MONIKER}/\d+_(?:[sm]|p\d+)\.#{EXT}!i

        # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
        # http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png
        return true if url =~ %r!#{I12}/img\d+/img/#{MONIKER}/\d+_(?:[sm]|p\d+)\.#{EXT}!i

        # http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg
        # http://i2.pixiv.net/c/64x64/img-master/img/2014/10/09/12/59/50/46441917_square1200.jpg
        return true if url =~ %r!#{I12}/c/\d+x\d+/img-master/img/#{TIMESTAMP}/\d+_\w+\.#{EXT}$!i

        # http://i.pximg.net/img-master/img/2014/05/15/23/53/59/43521009_p1_master1200.jpg
        return true if url =~ %r!#{PXIMG}/img-master/img/#{TIMESTAMP}/\d+_\w+\.#{EXT}!i

        # http://i.pximg.net/c/600x600/img-master/img/2017/03/22/17/40/51/62041488_p0_master1200.jpg
        return true if url =~ %r!#{PXIMG}/c/\d+x\d+/img-master/img/#{TIMESTAMP}/\d+_\w+\.#{EXT}!i

        # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png
        # http://i2.pixiv.net/img-inf/img/2010/11/30/08/54/06/14901765_64x64.jpg
        return true if url =~ %r!#{I12}/img-inf/img/#{TIMESTAMP}/\d+_\w+\.#{EXT}!i

        return false
      end
    end
  end
end
