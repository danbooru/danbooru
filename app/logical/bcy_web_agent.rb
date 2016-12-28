class BCYWebAgent
  LOGIN_URL = "http://bcy.net/public/dologin"
  CACHE_KEY = "bcy-credentials"

  def self.build
    mech = Mechanize.new

    phpsessid, logged_user = Cache.get(CACHE_KEY, 1.day) do
      params = {
        email: Danbooru.config.bcy_email,
        password: Danbooru.config.bcy_password,
        remember: 1
      }

      mech.post(LOGIN_URL, params)

      phpsessid = mech.cookies.select do |cookie| cookie.name == "PHPSESSID" end.first.try(:value)
      logged_user = mech.cookies.select do |cookie| cookie.name == "LOGGED_USER" end.first.try(:value)

      [phpsessid, logged_user]
    end

    phpsessid_cookie = Mechanize::Cookie.new("PHPSESSID", phpsessid)
    phpsessid_cookie.domain = ".bcy.net"
    phpsessid_cookie.path = "/"
    mech.cookie_jar.add(phpsessid_cookie)

    logged_user_cookie = Mechanize::Cookie.new("LOGGED_USER", logged_user)
    logged_user_cookie.domain = ".bcy.net"
    logged_user_cookie.path = "/"
    mech.cookie_jar.add(logged_user_cookie)

    mech
  end
end
