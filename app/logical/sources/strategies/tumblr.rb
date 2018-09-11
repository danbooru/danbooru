module Sources::Strategies
  class Tumblr < Base
    DOMAIN = %r{(data|(\d+\.)?media)\.tumblr\.com}
    MD5 = %r{(?<md5>[0-9a-f]{32})}i
    FILENAME = %r{(?<filename>(tumblr_(inline_)?)?[a-z0-9]+(_r[0-9]+)?)}i
    SIZES = %r{(?:250|400|500|500h|540|1280|raw)}i
    EXT = %r{(?<ext>\w+)}
    IMAGE = %r!\Ahttps?://#{DOMAIN}/(?<dir>#{MD5}/)?#{FILENAME}_#{SIZES}\.#{EXT}\z!i
    POST = %r!\Ahttps?://(?<blog_name>[^.]+)\.tumblr\.com/(?:post|image)/(?<post_id>\d+)!i

    def self.match?(*urls)
      urls.compact.any? do |url|
        blog_name, post_id = parse_info_from_url(url)
        url =~ IMAGE || blog_name.present? && post_id.present?
      end
    end

    def self.parse_info_from_url(url)
      if url =~ POST
        [$~[:blog_name], $~[:post_id]]
      else
        []
      end
    end

    def site_name
      "Tumblr"
    end

    def image_urls
      image_urls_sub
        .uniq
        .map {|x| normalize_cdn(x)}
        .map {|x| find_largest(x)}
        .compact
        .uniq
    end

    def preview_urls
      image_urls.map do |x|
        x.sub(%r!_1280\.(jpg|png|gif|jpeg)\z!, '_250.\1')
      end
    end

    def page_url
      [url, referer_url].each do |x|
        if x =~ POST
          blog_name, post_id = self.class.parse_info_from_url(x)
          return "https://#{blog_name}.tumblr.com/post/#{post_id}"
        end
      end

      return super
    end

    def profile_url
      "https://#{artist_name}.tumblr.com/"
    end

    def artist_name
      post[:blog_name]
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
      post[:tags].map do |tag|
        # normalize tags: space, underscore, and hyphen are equivalent in tumblr tags.
        etag = tag.gsub(/[ _-]/, "_")
        [etag, "https://tumblr.com/tagged/#{CGI.escape(etag)}"]
      end.uniq
    end
    memoize :tags

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc).strip
    end

  public

    def image_urls_sub
      list = []

      if url =~ IMAGE
        list << url
      end

      if page_url !~ POST
        return list
      end

      if post[:type] == "photo"
        list += post[:photos].map do |photo|
          photo[:original_size][:url]
        end
      end

      if post[:type] == "video"
        list << post[:video_url]
      end

      if inline_images.any?
        list += inline_images.to_a
      end

      if list.any?
        return list
      end

      raise "image url not found for (#{url}, #{referer_url})"
    end

    # Normalize cdn subdomains.
    #
    # https://gs1.wac.edgecastcdn.net/8019B6/data.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
    # => http://data.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
    def normalize_cdn(x)
      # does this work?
      x.sub(%r!\Ahttps?://gs1\.wac\.edgecastcdn\.net/8019B6/media\.tumblr\.com!i, "http://media.tumblr.com")
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
    def find_largest(x)
      if x =~ IMAGE
        sizes = [1280, 640, 540, "500h", 500, 400, 250]
        candidates = sizes.map do |size|
          "https://media.tumblr.com/#{$~[:dir]}#{$~[:filename]}_#{size}.#{$~[:ext]}"
        end

        return candidates.find do |candidate|
          http_exists?(candidate, headers)
        end
      end

      return x
    end

    def inline_images
      html = Nokogiri::HTML.fragment(artist_commentary_desc)
      html.css("img").map { |node| node["src"] }
    end
    memoize :inline_images

    def client
      raise NotImplementedError.new("Tumblr support is not available (API key not configured).") if Danbooru.config.tumblr_consumer_key.nil?

      TumblrApiClient.new(Danbooru.config.tumblr_consumer_key)
    end
    memoize :client

    def api_response
      blog_name, post_id = self.class.parse_info_from_url(page_url)

      raise "Page url not found for (#{url}, #{referer_url})" if blog_name.nil?

      client.posts(blog_name, post_id)
    end
    memoize :api_response

    def post
      api_response[:posts].first
    end
  end
end
