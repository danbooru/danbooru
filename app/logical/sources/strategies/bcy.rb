# Sample images:
#
#   http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg?imageMogr2/auto-orient/strip|watermark/2/text/wqlIYXNlbG51dHMKYmN5Lm5ldC91LzEzNzQwMDk=/fontsize/432/fill/I0U1RTVFNQ==/dx/6/dy/10/font/5b6u6L2v6ZuF6buR
#   http://img9.bcyimg.com/drawer/76491/cover/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg
#   http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg/2X2
#   http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg/2X3
#   http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg/tl640
#   http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg/w230
#   http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg/w650
#   http://img5.bcyimg.com/drawer/76491/post/c04f6/c63112f0b12511e691db2d08ae08b1d2.png/w650
#   http://img5.bcyimg.com/drawer/76491/post/c04f6/335aac00b12711e691db2d08ae08b1d2.gif/w650
#   http://img5.bcyimg.com/drawer/76491/post/c04f6/33efc010b12711e691db2d08ae08b1d2.jpeg/w650
#
# Full image:
#
#   http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg
#
# Work pages:
#
#   Login only:      http://bcy.net/illust/detail/76491/919327
#   Follower only:   http://bcy.net/illust/detail/76491/919439
#   Single image:    http://bcy.net/illust/detail/76491/919427
#   Multiple images: http://bcy.net/illust/detail/76491/919312
#

module Sources
  module Strategies
    class BCY < Base
      BCYIMG = '(?<subdomain>img[59])\.bcyimg\.com'
      BCYNET = '(?:www\.)?bcy\.net'
      DRAWER = '(?<drawer>[0-9]+)'
      DATE   = '(?<date>[a-z0-9]{1,5})'
      HASH   = '(?<hash>[a-z0-9]{32})'
      EXT    = '(?<ext>jpg|jpeg|png|gif)'
      SUFFIX = '(?:/(?<suffix>2X2|2X3|tl640|w230|w650))'
      WATERMARK = '(?:\?imageMogr2.*)'

      IMAGE_URL = %r!\Ahttps?://#{BCYIMG}/drawer/#{DRAWER}/(?:cover|post)/#{DATE}/#{HASH}\.#{EXT}#{SUFFIX}?#{WATERMARK}?\Z!
      PAGE_URL  = %r!\Ahttps?://#{BCYNET}/illust/detail/(?<dp_id>[0-9]+)/(?<rp_id>[0-9]+)\Z!

      def self.url_match?(url)
        url =~ IMAGE_URL || url =~ PAGE_URL
      end

      def self.sample_image_to_full_image(url)
        m = IMAGE_URL.match(url)
        "http://img9.bcyimg.com/drawer/#{m[:drawer]}/post/#{m[:date]}/#{m[:hash]}.#{m[:ext]}"
      end

      def initialize(url, referer_url = nil)
        @url, @referer_url = url, referer_url
      end

      def site_name
        "BCY"
      end

      def get
      end

      def image_url
        image_urls.first
      end

      def image_urls
        case url
        when PAGE_URL
          @image_urls ||= work_page.search("img.detail_std").map do |img|
            self.class.sample_image_to_full_image(img.attr("src"))
          end
        when IMAGE_URL
          @image_urls ||= [self.class.sample_image_to_full_image(url)]
        end
      end

      def page_count
        return nil unless work_page?
        image_urls.size
      end

      def tags
        return [[]] unless work_page?

        selector = ".tags .tag a, .post__info .post__role.post__info-group a"
        @tags ||= work_page.search(selector).map do |link|
          tag = link.text.strip
          page = link.attr("href") ? "http://bcy.net#{link.attr("href")}" : ""
          [tag, page]
        end
      end

      def has_artist_commentary?
        artist_commentary_title.present? || artist_commentary_desc.present?
      end

      def artist_commentary_title
        return nil unless work_page?
        @artist_commentary_title ||= work_page.search(".post__title h1").first.text.strip
      end

      def artist_commentary_desc
        return nil unless work_page?
        @artist_commentary_desc ||= work_page.search(".post__content.mb0").first.text.strip
      end

      def artist_name
        return nil unless work_page?
        @artist_name ||= work_page.search(".l-detailUser-name a").first.text
      end

      def unique_id
        return nil unless work_page?
        href = work_page.search(".l-detailUser-name a").first.attr("href")
        @unique_id ||= href[%r!\A/u/([0-9]+)\Z!, 1]
      end

      def profile_url
        return nil unless work_page?
        "http://bcy.net/u/" + unique_id
      end

      def work_page?
        url =~ PAGE_URL
      end

      def work_page
        return nil unless work_page?
        @work_page ||= agent.get(url)
      end

      def agent
        @agent ||= BCYWebAgent.build
      end
    end
  end
end
