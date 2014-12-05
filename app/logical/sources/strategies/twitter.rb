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
      agent.get(url) do |page|
        @artist_name, @profile_url = get_profile_from_page(page)
        @image_url = get_image_url_from_page(page)
      end
    end

    def get_profile_from_page(page)
      links = page.search("a.profile-link")
      if links.any?
        profile_url = "https://twitter.com" + links[0]["href"]
        artist_name = links[0].search("span")[0].text
      else
        profile_url = nil
        artist_name = nil
      end

      return [artist_name, profile_url].compact
    end

    def get_image_url_from_page(page)
      divs = page.search("div.media")

      if divs.any?
        image_url = divs.search("img")[0]["src"] + ":large"
      else
        image_url = nil
      end

      return image_url
    end

    private

    def agent
      @agent ||= Mechanize.new
    end
  end
end
