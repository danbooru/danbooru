# frozen_string_literal: true

# @see Source::URL::Mastodon
module Sources::Strategies
  class Mastodon < Base
    def match?
      Source::URL::Mastodon === parsed_url
    end

    def domain
      case site_name
      when "Pawoo" then "pawoo.net"
      when "Baraag" then "baraag.net"
      end
    end

    def image_urls
      if parsed_url.image_url?
        [parsed_url.full_image_url]
      else
        api_response.image_urls
      end
    end

    def page_url
      artist_name = artist_name_from_url
      status_id = status_id_from_url
      return if status_id.blank?

      if artist_name.present?
        "https://#{domain}/@#{artist_name}/#{status_id}"
      else
        "https://#{domain}/web/statuses/#{status_id}"
      end
    end

    def profile_url
      if artist_name_from_url.present?
        "https://#{domain}/@#{artist_name_from_url}"
      elsif api_response.present? && api_response.profile_url.present?
        api_response.profile_url
      end
    end

    def account_url
      return if account_id.blank?
      "https://#{domain}/web/accounts/#{account_id}"
    end

    def profile_urls
      [profile_url, account_url].compact
    end

    def artist_name
      api_response.account_name
    end

    def artist_name_from_url
      parsed_url.username || parsed_referer&.username
    end

    def other_names
      [api_response.display_name]
    end

    def account_id
      parsed_url.user_id || parsed_referer&.user_id || api_response.account_id
    end

    def status_id_from_url
      parsed_url.work_id || parsed_referer&.work_id
    end

    def artist_commentary_desc
      api_response.commentary
    end

    def tags
      api_response.tags
    end

    def normalize_for_source
      page_url
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
      MastodonApiClient.new(domain, status_id_from_url)
    end
    memoize :api_response
  end
end
