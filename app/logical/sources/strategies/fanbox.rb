# Image URLs #############################################################
#
# * OLD DOMAIN
# ** https://fanbox.pixiv.net/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png
#
# * NEW DOMAIN
# ** https://downloads.fanbox.cc/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png (full res)
# ** https://downloads.fanbox.cc/images/post/39714/c/1200x630/JvjJal8v1yLgc5DPyEI05YpT.jpeg (sample)
# ** https://downloads.fanbox.cc/images/post/39714/w/1200/JvjJal8v1yLgc5DPyEI05YpT.jpeg (sample)
#
# * POST COVERS
# * https://pixiv.pximg.net/c/1200x630_90_a2_g5/fanbox/public/images/post/186919/cover/VCI1Mcs2rbmWPg0mmiTisovn.jpeg
#
# * PROFILE IMAGES
# * https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg
# * https://pixiv.pximg.net/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg (dead URL type)
# * https://pixiv.pximg.net/c/1620x580_90_a2_g5/fanbox/public/images/creator/1566167/cover/WPqKsvKVGRq4qUjKFAMi23Z5.jpeg
# * https://pixiv.pximg.net/c/936x600_90_a2_g5/fanbox/public/images/plan/4635/cover/L6AZNneFuHW6r25CHHlkpHg4.jpeg
#
# Page URLs ##############################################################
#
# *  OLD
# ** https://www.pixiv.net/fanbox/creator/1566167/post/39714
#
# *  NEW
# ** https://omu001.fanbox.cc/posts/39714
# ** https://www.fanbox.cc/@tsukiori/posts/1080657
# ** https://brllbrll.fanbox.cc/posts/626093 (R-18)
#
#
# Profile URLs ###########################################################
#
# *  OLD
# ** https://www.pixiv.net/fanbox/creator/1566167
#
# * NEW
# ** https://omu001.fanbox.cc/
#

module Sources
  module Strategies
    class Fanbox < Base
      PROFILE_OLD = %r{\Ahttps?://(?:www\.)?pixiv\.net/fanbox/creator/(?<artist_id>\d+)}i
      PROFILE_NEW = %r{\Ahttps?://(?:(?!www|downloads)(?<artist_name>[\w-]+)\.fanbox\.cc|(?:www\.)?fanbox\.cc/@(?<artist_name>[\w-]+))}i

      PAGE_OLD    = %r{#{PROFILE_OLD}/post/(?<illust_id>\d+)}i
      PAGE_NEW    = %r{#{PROFILE_NEW}/posts/(?<illust_id>\d+)}i

      IMAGE        = %r{\Ahttps?://(?:fanbox\.pixiv\.net|downloads\.fanbox\.cc)/images/post/(?<illust_id>\d+)/(?:\w+/)*\w+\.\w+}i

      OTHER_IMAGES = %r{\Ahttps?://pixiv\.pximg\.net/.*/fanbox/.*?/(?:(?:creator|user)/(?<artist_id>\d+)|post/(?<illust_id>\d+))?/(?:.*/)?\w+\.\w+}i

      def domains
        ["fanbox.cc", "pixiv.net", "pximg.net"]
      end

      def site_name
        "Pixiv Fanbox"
      end

      def image_urls
        if url =~ IMAGE || url =~ OTHER_IMAGES
          [url]
        elsif api_response.present?
          # There's two ways pics are returned via api:
          # Pics in proper array: https://yanmi0308.fanbox.cc/posts/1141325
          # Embedded pics (imageMap): https://www.fanbox.cc/@tsukiori/posts/1080657
          images = api_response.dig("body", "images").to_a + api_response.dig("body", "imageMap").to_a.map { |id| id[1] }
          images.map { |img| img["originalUrl"] }
        else
          [url]
        end
      end

      def page_url
        if illust_id.present?
          "https://#{artist_name}.fanbox.cc/posts/#{illust_id}"
        elsif url =~ OTHER_IMAGES && artist_name.present?
          # Cover images
          "https://#{artist_name}.fanbox.cc"
        end
      end

      def normalize_for_source
        if illust_id.present?
          if artist_name_from_url.present?
            "https://#{artist_name_from_url}.fanbox.cc/posts/#{illust_id}"
          elsif artist_id_from_url.present?
            "https://www.pixiv.net/fanbox/creator/#{artist_id_from_url}/post/#{illust_id}"
          end
        elsif artist_id_from_url.present?
          # Cover images
          "https://www.pixiv.net/fanbox/creator/#{artist_id_from_url}"
        end
      end

      def profile_url
        return if artist_name.blank?

        "https://#{artist_name}.fanbox.cc"
      end

      def artist_name
        artist_name_from_url || api_response["creatorId"] || artist_api_response["creatorId"]
      end

      def display_name
        api_response.dig("user", "name") || artist_api_response.dig("user", "name")
      end

      def other_names
        [artist_name, display_name].compact.uniq
      end

      def tags
        api_response["tags"].to_a.map { |tag| [tag, "https://fanbox.cc/tags/#{tag}"] }
      end

      def artist_commentary_title
        api_response["title"]
      end

      def artist_commentary_desc
        body = api_response["body"]
        return if body.blank?

        if body["text"].present?
          body["text"]
        elsif body["blocks"].present?
          # Reference: https://official.fanbox.cc/posts/182757
          # Commentary can get pretty complex, but unfortunately it's served in json format so it's a pain to parse it.
          # I've left out parsing external embeds because each supported site has its own id mapped to the domain
          commentary = body["blocks"].map do |node|
            if node["type"] == "image"
              body["imageMap"][node["imageId"]]["originalUrl"]
            else
              node["text"] || "\n"
            end
          end
          commentary.join("\n")
        end
      end

      def illust_id
        urls.map { |url| url[PAGE_NEW, :illust_id] || url[IMAGE, :illust_id] || url[PAGE_OLD, :illust_id] || url[OTHER_IMAGES, :illust_id] }.compact.first
      end

      def artist_id_from_url
        urls.map { |url| url[PAGE_OLD, :artist_id] || url[OTHER_IMAGES, :artist_id] }.compact.first
      end

      def artist_name_from_url
        urls.map { |url| url[PROFILE_NEW, :artist_name] }.compact.first
      end

      def api_response
        return {} if illust_id.blank?
        resp = client.get("https://api.fanbox.cc/post.info?postId=#{illust_id}")
        json_response = JSON.parse(resp)["body"]

        # Pixiv Fanbox login is protected by Google Recaptcha, so it's not
        # possible for us to extract anything from them (save for the title).
        # Other projects like PixivUtils ask the user to periodically extract
        # cookies from the browser, but this is not feasible for Danbooru.
        return {} if json_response["restrictedFor"] == 2 && json_response["body"].blank?

        json_response
      rescue JSON::ParserError
        {}
      end

      def artist_api_response
        # Needed to fetch artist from cover pages
        return {} if artist_id_from_url.blank?
        resp = client.get("https://api.fanbox.cc/creator.get?userId=#{artist_id_from_url}")
        JSON.parse(resp)["body"]
      rescue JSON::ParserError
        {}
      end

      def client
        @client ||= http.headers(Origin: "https://fanbox.cc").cache(1.minute)
      end
    end
  end
end
