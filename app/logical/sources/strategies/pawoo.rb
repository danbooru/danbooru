# html page urls:
#   https://pawoo.net/@evazion/19451018
#   https://pawoo.net/web/statuses/19451018
#
# image urls:
#   https://img.pawoo.net/media_attachments/files/001/297/997/small/c4272a09570757c2.png
#   https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png
#   https://pawoo.net/media/lU2uV7C1MMQSb1czwvg
#
# artist urls:
#   https://pawoo.net/@evazion
#   https://pawoo.net/web/accounts/47806

module Sources::Strategies
  class Pawoo < Base
    attr_reader :image_urls

    def self.url_match?(url)
      PawooApiClient::Status.is_match?(url)
    end

    def referer_url
      normalized_url
    end

    def site_name
      "Pawoo"
    end

    def api_response
      @response ||= PawooApiClient.new.get_status(normalized_url)
    end

    def get
      response = api_response
      @artist_name = response.account_name
      @profile_url = response.account_profile_url
      @image_url = response.image_urls.first
      @image_urls = response.image_urls
      @tags = response.tags
      @artist_commentary_title = nil
      @artist_commentary_desc = response.commentary
    end

    def normalized_url
      if self.class.url_match?(@url)
        @url
      elsif self.class.url_match?(@referer_url)
        @referer_url
      end
    end

    def normalizable_for_artist_finder?
      true
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc) do |element|
        if element.name == "a"
          # don't include links to the toot itself.
          media_urls = api_response.json["media_attachments"].map { |attr| attr["text_url"] }
          element["href"] = nil if element["href"].in?(media_urls)
        end
      end.strip
    end
  end
end
