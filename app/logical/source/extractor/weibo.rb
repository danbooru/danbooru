# frozen_string_literal: true

# @see Source::URL::Weibo
module Source
  class Extractor
    class Weibo < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        elsif page_json.dig(:page_info, :type) == "video"
          image_urls_for_video
        else
          page_json[:pics].to_a.pluck(:url).map do |image_url|
            Source::URL.parse(image_url).try(:full_image_url) || image_url
          end
        end
      end

      def image_urls_for_video
        # https://weibo.com/2427303621/MxojLlLgQ (mixed videos and images)
        if post[:mix_media_info].present?
          media_items = post.dig(:mix_media_info, :items).to_a.pluck(:data).map do |item|
            item[:media_info] || item
          end
        # https://www.weibo.com/7817290049/N62KL5MpJ (single video)
        else
          media_items = [post.dig(:page_info, :media_info)].compact
        end

        media_items.filter_map do |item|
          # https://weibo.com/2427303621/MxojLlLgQ (mixed videos and images)
          # https://www.weibo.com/7817290049/N62KL5MpJ (video with playback_list)
          # https://m.weibo.cn/detail/4142890299009993 (video with empty playback_list)
          media_url = [
            item[:playback_list]&.max_by { |video| video.dig(:meta, :quality_index) }&.dig(:play_info, :url),
            item[:stream_url_hd],
            item[:stream_url],
            item.dig(:largest, :url),
          ].compact.first

          Source::URL.parse(media_url).try(:full_image_url) || media_url
        end
      end

      def page_url
        "https://www.weibo.com/#{artist_id}/#{illust_base62_id}" if artist_id.present? && illust_base62_id.present?
      end

      def tags
        tags = page_json[:text]&.parse_html&.css(".surl-text").to_a.map(&:text).select { |text| text&.match?(/^\#.*\#$/) }
        tags.map do |tag|
          tag = tag.delete_prefix("#").delete_suffix("#")
          [tag, "https://s.weibo.com/weibo?q=#{Danbooru::URL.escape("##{tag}#")}"]
        end
      end

      def profile_url
        "https://www.weibo.com/u/#{artist_id}" if artist_id.present?
      end

      def tag_name
        "weibo_#{artist_id}" if artist_id.present?
      end

      def display_name
        page_json.dig(:user, :screen_name)
      end

      def artist_id
        parsed_url.artist_short_id || parsed_referer&.artist_short_id || page_json.dig(:user, :id)
      end

      def artist_commentary_desc
        page_json[:text]
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://www.weibo.com") do |element|
          case element.name

          # Fix hashtag links to use desktop instead of mobile version.
          in "a" if element[:href]&.starts_with?("https://m.weibo.cn/search")
            element[:href] = "https://s.weibo.com/weibo?q=#{Danbooru::URL.escape(element.text)}"

          # Fix user profile links to use desktop instead of mobile version.
          in "a" if element[:href]&.starts_with?("https://m.weibo.cn/p/index")
            id = Danbooru::URL.parse(element[:href]).params[:containerid]
            element[:href] = "https://weibo.com/p/#{id}"

          # Fix external links.
          in "a" if element[:href]&.starts_with?("https://weibo.cn/sinaurl?u=")
            element[:href] = Danbooru::URL.parse(element[:href]).params[:u]

          # Remove emoticon images.
          # <span class="url-icon"> <img alt="[舔屏]" src="https://h5.sinaimg.cn/m/emoticon/icon/default/d_tian-3b1ce0a112.png" style="width:1em; height:1em;" /></span>
          in "img" if element[:src]&.starts_with?("https://h5.sinaimg.cn/m/emoticon")
            element.name = "span"
            element.content = element[:alt]

          else
            nil
          end
        end
      end

      def mobile_page_url
        parsed_url.mobile_url || parsed_referer&.mobile_url
      end

      def illust_id
        parsed_url.illust_id || parsed_referer&.illust_id
      end

      def illust_base62_id
        parsed_url.illust_base62_id || parsed_referer&.illust_base62_id || page_json[:bid]
      end

      memoize def page_json
        html = http.cache(1.minute).parsed_get(mobile_page_url)
        html.to_s[/var \$render_data = \[(.*)\]\[0\]/m, 1]&.parse_json&.dig("status") || {}
      end

      # This API doesn't work for certain posts that can only be opened on the mobile site. It's only used to grab
      # videos, since the mobile page doesn't return 1080p videos.
      memoize def post
        url = "https://www.weibo.com/ajax/statuses/show?id=#{illust_id}" if illust_id.present?
        http.no_follow.cookies(SUB: sub_cookie).cache(1.minute).parsed_get(url) || {}
      end

      # This `tid` value is tied to your IP and user agent.
      memoize def tid
        response = http.post("https://passport.weibo.com/visitor/genvisitor?cb=gen_callback")
        data = response.to_s[/({.*})/]&.parse_json&.dig(:data) || {}
        data[:tid]
      end

      memoize def visitor_cookies
        return {} unless tid.present?

        response = http.get("https://passport.weibo.com/visitor/visitor", params: { a: "incarnate", t: tid })
        response.cookies.to_h { |c| [c.name, c.value] }
      end

      def sub_cookie
        visitor_cookies["SUB"]
      end
    end
  end
end
