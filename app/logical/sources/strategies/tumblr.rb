# https://marmaladica.tumblr.com/post/188237914346/saved
# https://66.media.tumblr.com/2c6f55531618b4335c67e29157f5c1fc/tumblr_pz4a44xdVj1ssucdno1_1280.png
# https://66.media.tumblr.com/11700cab20d65d5a6acc470e284dbd3a/tumblr_pz4a44xdVj1ssucdno2_1280.png
#
# https://emlan.tumblr.com/post/189469423572/kuro-attempts-to-buy-a-racy-book-at-comiket-but
# https://66.media.tumblr.com/168dabd09d5ad69eb5fedcf94c45c31a/3dbfaec9b9e0c2e3-72/s640x960/bf33a1324f3f36d2dc64f011bfeab4867da62bc8.png
# https://66.media.tumblr.com/5a2c3fe25c977e2281392752ab971c90/3dbfaec9b9e0c2e3-92/s500x750/4f92bbaaf95c0b4e7970e62b1d2e1415859dd659.png
#
# https://superboin.tumblr.com/post/141169066579/photoset_iframe/superboin/tumblr_o45miiAOts1u6rxu8/500/false
#
# https://make-do5.tumblr.com/post/619663949657423872 (extremely high res, extractable)

module Sources::Strategies
  class Tumblr < Base
    SIZES = %w[1280 640 540 500h 500 400 250 100]

    BASE_URL = %r{\Ahttps?://(?:[^/]+\.)*tumblr\.com}i
    DOMAIN = /(data|(?:\d+\.)?media)\.tumblr\.com/i
    MD5 = /(?<md5>[0-9a-f]{32})/i
    FILENAME = /(?<filename>(?:tumblr_(?:inline_)?)?[a-z0-9]+(?:_r[0-9]+)?)/i
    EXT = /(?<ext>\w+)/

    # old: https://66.media.tumblr.com/2c6f55531618b4335c67e29157f5c1fc/tumblr_pz4a44xdVj1ssucdno1_1280.png
    # new: https://66.media.tumblr.com/168dabd09d5ad69eb5fedcf94c45c31a/3dbfaec9b9e0c2e3-72/s640x960/bf33a1324f3f36d2dc64f011bfeab4867da62bc8.png
    OLD_IMAGE = %r{\Ahttps?://#{DOMAIN}/(?<dir>#{MD5}/)?#{FILENAME}_(?<size>\w+)\.#{EXT}\z}i

    IMAGE = %r{\Ahttps?://#{DOMAIN}/}i
    VIDEO = %r{\Ahttps?://(?:vtt|ve|va\.media)\.tumblr\.com/}i
    POST = %r{\Ahttps?://(?<blog_name>[^.]+)\.tumblr\.com/(?:post|image)/(?<post_id>\d+)}i

    def self.enabled?
      Danbooru.config.tumblr_consumer_key.present?
    end

    def domains
      ["tumblr.com"]
    end

    def site_name
      "Tumblr"
    end

    def image_url
      return image_urls.first unless url.match?(IMAGE) || url.match?(VIDEO)
      find_largest(url)
    end

    def image_urls
      list = []

      case post[:type]
      when "photo"
        list += post[:photos].map do |photo|
          sizes = [photo[:original_size]] + photo[:alt_sizes]
          biggest = sizes.max_by { |x| x[:width] * x[:height] }
          biggest[:url]
        end

      when "video"
        list += [post[:video_url]]

      # api response is blank (work is deleted or we were given a direct image with no referer url)
      when nil
        list += [url] if url.match?(IMAGE) || url.match?(VIDEO)
      end

      list += inline_images
      list.map { |url| find_largest(url) }
    end

    def preview_urls
      image_urls.map do |x|
        x.sub(/_1280\.(jpg|png|gif|jpeg)\z/, '_250.\1')
      end
    end

    def page_url
      return nil unless blog_name.present? && post_id.present?
      "https://#{blog_name}.tumblr.com/post/#{post_id}"
    end

    def canonical_url
      page_url
    end

    def profile_url
      return nil if artist_name.blank?
      "https://#{artist_name}.tumblr.com"
    end

    def artist_name
      post[:blog_name] || blog_name
    end

    def artist_commentary_title
      case post[:type]
      when "text", "link"
        post[:title]

      when "answer"
        "#{post[:asking_name]} asked: #{post[:question]}"

      else
        nil
      end
    end

    def artist_commentary_desc
      case post[:type]
      when "text"
        post[:body]

      when "link"
        post[:description]

      when "photo", "video"
        post[:caption]

      when "answer"
        post[:answer]

      else
        nil
      end
    end

    def tags
      post[:tags].to_a.map do |tag|
        [tag, "https://tumblr.com/tagged/#{CGI.escape(tag)}"]
      end.uniq
    end

    def normalize_tag(tag)
      tag = tag.tr("-", "_")
      super(tag)
    end

    def normalize_for_source
      return unless blog_name.present? && post_id.present?

      "https://#{blog_name}.tumblr.com/post/#{post_id}"
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc).strip
    end

    # Look for the biggest available version on media.tumblr.com. A bigger
    # version may or may not exist.
    #
    # https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg
    # => https://media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_raw.jpg
    #
    # https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif
    # => https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_500.gif
    #
    # https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
    # => https://media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png
    #
    # http://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_400.jpg
    # => https://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_500.jpg
    #
    # http://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg
    # => https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg
    def find_largest(url, sizes: SIZES)
      if url =~ OLD_IMAGE
        candidates = sizes.map do |size|
          "https://media.tumblr.com/#{$~[:dir]}#{$~[:filename]}_#{size}.#{$~[:ext]}"
        end

        candidates.find do |candidate|
          http_exists?(candidate)
        end
      elsif url =~ %r{/s\d+x\d+/(\w+\.\w+)\z}i
        max_size = Integer.sqrt(Danbooru.config.max_image_resolution)
        url = url.gsub(%r{/s\d+x\d+/\w+\.\w+\z}i, "/s#{max_size}x#{max_size}/#{$1}")

        resp = http.cache(1.minute).headers(accept: "text/html").get(url).parse
        resp.at("img[src*='/s#{max_size}x#{max_size}/']")["src"]
      else
        url
      end
    end

    def inline_images
      html = Nokogiri::HTML.fragment(artist_commentary_desc)
      html.css("img").map { |node| node["src"] }
    end

    def blog_name
      urls.map { |url| url[POST, :blog_name] }.compact.first
    end

    def post_id
      urls.map { |url| url[POST, :post_id] }.compact.first
    end

    def api_response
      return {} unless self.class.enabled?
      return {} unless blog_name.present? && post_id.present?

      response = http.cache(1.minute).get(
        "https://api.tumblr.com/v2/blog/#{blog_name}/posts",
        params: { id: post_id, api_key: Danbooru.config.tumblr_consumer_key }
      )

      return {} if response.code != 200
      response.parse.with_indifferent_access
    end
    memoize :api_response

    def post
      api_response.dig(:response, :posts)&.first || {}
    end
  end
end
