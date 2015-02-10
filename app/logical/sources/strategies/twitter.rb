module Sources::Strategies
  class Twitter < Base
    def self.url_match?(url)
      url =~ %r!https?://mobile\.twitter\.com/\w+/status/\d+!
    end

    def tags
      []
    end

    def site_name
      "Twitter"
    end

    def get
      attrs = TwitterService.new.client.status(url).attrs
      @artist_name = attrs[:user][:name]
      @profile_url = "https://twitter.com/" + attrs[:user][:screen_name]
      @image_url = attrs[:entities][:media][0][:media_url] + ":large"
    end
  end
end
