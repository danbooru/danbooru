class NicoSeigaApiClient
  extend Memoist
  BASE_URL = "http://seiga.nicovideo.jp/api"
  attr_reader :illust_id

  def self.agent
    mech = Mechanize.new
    mech.redirect_ok = false
    mech.keep_alive = false

    session = Cache.get("nico-seiga-session")
    if session
      cookie = Mechanize::Cookie.new("user_session", session)
      cookie.domain = ".nicovideo.jp"
      cookie.path = "/"
      mech.cookie_jar.add(cookie)
    else
      mech.get("https://account.nicovideo.jp/login") do |page|
        page.form_with(:id => "login_form") do |form|
          form["mail_tel"] = Danbooru.config.nico_seiga_login
          form["password"] = Danbooru.config.nico_seiga_password
        end.click_button
      end
      session = mech.cookie_jar.cookies.select{|c| c.name == "user_session"}.first
      if session
        Cache.put("nico-seiga-session", session.value, 1.week)
      else
        raise "Session not found"
      end
    end

    # This cookie needs to be set to allow viewing of adult works
    cookie = Mechanize::Cookie.new("skip_fetish_warning", "1")
    cookie.domain = "seiga.nicovideo.jp"
    cookie.path = "/"
    mech.cookie_jar.add(cookie)

    mech.redirect_ok = true
    mech
  end

  def initialize(illust_id:, user_id: nil)
    @illust_id = illust_id
    @user_id = user_id
  end

  def image_id
    illust_xml["response"]["image"]["id"].to_i
  end

  def user_id
    @user_id || illust_xml["response"]["image"]["user_id"].to_i
  end

  def title
    illust_xml["response"]["image"]["title"]
  end

  def desc
    illust_xml["response"]["image"]["description"]
  end

  def moniker
    artist_xml["response"]["user"]["nickname"]
  end

  def illust_xml
    uri = "#{BASE_URL}/illust/info?id=#{illust_id}"
    body, code = HttpartyCache.get(uri)
    if code == 200
      Hash.from_xml(body)
    else
      raise "nico seiga api call failed (code=#{code}, body=#{body})"
    end
  end
  memoize :illust_xml

  def artist_xml
    uri = "#{BASE_URL}/user/info?id=#{user_id}"
    body, code = HttpartyCache.get(uri)
    if code == 200
      Hash.from_xml(body)
    else
      raise "nico seiga api call failed (code=#{code}, body=#{body})"
    end
  end
  memoize :artist_xml
end
