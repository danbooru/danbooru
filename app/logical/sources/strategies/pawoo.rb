# Image URLS:
# * https://img.pawoo.net/media_attachments/files/001/297/997/small/c4272a09570757c2.png
# * https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png
# * https://pawoo.net/media/lU2uV7C1MMQSb1czwvg
#
# Page URLS:
# * https://pawoo.net/@evazion/19451018
# * https://pawoo.net/web/statuses/19451018
#
# Account URLS:
# * https://pawoo.net/@evazion
# * https://pawoo.net/web/accounts/47806
#
# OAUTH URLS: (NOTE: ID IS DIFFERENT FROM ACCOUNT URL ID)
# * https://pawoo.net/oauth_authentications/17230064

module Sources::Strategies
  class Pawoo < Base
    HOST = %r{\Ahttps?://(www\.)?pawoo\.net}i
    IMAGE = %r{\Ahttps?://img\.pawoo\.net/media_attachments/files/(\d+/\d+/\d+)}
    NAMED_PROFILE = %r{#{HOST}/@(?<artist_name>\w+)}i
    ID_PROFILE = %r{#{HOST}/web/accounts/(?<artist_id>\d+)}

    STATUS1 = %r{\A#{HOST}/web/statuses/(?<status_id>\d+)}
    STATUS2 = %r{\A#{NAMED_PROFILE}/(?<status_id>\d+)}

    def self.enabled?
      Danbooru.config.pawoo_client_id.present? && Danbooru.config.pawoo_client_secret.present?
    end

    def domains
      ["pawoo.net"]
    end

    def site_name
      "Pawoo"
    end

    def image_url
      image_urls.first
    end

    def image_urls
      if url =~ %r{#{IMAGE}/small/([a-z0-9]+\.\w+)\z}i
        ["https://img.pawoo.net/media_attachments/files/#{$1}/original/#{$2}"]
      elsif url =~ %r{#{IMAGE}/original/([a-z0-9]+\.\w+)\z}i
        [url]
      else
        api_response.image_urls
      end
    end

    def page_url
      [url, referer_url].each do |x|
        if PawooApiClient::Status.is_match?(x)
          return x
        end
      end

      super
    end

    def profile_url
      if url =~ PawooApiClient::PROFILE2
        "https://pawoo.net/@#{$1}"
      elsif api_response.profile_url.blank?
        url
      else
        api_response.profile_url
      end
    end

    def artist_name
      api_response.account_name
    end

    def artist_name_from_url
      if url =~ NAMED_PROFILE
        url[NAMED_PROFILE, :artist_name]
      end
    end

    def artist_id_from_url
      if url =~ ID_PROFILE
        url[ID_PROFILE, :artist_name]
      end
    end

    def status_id_from_url
      urls.map { |url| url[STATUS1, :status_id] || url[STATUS2, :status_id] }.compact.first
    end

    def artist_commentary_desc
      api_response.commentary
    end

    def tags
      api_response.tags
    end

    def normalize_for_source
      artist_name = artist_name_from_url
      status_id = status_id_from_url
      return if status_id.blank?

      if artist_name.present?
        "https://pawoo.net/@#{artist_name}/#{status_id}"
      else
        "https://pawoo.net/web/statuses/#{status_id}"
      end
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

    def api_response
      [url, referer_url].each do |x|
        if (client = PawooApiClient.new.get(x))
          return client
        end
      end

      nil
    end
    memoize :api_response
  end
end
