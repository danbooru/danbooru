module Sources::Strategies
  class Pawoo < Base
    IMAGE = %r!\Ahttps?://img\.pawoo\.net/media_attachments/files/(\d+/\d+/\d+)!

    def self.match?(*urls)
      urls.compact.any? do |x| 
        x =~ IMAGE || PawooApiClient::Status.is_match?(x) || PawooApiClient::Account.is_match?(x)
      end
    end

    def site_name
      "Pawoo"
    end

    def image_url
      image_urls.first
    end

    # https://img.pawoo.net/media_attachments/files/001/297/997/small/c4272a09570757c2.png
    # https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png
    # https://pawoo.net/media/lU2uV7C1MMQSb1czwvg
    def image_urls
      if url =~ %r!#{IMAGE}/small/([a-z0-9]+\.\w+)\z!i
        return ["https://img.pawoo.net/media_attachments/files/#{$1}/original/#{$2}"]
      end

      if url =~ %r!#{IMAGE}/original/([a-z0-9]+\.\w+)\z!i
        return [url]
      end

      return api_response.image_urls
    end

    # https://pawoo.net/@evazion/19451018
    # https://pawoo.net/web/statuses/19451018
    def page_url
      [url, referer_url].each do |x|
        if PawooApiClient::Status.is_match?(x)
          return x
        end
      end

      return super
    end

    # https://pawoo.net/@evazion
    # https://pawoo.net/web/accounts/47806
    def profile_url
      if url =~ PawooApiClient::PROFILE2
        return "https://pawoo.net/@#{$1}"
      end

      api_response.profile_url
    end

    def artist_name
      api_response.account_name
    end

    def artist_commentary_title
      nil
    end

    def artist_commentary_desc
      api_response.commentary
    end

    def tags
      api_response.tags
    end

    def normalizable_for_artist_finder?
      true
    end

    def normalize_for_artist_finder
      profile_url
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

  public

    def api_response
      [url, referer_url].each do |x|
        if client = PawooApiClient.new.get(x)
          return client
        end
      end

      nil
    end
    memoize :api_response
  end
end
