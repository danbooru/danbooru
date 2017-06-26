module Downloads
  module RewriteStrategies
    DOMAIN = '(data|(\d+\.)?media)\.tumblr\.com'
    MD5 = '(?<md5>[0-9a-f]{32})'
    FILENAME = '(?<filename>(tumblr_(inline_)?)?[a-z0-9]+(_r[0-9]+)?)'
    SIZES = '(250|400|500|500h|540|1280|raw)'
    EXT = '(?<ext>\w+)'

    class Tumblr < Base
      def rewrite(url, headers, data = {})
        url = rewrite_cdn(url)
        url = rewrite_samples(url, headers)
        url = rewrite_html_pages(url)

        return [url, headers, data]
      end

    protected
      # Look for the biggest available version on data.tumblr.com. A bigger
      # version may or may not exist.
      #
      # http://40.media.tumblr.com/d8c6d49785c0842ee31ff26c010b7445/tumblr_naypopLln51tkufhoo2_500h.png
      # => http://data.tumblr.com/d8c6d49785c0842ee31ff26c010b7445/tumblr_naypopLln51tkufhoo2_raw.png
      #
      # https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg
      # => http://data.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_raw.jpg
      #
      # https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif
      # => http://data.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_500.gif
      #
      # https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
      # => http://data.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png
      #
      # http://data.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_400.jpg
      # => http://data.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_500.jpg
      #
      # http://data.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg
      # => http://data.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg
      def rewrite_samples(url, headers)
        if url =~ %r!\Ahttps?://#{DOMAIN}/(?<dir>#{MD5}/)?#{FILENAME}_#{SIZES}\.#{EXT}\z!i
          sizes = ["raw", 1280, 540, 500, 400, 250]
          candidates = sizes.map do |size|
            "http://data.tumblr.com/#{$~[:dir]}#{$~[:filename]}_#{size}.#{$~[:ext]}"
          end

          url = candidates.find do |candidate|
            http_exists?(candidate, headers)
          end
        end

        url
      end

      # https://gs1.wac.edgecastcdn.net/8019B6/data.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
      # => http://data.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
      def rewrite_cdn(url)
        url.sub!(%r!\Ahttps?://gs1\.wac\.edgecastcdn\.net/8019B6/data\.tumblr\.com!i, "http://data.tumblr.com")
        url
      end

      def rewrite_html_pages(url)
        if Sources::Strategies::Tumblr.url_match?(url)
          url = Sources::Strategies::Tumblr.new(url).image_url
        end

        url
      end
    end
  end
end
