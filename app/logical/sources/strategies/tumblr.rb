module Sources::Strategies
  class Tumblr < Base
    def self.url_match?(url)
      url =~ %r{^https?://.+\.tumblr\.com/(?:\w+/)?(?:tumblr_)?(\w+_)(\d+)\..+$} || url =~ %r{^https?://[^.]+\.tumblr\.com/(?:post|image)/\d+}
    end

    def referer_url
      if @referer_url =~ %r{^https?://[^.]+\.tumblr\.com/post/\d+} && @url =~ %r{^https?://.+\.tumblr\.com/(?:\w+/)?(?:tumblr_)?(\w+_)(\d+)\..+$}
        @referer_url
      elsif @referer_url =~ %r{^https?://[^.]+\.tumblr\.com/image/\d+} && @url =~ %r{^https?://.+\.tumblr\.com/(?:\w+/)?(?:tumblr_)?(\w+_)(\d+)\..+$}
        @referer_url.sub("/image/", "/post/")
      else
        @url
      end
    end

    def tags
      []
    end

    def site_name
      "Tumblr"
    end

    def get
    end
  end
end
