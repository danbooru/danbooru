module Sources
  module Strategies
    class FC2 < Base
      USERNAME = '(?:[^/]+)'
      FILENAME = '(?:[^/]+\.[a-z]{1,4})'
      DIARY    = '\A(?:https?://)?diary\d*\.fc2\.com'
      OLDBLOG  = '\A(?:https?://)blog\d*\.fc2\.com'
      BLOG     = '\A(?:https?://)?[^/]+\.blog\d*\.fc2\.com'
      WEB      = '\A(?:https?://)?[^/]+\.(?:(?:web|h|x)\.fc2|fc2web)\.com'
      BLOGIMGS = '\A(?:https?://)?blog-imgs-\d+(?:-origin)?\.fc2\.com'

      def self.url_match?(url)
        # This is a diary work page URL.
        # http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom?Y=2014&M=10&D=26
        return true if url =~ %r!#{DIARY}/cgi-sys/ed\.cgi/[^/]\?Y=\d{4}&M=\d{1,2}&D={1,2}\z!i

        # This is a diary direct image URL.
        # http://diary1.fc2.com/user/hitorigoto3/img/2011_9/25.jpg
        return true if url =~ %r!#{DIARY}/user/#{USERNAME}/img/\d{4}_\d{1,2}/\d{1,2}\.[a-z]+\z!i

        # These are blog work page URLs.
        # http://flanvia.blog.fc2.com/img/20140306184507199.png/
        # http://digdug006.blog118.fc2.com/img/Reiko2014.jpg/
        return true if url =~ %r!#{BLOG}/img/#{FILENAME}/\z!i

        # These are blog direct image URLs.
        # http://blog-imgs-63.fc2.com/p/u/c/pucco2/2032gou(2).jpg
        # http://blog-imgs-67-origin.fc2.com/d/i/g/digdug006/Reiko2014.jpg
        return true if url =~ %r!#{BLOGIMGS}/./././#{USERNAME}/#{FILENAME}\z!i

        # These are old blog direct image URLs that stopped being used in 2008-2009.
        # They no longer work but they're seen in older posts.
        #
        # http://blog.fc2.com/m/mueyama/file/20060911-640.jpg
        # http://blog.fc2.com/j/a/h/jahreszeiten/nanoha.jpg
        # http://blog105.fc2.com/t/teromere/file/091006.jpg
        return true if url =~ %r!#{OLDBLOG}/(./){1,3}#{USERNAME}/file/#{FILENAME}\z!i

        # These are web.fc2.com, h.fc2.com, x.fc2.com, and fc2web.com URLs. The
        # file path has no pattern across artists; it's determined by the individual artist.
        #
        # http://eruboru.web.fc2.com/XenoTaker0001.PNG
        # http://arche.x.fc2.com/130507yuyushiki.jpg
        # http://azumaya.h.fc2.com/image/28.jpg
        # http://allenemy.fc2web.com/c74/179.jpg
        return true if url =~ %r!#{WEB}!i

        return false
      end

      def site_name
        "FC2"
      end

      def normalize_for_dupe_search
        #    http://newrp.blog34.fc2.com/img/fc2blog_20140718045830c1a.jpg/
        #    http://newrp.blog.fc2.com/img/fc2blog_20140718045830c1a.jpg/
        # => http://newrp.blog*.fc2.com/img/fc2blog_20140718045830c1a.jpg/
        search_url = url.sub(%r!\A(?:https?://)?#{USERNAME}\.(blog\d*\.fc2\.com)/img/#{FILENAME}/\z!i) do |url|
          domain = $1
          url.sub(domain, 'blog*.fc2.com')
        end

        #    http://blog-imgs-58-origin.fc2.com/t/e/n/tenchisouha/ratifa01.jpg
        #    http://blog-imgs-58.fc2.com/t/e/n/tenchisouha/ratifa01.jpg
        # => http://blog-imgs-58*.fc2.com/t/e/n/tenchisouha/ratifa01.jpg
        search_url = search_url.sub(%r!\A(?:https?://)?(blog-imgs-\d+(?:-origin)?)\.fc2\.com/./././#{USERNAME}/#{FILENAME}\z!i) do |url|
          old_subdomain = $1
          new_subdomain = old_subdomain.sub('-origin', '') + '*'
          url.sub(old_subdomain, new_subdomain)
        end
      end
    end
  end
end
