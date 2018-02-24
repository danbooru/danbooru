module Sources::Strategies
  class Tumblr < Base
    extend Memoist

    def self.url_match?(url)
      blog_name, post_id = parse_info_from_url(url)
      blog_name.present? && post_id.present?
    end

    def referer_url
      blog_name, post_id = self.class.parse_info_from_url(normalized_url)
      "https://#{blog_name}.tumblr.com/post/#{post_id}"
    end

    def tags
      post[:tags].map do |tag|
        # normalize tags: space, underscore, and hyphen are equivalent in tumblr tags.
        [tag.tr(" _-", "_"), "https://tumblr.com/tagged/#{CGI::escape(tag.tr(" _-", "-"))}"]
      end.uniq
    end

    def site_name
      "Tumblr"
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
        post[:question]
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

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc).strip
    end

    def image_url
      image_urls.first
    end

    def image_urls
      urls = case post[:type]
      when "photo"
        post[:photos].map do |photo|
          self.class.normalize_image_url(photo[:original_size][:url])
        end
      when "video"
        [post[:video_url]]
      else
        []
      end

      urls += self.class.parse_inline_images(artist_commentary_desc)
      urls
    end

    def get
    end

    module HelperMethods
      extend ActiveSupport::Concern

      module ClassMethods
        def parse_info_from_url(url)
          url =~ %r!\Ahttps?://(?<blog_name>[^.]+)\.tumblr\.com/(?:post|image)/(?<post_id>\d+)!i
          [$1, $2]
        end

        def parse_inline_images(text)
          html = Nokogiri::HTML.fragment(text)
          image_urls = html.css("img").map { |node| node["src"] }
          image_urls = image_urls.map(&method(:normalize_image_url))
          image_urls
        end

        def normalize_image_url(url)
          url, _, _ = Downloads::RewriteStrategies::Tumblr.new.rewrite(url, {})
          url
        end
      end

      def normalized_url
        if self.class.url_match?(@referer_url)
          @referer_url
        elsif self.class.url_match?(@url)
          @url
        end
      end
    end

    module ApiMethods
      def client
        raise NotImplementedError.new("Tumblr support is not available (API key not configured).") if Danbooru.config.tumblr_consumer_key.nil?
        ::TumblrApiClient.new(Danbooru.config.tumblr_consumer_key)
      end

      def api_response
        blog_name, post_id = self.class.parse_info_from_url(normalized_url)
        client.posts(blog_name, post_id)
      end

      def post
        api_response[:posts].first
      end
    end

    include ApiMethods
    include HelperMethods

    memoize :client, :api_response
  end
end
