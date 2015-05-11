class PixivApiClient
  CLIENT_ID = "bYGKuGVw91e0NMfPGp44euvGt59s"
  CLIENT_SECRET = "HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK"

  def works(illust_id)
    headers = {
      "Referer" => "http://www.pixiv.net",
      "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}",
      "Content-Type" => "application/x-www-form-urlencoded",
      "Authorization" => "Bearer #{access_token}"
    }
    params = {
      "image_sizes" => "large",
      "include_stats" => "true"
    }
    url = URI.parse("https://public-api.secure.pixiv.net/v1/works/#{illust_id.to_i}.json")
    url.query = URI.encode_www_form(params)
    json = nil

    Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
      resp = http.request_get(url.request_uri, headers)
      if resp.is_a?(Net::HTTPSuccess)
        json = JSON.parse(resp.body)
      end
    end

    map(json)
  end

private

  def map(raw_json)
    {
      :moniker => raw_json["response"][0]["user"]["account"],
      :file_ext => File.extname(raw_json["response"][0]["image_urls"]["large"]),
      :page_count => raw_json["response"][0]["page_count"]
    }
  end

	def access_token
    Cache.get("pixiv-papi-access-token", 3000) do
      access_token = nil
      headers = {
        "Referer" => "http://www.pixiv.net"
      }
      params = {
        "username" => Danbooru.config.pixiv_login,
        "password" => Danbooru.config.pixiv_password,
        "grant_type" => "password",
        "client_id" => CLIENT_ID,
        "client_secret" => CLIENT_SECRET
      }
      url = URI.parse("https://oauth.secure.pixiv.net/auth/token")

      Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
        resp = http.request_post(url.request_uri, URI.encode_www_form(params), headers)

        if resp.is_a?(Net::HTTPSuccess)
          json = JSON.parse(resp.body)
          access_token = json["response"]["access_token"]
        end
      end

      access_token
    end
  end
end