# Original images:
#
# * https://yande.re/image/b4b1d11facd1700544554e4805d47bb6/.png
# * https://files.yande.re/image/e4c2ba38de88ff1640aaebff84c84e81/469784.jpg
# * https://files.yande.re/image/2a5d1d688f565cb08a69ecf4e35017ab/yande.re%20349790%20breast_hold%20kurashima_tomoyasu%20mahouka_koukou_no_rettousei%20naked%20nipples.jpg
# * https://ayase.yande.re/image/2d0d229fd8465a325ee7686fcc7f75d2/yande.re%20192481%20animal_ears%20bunny_ears%20garter_belt%20headphones%20mitha%20stockings%20thighhighs.jpg
# * https://yuno.yande.re/image/1764b95ae99e1562854791c232e3444b/yande.re%20281544%20cameltoe%20erect_nipples%20fundoshi%20horns%20loli%20miyama-zero%20sarashi%20sling_bikini%20swimsuits.jpg
# * https://konachan.com/image/5d633771614e4bf5c17df19a0f0f333f/Konachan.com%20-%20270807%20black_hair%20bokuden%20clouds%20grass%20landscape%20long_hair%20original%20phone%20rope%20scenic%20seifuku%20skirt%20sky%20summer%20torii%20tree.jpg
#
# Jpeg sample images (full size is .png):
#
# * https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg
# * https://yande.re/jpeg/0c9ec0ffcaa40470093cb44c3fd40056/yande.re%2064649%20animal_ears%20cameltoe%20fixme%20nekomimi%20nipples%20ryohka%20school_swimsuit%20see_through%20shiraishi_nagomi%20suzuya%20swimsuits%20tail%20thighhighs.jpg
# * https://konachan.com/jpeg/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20banishment%20bicycle%20grass%20group%20male%20night%20original%20rooftop%20scenic%20signed%20stars%20tree.jpg
#
# Sample images (full size is .png or .jpg):
#
# * https://yande.re/sample/ceb6a12e87945413a95b90fada406f91/.jpg
# * https://files.yande.re/sample/0d79447ce2c89138146f64ba93633568/yande.re%20290757%20sample%20seifuku%20thighhighs%20tsukudani_norio.jpg
# * https://konachan.com/sample/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20sample.jpg
#
# Preview images:
#
# * https://assets.yande.re/data/preview/7e/cf/7ecfdead705d7b956b26b1d37b98d089.jpg
# * https://konachan.com/data/preview/5d/63/5d633771614e4bf5c17df19a0f0f333f.jpg
#
# Post pages:
#
# * https://yande.re/post/show/3
# * https://konachan.com/post/show/270803/banishment-bicycle-grass-group-male-night-original

module Sources
  module Strategies
    class Moebooru < Base
      BASE_URL = %r{\Ahttps?://(?:[^.]+\.)?(?<domain>yande\.re|konachan\.com)}i
      POST_URL = %r{#{BASE_URL}/post/show/(?<id>\d+)}i
      URL_SLUG = %r{/(?:yande\.re%20|Konachan\.com%20-%20)?(?<id>\d+)?.*}i
      IMAGE_URL = %r{#{BASE_URL}/(?<type>image|jpeg|sample)/(?<md5>\h{32})#{URL_SLUG}?\.(?<ext>jpg|jpeg|png|gif)\z}i

      delegate :artist_name, :profile_url, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_strategy, allow_nil: true

      def domains
        ["yande.re", "konachan.com"]
      end

      def site_name
        urls.map { |url| url[BASE_URL, :domain] }.compact.first
      end

      def image_url
        # try to include the post_id so that it's saved for posterity in the canonical_url.
        if post_md5.present? && file_ext.present? && post_id.present?
          "https://#{file_host}/image/#{post_md5}/#{filename_prefix}#{post_id}.#{file_ext}"
        elsif post_md5.present? && file_ext.present?
          "https://#{file_host}/image/#{post_md5}.#{file_ext}"
        else
          url
        end
      end

      def image_urls
        [image_url]
      end

      def preview_urls
        return image_urls if post_md5.blank?
        ["https://#{file_host}/data/preview/#{post_md5[0..1]}/#{post_md5[2..3]}/#{post_md5}.jpg"]
      end

      def page_url
        return nil if post_id.blank?
        "https://#{site_name}/post/show/#{post_id}"
      end

      def canonical_url
        image_url
      end

      def normalize_for_source
        id = post_id_from_url
        md5 = post_md5_from_url

        if id.present?
          "https://#{site_name}/post/show/#{id}"
        elsif md5.present?
          "https://#{site_name}/post?tags=md5:#{md5}"
        end
      end

      def tags
        api_response[:tags].to_s.split.map do |tag|
          [tag, "https://#{site_name}/post?tags=#{CGI.escape(tag)}"]
        end
      end

      # XXX the base strategy excludes artist tags from the translated tags; we don't want that for moebooru.
      def translated_tags
        tags.map(&:first).flat_map(&method(:translate_tag)).uniq.sort
      end

      def headers
        { "Referer" => "http://#{site_name}" }
      end

      # Moebooru returns an empty array when doing an md5:<hash> search for a
      # deleted post. Because of this, api_response may be empty in some cases.
      def api_response
        if post_id_from_url.present?
          params = { tags: "id:#{post_id_from_url}" }
        elsif post_md5_from_url.present?
          params = { tags: "md5:#{post_md5_from_url}" }
        else
          return {}
        end

        response = http.cache(1.minute).get("https://#{site_name}/post.json", params: params)
        post = response.parse.first&.with_indifferent_access
        post || {}
      end
      memoize :api_response

      concerning :HelperMethods do
        def sub_strategy
          @sub_strategy ||= Sources::Strategies.find(api_response[:source], default: nil)
        end

        def file_host
          case site_name
          when "yande.re" then "files.yande.re"
          when "konachan.com" then "konachan.com"
          end
        end

        def filename_prefix
          case site_name
          when "yande.re" then "yande.re%20"
          when "konachan.com" then "Konachan.com%20-%20"
          end
        end

        def file_ext
          if url[IMAGE_URL, :type] == "jpeg"
            "png"

          elsif url[IMAGE_URL, :type] == "image"
            url[IMAGE_URL, :ext]

          # file_ext is not present in konachan's api (only on yande.re)
          elsif api_response[:file_ext].present?
            api_response[:file_ext]

          # file_url is not present in yande.re's api on deleted posts
          elsif api_response[:file_url].present?
            api_response[:file_url][/\.(jpg|jpeg|png|gif)\z/i, 1]

          # the api_response wasn't available because it's a deleted post.
          elsif post_md5.present?
            %w[jpg png gif].find { |ext| http_exists?("https://#{site_name}/image/#{post_md5}.#{ext}") }

          else
            nil
          end
        end

        def post_id_from_url
          urls.map { |url| url[POST_URL, :id] || url[IMAGE_URL, :id] }.compact.first
        end

        def post_md5_from_url
          urls.map { |url| url[IMAGE_URL, :md5] }.compact.first
        end

        def post_id
          post_id_from_url || api_response[:id]
        end

        def post_md5
          post_md5_from_url || api_response[:md5]
        end
      end
    end
  end
end
