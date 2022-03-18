# frozen_string_literal: true

class Source::URL::Fc2 < Source::URL
  attr_reader :username, :profile_url

  def self.match?(url)
    url.domain.in?(%w[fc2.com fc2blog.net fc2blog.us])
  end

  def site_name
    "FC2"
  end

  def parse
    case [*host.split("."), *path_segments]

    # http://silencexs.blog.fc2.com
    # http://silencexs.blog106.fc2.com
    in username, /blog\d*/, "fc2", "com", *rest
      @username = username
      @profile_url = "http://#{username}.blog.fc2.com"

    # http://794ancientkyoto.web.fc2.com
    # http://yorokobi.x.fc2.com
    # https://lilish28.bbs.fc2.com
    # http://jpmaid.h.fc2.com
    # http://toritokaizoku.web.fc2.com/tori.html (404: http://toritokaizoku.web.fc2.com)
    in username, ("bbs" | "web" | "h" | "x") => subsite, "fc2", "com", *rest
      @username = username
      @subsite = subsite
      @profile_url = ["http://#{username}.#{subsite}.fc2.com", *rest].join("/")

    # http://swordsouls.blog131.fc2blog.net
    # http://swordsouls.blog131.fc2blog.us
    in username, /blog\d*/, "fc2blog", ("net" | "us") => tld, *rest
      @username = username
      @profile_url = "http://#{username}.blog.fc2blog.#{tld}"

    else
    end
  end
end
