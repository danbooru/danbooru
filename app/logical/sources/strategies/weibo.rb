# Image URLS
# * http://ww1.sinaimg.cn/large/69917555gw1f6ggdghk28j20c87lbhdt.jpg
#
# Image Samples
# * http://ww4.sinaimg.cn/mw690/77a2d531gw1f4u411ws3aj20m816fagg.jpg
# * https://wx4.sinaimg.cn/orj360/e3930166gy1g546bz86cij20u00u040y.jpg
# * http://ww3.sinaimg.cn/mw1024/0065kjmOgw1fabcanrzx6j30f00lcjwv.jpg
#
# Page URLS
# * http://weibo.com/3357910224/EEHA1AyJP
# * https://www.weibo.com/5501756072/IF9fugHzj?from=page_1005055501756072_profile&wvr=6&mod=weibotime
#
# * http://photo.weibo.com/5732523783/talbum/detail/photo_id/4029784374069389?prel=p6_3
# * http://photo.weibo.com/2125874520/wbphotos/large/mid/4194742441135220/pid/7eb64558gy1fnbryb5nzoj20dw10419t
# * http://tw.weibo.com/1300957955/3786333853668537
#
# * https://m.weibo.cn/detail/4506950043618873
# * https://m.weibo.cn/status/J33G4tH1B
#
# Video
# * https://www.weibo.com/5501756072/IF9fugHzj
#
# Profile URLS
# ### Short ID
# * https://www.weibo.com/5501756072
# * https://www.weibo.com/u/5501756072
# * https://m.weibo.cn/profile/5501756072
# * https://m.weibo.cn/u/5501756072
# ### Long ID
# * https://www.weibo.com/p/1005055501756072

module Sources
  module Strategies
    class Weibo < Base
      PROFILE_URL_1 = %r{\Ahttps?://(?:(?:www|m)\.)?weibo\.c(?:om|n)/(?:(?:u|profile)/)?(?<artist_short_id>\d+)\z}i
      PROFILE_URL_2 = %r{\Ahttps?://photo\.weibo\.com/(?<artist_short_id>\d+)}i
      PROFILE_URL_3 = %r{\Ahttps?://(?:www\.)?weibo\.com/p/(?<artist_long_id>\d+)}i

      PAGE_URL_1    = %r{\Ahttps?://(?:www\.)?weibo\.com/(?<artist_short_id>\d+)/(?<illust_base62_id>\w+)(?:\?.*)?\z}i
      PAGE_URL_2    = %r{#{PROFILE_URL_2}/(?:wbphotos/large/mid|talbum/detail/photo_id)/(?<illust_long_id>\d+)(?:/pid/(?<image_id>\w{32}))?}i
      PAGE_URL_3    = %r{\Ahttps?://m\.weibo\.cn/(?:detail/(?<illust_long_id>\d+)|status/(?<illust_base62_id>\w+))}i
      PAGE_URL_4    = %r{\Ahttps?://tw\.weibo\.com/(?:(?<artist_short_id>\d+)|\w+)/(?<illust_long_id>\d+)}i

      IMAGE_URL     = %r{\Ahttps?://\w{3}\.sinaimg\.cn/\w+/(?<image_id>\w{32})\.}i

      def domains
        ["weibo.com", "weibo.cn", "weibocdn.com", "sinaimg.cn"]
      end

      def site_name
        "Weibo"
      end

      def image_urls
        urls = []

        if url =~ IMAGE_URL
          urls << self.class.convert_image_to_large(url)
        elsif api_response.present?
          if api_response["pics"].present?
            urls += api_response["pics"].to_a.map { |pic| self.class.convert_image_to_large(pic["url"]) }
          elsif api_response.dig("page_info", "type") == "video"
            variants = api_response["page_info"]["media_info"].to_h.values + api_response["page_info"]["urls"].to_h.values
            urls << variants.max_by do |variant|
              if /template=(?<width>\d+)x(?<height>\d+)/ =~ variant.to_s
                width.to_i * height.to_i
              else
                0
              end
            end
          end
        else
          urls << url
        end

        urls
      end

      def image_url
        image_id = url[PAGE_URL_2, :image_id] if url =~ PAGE_URL_2

        if image_id.present?
          image_urls.select { |i| i[IMAGE_URL, :image_id] == image_id }.compact.first
        else
          image_urls.first
        end
      end

      def preview_urls
        image_urls.map { |img| img.gsub(%r{.cn/\w+/(\w+)}, '.cn/orj360/\1') }
      end

      def page_url
        if api_response.present?
          artist_id = api_response["user"]["id"]
          illust_id = api_response["bid"]
          "https://www.weibo.com/#{artist_id}/#{illust_id}"
        elsif url =~ IMAGE_URL
          self.class.convert_image_to_large(url)
        else
          url
        end
      end

      def tags
        return [] if api_response.blank?

        matches = api_response["text"]&.scan(/surl-text">#(.*?)#</).to_a.map { |m| m[0] }

        matches.map do |match|
          [match, "https://s.weibo.com/weibo/#{match}"]
        end
      end

      def profile_urls
        [profile_short_url, profile_long_url].compact
      end

      def profile_url
        profile_urls.first
      end

      def profile_short_url
        return if artist_short_id.blank?

        "https://www.weibo.com/u/#{artist_short_id}"
      end

      def profile_long_url
        return if artist_long_id.blank?

        "https://www.weibo.com/p/#{artist_long_id}"
      end

      def artist_commentary_desc
        return if api_response.blank?

        api_response["text"]
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc) do |element|
          if element["href"].present?
            href = Addressable::URI.heuristic_parse(element["href"])
            href.site ||= "https://www.weibo.com"
            href.scheme ||= "https"
            element["href"] = href.to_s
          end

          if element["src"].present?
            src = Addressable::URI.heuristic_parse(element["src"])
            src.scheme ||= "https"
            element["src"] = src.to_s
          end
        end
      end

      def normalize_for_source
        return url if url =~ PAGE_URL_2
        artist_id = artist_short_id_from_url

        if artist_id.present?
          if illust_base62_id.present?
            "https://www.weibo.com/#{artist_id}/#{illust_base62_id}"
          elsif illust_long_id.present?
            "https://photo.weibo.com/#{artist_id}/talbum/detail/photo_id/#{illust_long_id}"
          end
        elsif mobile_url.present?
          mobile_url
        end
      end

      def self.convert_image_to_large(url)
        url.gsub(%r{.cn/\w+/(\w+)}, '.cn/large/\1')
      end

      def illust_long_id
        [url, referer_url].compact.map { |x| x[PAGE_URL_2, :illust_long_id] || x[PAGE_URL_3, :illust_long_id] || x[PAGE_URL_4, :illust_long_id] }.compact.first
      end

      def illust_base62_id
        [url, referer_url].compact.map { |x| x[PAGE_URL_1, :illust_base62_id] || x[PAGE_URL_3, :illust_base62_id] }.compact.first
      end

      def artist_short_id_from_url
        [url, referer_url].compact.map { |x| x[PROFILE_URL_1, :artist_short_id] || x[PROFILE_URL_2, :artist_short_id] || x[PAGE_URL_1, :artist_short_id] || x[PAGE_URL_4, :artist_short_id] }.compact.first
      end

      def artist_short_id
        artist_short_id_from_url || api_response&.dig("user", "id")
      end

      def artist_long_id
        [url, referer_url].compact.map { |x| x[PROFILE_URL_3, :artist_long_id] }.compact.first
      end

      def mobile_url
        if illust_long_id.present?
          "https://m.weibo.cn/detail/#{illust_long_id}"
        elsif illust_base62_id.present?
          "https://m.weibo.cn/status/#{illust_base62_id}"
        end
      end

      def api_response
        return {} if mobile_url.blank?

        resp = http.cache(1.minute).get(mobile_url)
        json_string = resp.to_s[/var \$render_data = \[(.*)\]\[0\]/m, 1]

        return {} if json_string.blank?

        JSON.parse(json_string)["status"]
      end
      memoize :api_response
    end
  end
end
