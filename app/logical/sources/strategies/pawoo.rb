module Sources::Strategies
  class Pawoo < Base
    attr_reader :image_urls

    def self.url_match?(url)
      PawooApiClient::Status.is_match?(url)
    end

    def referer_url
      @url
    end

    def site_name
      "Pawoo"
    end

    def get
      response = PawooApiClient.new.get_status(url)
      @artist_name = response.account_name
      @profile_url = response.account_profile_url
      @image_url = response.image_urls.first
      @image_urls = response.image_urls
    end

    def normalizable_for_artist_finder?
      true
    end
  end
end
