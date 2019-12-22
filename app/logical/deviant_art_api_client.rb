# https://github.com/danbooru/danbooru/issues/4144
#
# API requests must send a user agent and must use gzip compression, otherwise
# 403 errors will be returned.

DeviantArtApiClient = Struct.new(:deviation_id) do
  extend Memoist

  def extended_fetch
    params = { deviationid: deviation_id, type: "art", include_session: false }
    get("https://www.deviantart.com/_napi/da-deviation/shared_api/deviation/extended_fetch", params: params)
  end

  def extended_fetch_json
    JSON.parse(extended_fetch.body).with_indifferent_access
  end

  def download_url
    url = extended_fetch_json.dig(:deviation, :extended, :download, :url)
    response = get(url)
    response.headers[:location]
  end

  def get(url, retries: 1, **options)
    response = http.cookies(cookies).get(url, **options)

    new_cookies = response.cookies.cookies.map { |cookie| { cookie.name => cookie.value } }.reduce(&:merge)
    new_cookies = new_cookies.slice(:userinfo, :auth, :authsecure)
    if new_cookies.present?
      DanbooruLogger.info("DeviantArt: updating cookies", url: url, new_cookies: new_cookies, old_cookies: cookies)
      self.cookies = new_cookies
    end

    # If the old auth cookie expired we may get a 404 with a new auth cookie
    # set. Try again with the new cookie.
    if response.code == 404 && retries > 0
      DanbooruLogger.info("DeviantArt: retrying", url: url, cookies: cookies)
      response = get(url, retries: retries - 1, **options)
    end

    response
  end

  def cookies
    Cache.get("deviantart_cookies", 10.years.to_i) do
      JSON.parse(Danbooru.config.deviantart_cookies)
    end
  end

  def cookies=(new_cookies)
    Cache.put("deviantart_cookies", new_cookies, 10.years.to_i)
  end

  def http
    HTTP.use(:auto_inflate).headers(Danbooru.config.http_headers.merge("Accept-Encoding" => "gzip"))
  end

  memoize :extended_fetch, :extended_fetch_json, :download_url
end
