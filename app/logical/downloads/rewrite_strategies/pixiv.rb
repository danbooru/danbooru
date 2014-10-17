module Downloads
  module RewriteStrategies
    class Pixiv < Base
      attr_accessor :url, :source

      def initialize(url)
        @url  = url
      end

      def rewrite(url, headers, data = {})
        if url =~ /https?:\/\/(?:\w+\.)?pixiv\.net/
          url, headers = rewrite_headers(url, headers)
          url, headers = rewrite_cdn(url, headers)
          url, headers = rewrite_html_pages(url, headers)
          url, headers = rewrite_thumbnails(url, headers)
          url, headers = rewrite_old_small_manga_pages(url, headers)
        end

        # http://i2.pixiv.net/img-zip-ugoira/img/2014/08/05/06/01/10/44524589_ugoira1920x1080.zip
        if url =~ %r!\Ahttps?://i[12]\.pixiv\.net/img-zip-ugoira/img/\d{4}/\d{2}/\d{2}/\d{2}/\d{2}/\d{2}/\d+_ugoira\d+x\d+\.zip\z!i
          data[:ugoira_frame_data] = source.ugoira_frame_data
          data[:ugoira_width] = source.ugoira_width
          data[:ugoira_height] = source.ugoira_height
          data[:ugoira_content_type] = source.ugoira_content_type
        end

        return [url, headers, data]
      end

    protected
      def rewrite_headers(url, headers)
        headers["Referer"] = "http://www.pixiv.net"
        return [url, headers]
      end

      # Rewrite these:
      #   http://www.pixiv.net/i/18557054
      #   http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054
      #   http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054
      #   http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054
      #   http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1
      # Plus this:
      #   i2.pixiv.net/img-inf/img/2014/09/25/00/57/24/46170939_64x64.jpg
      def rewrite_html_pages(url, headers)
        if url =~ /illust_id=\d+/i || url =~ %r!pixiv\.net/img-inf/img/!i
          return [source.file_url, headers]
        else
          return [url, headers]
        end
      end

      # Rewrite these:
      #   http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_m.jpg
      #   http://i1.pixiv.net/c/600x600/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg
      def rewrite_thumbnails(url, headers)
        url = source.rewrite_thumbnails(url)
        return [url, headers]
      end

      # Rewrite these:
      #   http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_p0.jpg
      #   http://img04.pixiv.net/img/syounen_no_uta/46170939_p0.jpg
      # but not these:
      #   http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg
      #   http://i1.pixiv.net/c/600x600/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg
      #   http://i1.pixiv.net/img-original/img/2014/09/25/23/09/29/46183440_p0.jpg
      def rewrite_old_small_manga_pages(url, headers)
        if url !~ %r!/img-(?:original|master)/img/!i && url =~ %r!/(\d+_p\d+)\.!i
          match = $1
          repl = match.sub(/_p/, "_big_p")
          big_url = url.sub(match, repl)
          if http_exists?(big_url, headers)
            url = big_url
          end
        end

        return [url, headers]
      end

      def rewrite_cdn(url, headers)
        if url =~ %r{https?:\/\/(?:\w+\.)?pixiv\.net\.edgesuite\.net}
          url = url.sub(".edgesuite.net", "")
        end

        return [url, headers]
      end

      # Cache the source data so it gets fetched at most once.
      def source
        @source ||= begin
          source = ::Sources::Strategies::Pixiv.new(url)
          source.get

          source
        end
      end
    end
  end
end
