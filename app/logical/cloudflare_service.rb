# donmai.us specific

class CloudflareService
  def enabled?
    api_token.present? && zone.present?
  end

  def api_token
    Danbooru.config.cloudflare_api_token
  end

  def zone
    Danbooru.config.cloudflare_zone
  end

  def options
    Danbooru.config.httparty_options.deep_merge(headers: {
      "Authorization" => "Bearer #{api_token}",
      "Content-Type" => "application/json",
      "User-Agent" => "#{Danbooru.config.app_name}/#{Rails.application.config.x.git_hash}"
    })
  end

  def ips(expiry: 24.hours)
    text, code = HttpartyCache.get("https://api.cloudflare.com/client/v4/ips", expiry: expiry)
    return [] if code != 200

    json = JSON.parse(text, symbolize_names: true)
    ips = json[:result][:ipv4_cidrs] + json[:result][:ipv6_cidrs]
    ips.map { |ip| IPAddr.new(ip) }
  end

  def delete(md5, ext)
    return unless enabled?

    url = "https://api.cloudflare.com/client/v4/zones/#{zone}/purge_cache"
    files = ["#{md5}.#{ext}", "preview/#{md5}.jpg", "sample/sample-#{md5}.jpg"].map do |name|
      ["danbooru", "safebooru", "raikou1", "raikou2", "raikou3", "raikou4"].map do |subdomain|
        "http://#{subdomain}.donmai.us/data/#{name}"
      end
    end.flatten
    body = {
      "files" => files
    }.to_json

    HTTParty.delete(url, options.merge(body: body)) #, body: body)
  end
end
