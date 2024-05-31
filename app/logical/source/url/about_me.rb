# frozen_string_literal: true

class Source::URL::AboutMe < Source::URL
  attr_reader :username, :full_image_url

  def self.match?(url)
    url.domain == "about.me"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=750/https://assets.about.me/background/users/w/o/k/wokada156_1411467603_49.jpg
    # https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=1799.9100044997751/https://assets.about.me/background/users/u/dot/n/u.no_1471830904_68.jpg
    # https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=cover,w=120,h=120,gravity=auto/https://assets.about.me/background/users/s/g/r/sgr_sk_1369590004_43.jpg
    in _, "about.me", "cdn-cgi", "image", params, *url, /^(.+)_\d+_\d+/
      @full_image_url = to_s.delete_prefix("#{site}/cdn-cgi/image/#{params}/")
      @username = $1

    # https://assets.about.me/background/users/w/o/k/wokada156_1411467603_49.jpg
    in "assets", "about.me", "background", "users", a, b, c, /^(.+)_\d+_\d+/
      @full_image_url = to_s
      @username = $1

    # https://about.me/wokada156
    in _, "about.me", username
      @username = username

    else
      nil
    end
  end

  def image_url?
    full_image_url.present?
  end

  def profile_url
    "https://about.me/#{username}" if username.present?
  end
end
