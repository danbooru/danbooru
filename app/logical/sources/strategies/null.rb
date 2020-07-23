module Sources
  module Strategies
    class Null < Base
      def image_urls
        [url]
      end

      def page_url
        url
      end

      def canonical_url
        image_url
      end

      def normalize_for_source
        case url
        when %r{\Ahttps?://(?:d3j5vwomefv46c|dn3pm25xmtlyu)\.cloudfront\.net/photos/large/(\d+)\.}i
          base_10_id = $1.to_i
          base_36_id = base_10_id.to_s(36)
          "https://twitpic.com/#{base_36_id}"

        when %r{\Ahttp://www\.karabako\.net/images(?:ub)?/karabako_(\d+)(?:_\d+)?\.}i
          "http://www.karabako.net/post/view/#{$1}"

        # XXX http://twipple.jp is defunct
        # http://p.twpl.jp/show/orig/myRVs
        when %r{\Ahttp://p\.twpl\.jp/show/(?:large|orig)/([a-z0-9]+)}i
          "http://p.twipple.jp/#{$1}"

        when %r{\Ahttps?://blog(?:(?:-imgs-)?\d*(?:-origin)?)?\.fc2\.com/(?:(?:[^/]/){3}|(?:[^/]/))([^/]+)/(?:file/)?([^.]+\.[^?]+)}i
          username = $1
          filename = $2
          "http://#{username}.blog.fc2.com/img/#{filename}/"

        when %r{\Ahttps?://diary(\d)?\.fc2\.com/user/([^/]+)/img/(\d+)_(\d+)/(\d+)\.}i
          server_id = $1
          username = $2
          year = $3
          month = $4
          day = $5
          "http://diary#{server_id}.fc2.com/cgi-sys/ed.cgi/#{username}?Y=#{year}&M=#{month}&D=#{day}"

        when %r{\Ahttps?://(?:fbcdn-)?s(?:content|photos)-[^/]+\.(?:fbcdn|akamaihd)\.net/hphotos-.+/\d+_(\d+)_(?:\d+_){1,3}[no]\.}i
          "https://www.facebook.com/photo.php?fbid=#{$1}"

        when %r{\Ahttps?://c(?:s|han|[1-4])\.sankakucomplex\.com/data(?:/sample)?/(?:[a-f0-9]{2}/){2}(?:sample-|preview)?([a-f0-9]{32})}i
          "https://chan.sankakucomplex.com/en/post/show?md5=#{$1}"

        when %r{\Ahttps?://(?:www|s(?:tatic|[1-4]))\.zerochan\.net/.+(?:\.|\/)(\d+)(?:\.(?:jpe?g?|png))?\z}i
          "https://www.zerochan.net/#{$1}#full"

        when %r{\Ahttps?://static[1-6]?\.minitokyo\.net/(?:downloads|view)/(?:\d{2}/){2}(\d+)}i
          "http://gallery.minitokyo.net/download/#{$1}"

        # https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg
        # http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png
        # https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg
        when %r{\Ahttps?://(?:\w+\.)?gelbooru\.com//?(?:images|samples)/(?:\d+|\h\h/\h\h)/(?:sample_)?(?<md5>\h{32})\.}i
          "https://gelbooru.com/index.php?page=post&s=list&md5=#{$~[:md5]}"

        when %r{\Ahttps?://(?:slot\d*\.)?im(?:g|ages)\d*\.wikia\.(?:nocookie\.net|com)/(?:_{2}cb\d{14}/)?([^/]+)(?:/[a-z]{2})?/images/(?:(?:thumb|archive)?/)?[a-f0-9]/[a-f0-9]{2}/(?:\d{14}(?:!|%21))?([^/]+)}i
          subdomain = $1
          filename = $2
          "https://#{subdomain}.wikia.com/wiki/File:#{filename}"

        when %r{\Ahttps?://vignette(?:\d*)\.wikia\.nocookie\.net/([^/]+)/images/[a-f0-9]/[a-f0-9]{2}/([^/]+)}i
          subdomain = $1
          filename = $2
          "https://#{subdomain}.wikia.com/wiki/File:#{filename}"

        when %r{\Ahttps?://e-shuushuu.net/images/\d{4}-(?:\d{2}-){2}(\d+)}i
          "https://e-shuushuu.net/image/#{$1}"

        when %r{\Ahttps?://jpg\.nijigen-daiaru\.com/(\d+)}i
          "http://nijigen-daiaru.com/book.php?idb=#{$1}"

        when %r{\Ahttps?://sozai\.doujinantena\.com/contents_jpg/([a-f0-9]{32})/}i
          "http://doujinantena.com/page.php?id=#{$1}"

        when %r{\Ahttps?://rule34-(?:data-\d{3}|images)\.paheal\.net/(?:_images/)?([a-f0-9]{32})}i
          "https://rule34.paheal.net/post/list/md5:#{$1}/1"

        when %r{\Ahttps?://shimmie\.katawa-shoujo\.com/image/(\d+)}i
          "https://shimmie.katawa-shoujo.com/post/view/#{$1}"

        when %r{\Ahttps://(?:(?:\w+\.)?rule34\.xxx|img\.booru\.org/(?:rule34|r34))(?:/(?:img/rule34|r34))?/{1,2}images/\d+/([a-f0-9]{32})\.}i
          "https://rule34.xxx/index.php?page=post&s=list&md5=#{$1}"

        when %r{(\Ahttps?://.+)/diarypro/d(?:ata/upfile/|iary\.cgi\?mode=image&upfile=)(\d+)}i
          base_url = $1
          entry_no = $2
          "#{base_url}/diarypro/diary.cgi?no=#{entry_no}"

        # XXX site is defunct
        when %r{\Ahttps?://i(?:\d)?\.minus\.com/(?:i|j)([^\.]{12,})}i
          "http://minus.com/i/#{$1}"

        # http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg
        # http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg
        when %r{\Ahttps?://\w+\.photozou\.jp/pub/\d+/(?<artist_id>\d+)/photo/(?<photo_id>\d+)_.*$}i
          "https://photozou.jp/photo/show/#{$~[:artist_id]}/#{$~[:photo_id]}"

        # http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg
        # http://img.toranoana.jp/popup_img18/04/0010/22/87/040010228714-1p.jpg
        # http://img.toranoana.jp/popup_blimg/04/0030/08/30/040030083068-1p.jpg
        # https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg
        when %r{\Ahttps?://(?:\w+\.)?toranoana\.jp/(?:popup_(?:bl)?img\d*|ec/img)/\d{2}/\d{4}/\d{2}/\d{2}/(?<work_id>\d+)}i
          "https://ec.toranoana.jp/tora_r/ec/item/#{$~[:work_id]}/"

        # https://a.hitomi.la/galleries/907838/1.png
        # https://0a.hitomi.la/galleries/1169701/23.png
        # https://aa.hitomi.la/galleries/990722/003_01_002.jpg
        # https://la.hitomi.la/galleries/1054851/001_main_image.jpg
        when %r{\Ahttps?://\w+\.hitomi\.la/galleries/(?<gallery_id>\d+)/(?<image_id>\d+)\w*\.[a-z]+\z}i
          "https://hitomi.la/reader/#{$~[:gallery_id]}.html##{$~[:image_id].to_i}"

        # https://aa.hitomi.la/galleries/883451/t_rena1g.png
        when %r{\Ahttps?://\w+\.hitomi\.la/galleries/(?<gallery_id>\d+)/\w*\.[a-z]+\z}i
          "https://hitomi.la/galleries/#{$~[:gallery_id]}.html"

        else
          nil
        end
      end
    end
  end
end
