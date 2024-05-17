# frozen_string_literal: true

# @see Source::URL::Mastodon
# @see https://docs.joinmastodon.org/api
class Source::Extractor
  class Mastodon < Source::Extractor
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
        api_response.dig("media_attachments").to_a.pluck("url")
      end
    end

    def page_url
      if username.present? && status_id.present?
        "https://#{domain}/@#{username}/#{status_id}"
      elsif status_id.present?
        "https://#{domain}/web/statuses/#{status_id}"
      end
    end

    def profile_url
      if username.present?
        "https://#{domain}/@#{username}"
      else
        api_response.dig("account", "url")
      end
    end

    def account_url
      "https://#{domain}/web/accounts/#{account_id}" if account_id.present?
    end

    def profile_urls
      [profile_url, account_url].compact
    end

    def username
      api_response.dig("account", "username") || parsed_url.username || parsed_referer&.username
    end

    def display_name
      api_response.dig("account", "display_name").presence
    end

    def account_id
      parsed_url.user_id || parsed_referer&.user_id || api_response.dig("account", "id")
    end

    def status_id
      parsed_url.work_id || parsed_referer&.work_id
    end

    def artist_commentary_desc
      commentary = "".dup
      commentary << "<p>#{api_response["spoiler_text"]}</p>" if api_response["spoiler_text"].present?
      commentary << api_response["content"] if api_response["content"].present?
      commentary
    end

    def tags
      api_response.dig("tags").to_a.map do |tag|
        [tag["name"], tag["url"]]
      end
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc, base_url: "https://#{domain}") do |element|
        if element.name == "a"
          # don't include links to the toot itself.
          media_urls = api_response.dig("media_attachments").pluck("text_url")
          element.content = nil if element["href"].in?(media_urls)
        end
      end.strip
    end

    def status_api_url
      "https://#{domain}/api/v1/statuses/#{status_id}" if status_id.present?
    end

    memoize def api_response
      http.cache(1.minute).parsed_get(status_api_url) || {}
    end

    def http
      super.headers(Authorization: "Bearer #{access_token}")
    end

    def access_token
      case site_name
      when "Pawoo" then Danbooru.config.pawoo_access_token
      when "Baraag" then Danbooru.config.baraag_access_token
      end
    end
  end
end
