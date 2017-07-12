module Sources::Strategies
  class ArtStation < Base
    attr_reader :json, :image_urls

    def self.url_match?(url)
      self.project_id(url).present?
    end

    # https://www.artstation.com/artwork/04XA4"
    # https://dantewontdie.artstation.com/projects/YZK5q"
    # https://www.artstation.com/artwork/cody-from-sf"
    def self.project_id(url)
      if url =~ %r!\Ahttps?://\w+\.artstation\.com/(?:artwork|projects)/(?<project_id>[a-z0-9-]+)\z!i
        $~[:project_id]
      else
        nil
      end
    end

    def referer_url
      if self.class.url_match?(@referer_url)
        @referer_url
      else
        @url
      end
    end

    def site_name
      "ArtStation"
    end

    def project_id
      self.class.project_id(referer_url)
    end

    def page_url
      "https://www.artstation.com/artwork/#{project_id}"
    end

    def api_url
      "https://www.artstation.com/projects/#{project_id}.json"
    end

    def image_url
      image_urls.first
    end

    def get
      resp = HTTParty.get(api_url, Danbooru.config.httparty_options)
      image_url_rewriter = Downloads::RewriteStrategies::ArtStation.new
      if resp.success?
        @json = JSON.parse(resp.body)
        @artist_name = json["user"]["username"]
        @profile_url = json["user"]["permalink"]
        images = json["assets"].select { |asset| asset["asset_type"] == "image" }
        @image_urls = images.map do |x|
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
