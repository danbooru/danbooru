# donmai.us specific

class CloudflareService
  def key
    Danbooru.config.cloudflare_key
  end

  def email
    Danbooru.config.cloudflare_email
  end

  def zone
    Danbooru.config.cloudflare_zone
  end

  def options
    Danbooru.config.httparty_options.deep_merge(headers: {
      "X-Auth-Email" => email,
      "X-Auth-Key" => key,
      "Content-Type" => "application/json",
      "User-Agent" => "#{Danbooru.config.app_name}/#{Danbooru.config.version}"
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
