# frozen_string_literal: true

# A simple Cloudflare API client for purging cached images after they're
# regenerated or deleted.
class CloudflareService
  attr_reader :api_token, :zone

  def initialize(api_token: Danbooru.config.cloudflare_api_token, zone: Danbooru.config.cloudflare_zone)
    @api_token, @zone = api_token, zone
  end

  def enabled?
    api_token.present? && zone.present?
  end

  # Purge a list of URLs from Cloudflare's cache.
  # @param urls [Array<String>] the list of URLs to purge
  # @see https://api.cloudflare.com/#zone-purge-files-by-url
  def purge_cache(urls)
    return unless enabled?

    cloudflare = Danbooru::Http.external.headers(
      "Authorization" => "Bearer #{api_token}",
      "Content-Type" => "application/json"
    )

    url = "https://api.cloudflare.com/client/v4/zones/#{zone}/purge_cache"
    cloudflare.delete(url, json: { files: urls })
  end
end
