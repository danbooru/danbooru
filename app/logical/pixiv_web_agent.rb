class PixivWebAgent
  def self.phpsessid(agent)
    agent.cookies.select do |cookie| cookie.name == "PHPSESSID" end.first.try(:value)
  end

  def self.build
    mech = Mechanize.new
    phpsessid = Cache.get("pixiv-phpsessid")

    if phpsessid
      cookie = Mechanize::Cookie.new("PHPSESSID", phpsessid)
      cookie.domain = ".pixiv.net"
      cookie.path = "/"
      mech.cookie_jar.add(cookie)
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
        cookie = mech.cookies.select {|x| x.name == "PHPSESSID"}.first
        phpsessid = cookie.value
        Cache.put("pixiv-phpsessid", phpsessid.value, 1.month)
      end
    end

    mech
  end
end
