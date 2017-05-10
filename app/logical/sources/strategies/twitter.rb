module Sources::Strategies
  class Twitter < Base
    def self.url_match?(url)
      url =~ %r!https?://(?:mobile\.)?twitter\.com/\w+/status/\d+! || url =~ %r{https?://pbs\.twimg\.com/media/}
    end

    def referer_url
      if @referer_url =~ %r!https?://(?:mobile\.)?twitter\.com/\w+/status/\d+! && @url =~ %r{https?://pbs\.twimg\.com/media/}
        @referer_url
      else
        @url
      end
    end

    def tags
      []
    end

    def site_name
      "Twitter"
    end

    def get
      status_id = status_id_from_url(url)
      attrs = TwitterService.new.client.status(status_id).attrs
      @artist_name = attrs[:user][:name]
      @profile_url = "https://twitter.com/" + attrs[:user][:screen_name]
      @image_url = image_urls.first
      @artist_commentary_title = ""
      @artist_commentary_desc = attrs[:text]
    end

    def image_urls
      TwitterService.new.image_urls(url)
    end

    def normalize_for_artist_finder!
      url.downcase
    end

    def normalizable_for_artist_finder?
      true
    end

    def status_id_from_url(url)
      if url =~ %r{^https?://(?:mobile\.)?twitter\.com/\w+/status/(\d+)}
        $1.to_i
      else
        raise Sources::Error.new("Couldn't get status ID from URL: #{url}")
      end
    end
  end
end
