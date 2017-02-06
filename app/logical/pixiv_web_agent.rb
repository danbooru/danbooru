class PixivWebAgent
  SESSION_CACHE_KEY = "pixiv-phpsessid"
  COMIC_SESSION_CACHE_KEY = "pixiv-comicsessid"
  SESSION_COOKIE_KEY = "PHPSESSID"
  COMIC_SESSION_COOKIE_KEY = "_pixiv-comic_session"

  def self.phpsessid(agent)
    agent.cookies.select do |cookie| cookie.name == SESSION_COOKIE_KEY end.first.try(:value)
  end

  def self.build
    mech = Mechanize.new
    mech.keep_alive = false

    phpsessid = Cache.get(SESSION_CACHE_KEY)
    comicsessid = Cache.get(COMIC_SESSION_CACHE_KEY)

    if phpsessid
      cookie = Mechanize::Cookie.new(SESSION_COOKIE_KEY, phpsessid)
      cookie.domain = ".pixiv.net"
      cookie.path = "/"
      mech.cookie_jar.add(cookie)

      if comicsessid
        cookie = Mechanize::Cookie.new(COMIC_SESSION_COOKIE_KEY, comicsessid)
        cookie.domain = ".pixiv.net"
        cookie.path = "/"
        mech.cookie_jar.add(cookie)
      end
    else
      headers = {
        "Origin" => "https://accounts.pixiv.net",
        "Referer" => "https://accounts.pixiv.net/login?lang=en^source=pc&view_type=page&ref=wwwtop_accounts_index"
      }

      params = {
        pixiv_id: Danbooru.config.pixiv_login,
        password: Danbooru.config.pixiv_password,
        captcha: nil,
        g_captcha_response: nil,
        source: "pc",
        post_key: nil
      }

      mech.get("https://accounts.pixiv.net/login?lang=en&source=pc&view_type=page&ref=wwwtop_accounts_index") do |page|
        json = page.search("input#init-config").first.attr("value")
        if json =~ /pixivAccount\.postKey":"([a-f0-9]+)/
          params[:post_key] = $1
        end
      end

      mech.post("https://accounts.pixiv.net/api/login?lang=en", params, headers)
      if mech.current_page.body =~ /"error":false/
        cookie = mech.cookies.select {|x| x.name == SESSION_COOKIE_KEY}.first
        if cookie
          Cache.put(SESSION_CACHE_KEY, cookie.value, 1.month)
        end
      end

      begin
        mech.get("https://comic.pixiv.net") do |page|
          cookie = mech.cookies.select {|x| x.name == COMIC_SESSION_COOKIE_KEY}.first
          if cookie
            Cache.put(COMIC_SESSION_CACHE_KEY, cookie.value, 1.month)
          end
        end
      rescue Net::HTTPServiceUnavailable
        # ignore
      end
    end

    mech
  end
end
