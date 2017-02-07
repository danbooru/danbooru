module Sources::Strategies
  class ArtStation < Base
    attr_reader :json, :image_urls

    def self.url_match?(url)
      url =~ %r!^https?://\w+\.artstation\.com/artwork/[a-z0-9]+!i
    end

    def referer_url
      if @referer_url =~ %r!^https?://\w+\.artstation\.com/artwork/[a-z0-9]+!i
        @referer_url
      else
        @url
      end
    end

    def site_name
      "ArtStation"
    end

    def api_url
      url.sub(%r!^https?://\w+\.!, "https://www.").sub(%r!/artwork/!, "/projects/") + ".json"
    end

    def image_url
      image_urls.first
    end

    def get
      uri = URI.parse(api_url)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.is_a?(URI::HTTPS)) do |http|
        resp = http.request_get(uri.request_uri)
        image_url_rewriter = Downloads::RewriteStrategies::ArtStation.new
        if resp.is_a?(Net::HTTPSuccess)
          @json = JSON.parse(resp.body)
          @artist_name = json["user"]["username"]
          @profile_url = json["user"]["permalink"]
          @image_urls = json["assets"].map do |x| 
            y, _, _ = image_url_rewriter.rewrite(x["image_url"], nil)
            y
          end
          @tags = json["tags"].map {|x| [x.downcase.tr(" ", "_"), "https://www.artstation.com/search?q=" + CGI.escape(x)]} if json["tags"]
          @artist_commentary_title = json["title"]
          @artist_commentary_desc = ActionView::Base.full_sanitizer.sanitize(json["description"])
        else
          raise "HTTP error code: #{resp.code} #{resp.message}"
        end
      end
    end
  end
end
