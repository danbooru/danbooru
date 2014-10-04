module Downloads
  module Strategies
    class Pixiv < Base
      def rewrite(url, headers)
        if url =~ /https?:\/\/(?:\w+\.)?pixiv\.net/
          url, headers = rewrite_headers(url, headers)
          url, headers = rewrite_cdn(url, headers)
          url, headers = rewrite_html_pages(url, headers)
          url, headers = rewrite_small_and_medium_images(url, headers)
          url, headers = rewrite_old_small_manga_pages(url, headers)
        end

        return [url, headers]
      end

    protected
      def rewrite_headers(url, headers)
        headers["Referer"] = "http://www.pixiv.net"
        return [url, headers]
      end

      def rewrite_html_pages(url, headers)
        # example: http://www.pixiv.net/member_illust.php?mode=big&illust_id=23828655

        if url =~ %r!illust_id=\d+!
          source = ::Sources::Strategies::Pixiv.new(url)
          source.get
          return [source.image_url, headers]
        else
          return [url, headers]
        end
      end

      def rewrite_small_and_medium_images(url, headers)
        if url =~ %r!(/img/.+?/.+?)_m.+$!
          match = $1
          url.sub!(match + "_m", match)
        elsif url !~ %r!/img-inf/! && url =~ %r!(/img/.+?/.+?)_s.+$!
          match = $1
          url.sub!(match + "_s", match)
        end

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
          url.sub!(".edgesuite.net", "")
        end

        return [url, headers]
      end
    end
  end
end
