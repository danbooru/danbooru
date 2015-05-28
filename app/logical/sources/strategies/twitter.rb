module Sources::Strategies
  class Twitter < Base
    def self.url_match?(url)
      url =~ %r!https?://(?:mobile\.)?twitter\.com/\w+/status/\d+!
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
      @image_url = attrs[:entities][:media][0][:media_url] + ":orig"
    end

    def image_urls
      TwitterService.new.image_urls(url)
    end

    def status_id_from_url(url)
      if url =~ %r{^https?://twitter\.com/[^/]+/status/(\d+)}
        $1
      else
        raise Sources::Error.new("Couldn't get status ID from URL: #{url}")
      end
    end
  end
end
