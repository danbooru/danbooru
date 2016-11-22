# Sample images:
#
#   http://img5.bcyimg.com/drawer/1491/cover/c04ey/7a85f760aa7e11e688552967e7522d45.jpg
#   http://img5.bcyimg.com/drawer/1491/post/c04ey/7a85f760aa7e11e688552967e7522d45.jpg/2X2
#   http://img5.bcyimg.com/drawer/1491/post/c04ey/7a85f760aa7e11e688552967e7522d45.jpg/2X3
#   http://img5.bcyimg.com/drawer/1491/post/c04ey/7a85f760aa7e11e688552967e7522d45.jpg/tl640
#   http://img5.bcyimg.com/drawer/1491/post/c04ey/7a85f760aa7e11e688552967e7522d45.jpg/w230
#   http://img5.bcyimg.com/drawer/1491/post/c04ey/7a85f760aa7e11e688552967e7522d45.jpg/w650
#
# Full image:
#
#   http://img9.bcyimg.com/drawer/1491/post/c04ey/7a85f760aa7e11e688552967e7522d45.jpg
#
# Work page:
#
#     http://bcy.net/illust/detail/28966/918325
#

module Sources
  module Strategies
    class BCY < Base
      BCYIMG = '(?<subdomain>img[59])\.bcyimg\.com'
      DRAWER = '(?<drawer>[0-9]+)'
      DATE   = '(?<date>[a-z0-9]{1,5})'
      HASH   = '(?<hash>[a-z0-9]{32})'
      EXT    = '(?<ext>jpg|jpeg|png|gif)'
      SUFFIX = '(?:/(?<suffix>2X2|2X3|tl640|w230|w650))'
      WATERMARK = '(?:\?imageMogr2.*)'

      IMAGE_URL = %r!\Ahttps?://#{BCYIMG}/drawer/#{DRAWER}/(?:cover|post)/#{DATE}/#{HASH}\.#{EXT}#{SUFFIX}?#{WATERMARK}?\Z!

      def self.url_match?(url)
        url =~ IMAGE_URL
      end

      def site_name
        "BCY"
      end

      def image_url
        case url
        when IMAGE_URL
          @image_url ||= sample_image_to_full_image(url)
        end
      end

      def sample_image_to_full_image(url)
        m = IMAGE_URL.match(url)
        "http://img9.bcyimg.com/drawer/#{m[:drawer]}/post/#{m[:date]}/#{m[:hash]}.#{m[:ext]}"
      end
    end
  end
end
