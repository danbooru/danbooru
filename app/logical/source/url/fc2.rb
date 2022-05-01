# frozen_string_literal: true

class Source::URL::Fc2 < Source::URL
  attr_reader :username, :profile_url, :page_url, :file

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
    # http://onidocoro.blog14.fc2.com/file/20071003061150.png
    in username, /^blog\d*$/, "fc2", "com", *rest
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
    in username, /^blog\d*$/, "fc2blog", ("net" | "us") => tld, *rest
      @username = username
      @profile_url = "http://#{username}.blog.fc2blog.#{tld}"

    # http://blog23.fc2.com/m/mosha2/file/uru.jpg
    # http://blog.fc2.com/g/genshi/file/20070612a.jpg
    in /^blog\d*$/, "fc2", "com", /^\w$/, username, "file", file
      @file = file
      @username = username
      @profile_url = "http://#{username}.blog.fc2.com"

    # http://blog-imgs-63-origin.fc2.com/y/u/u/yuukyuukikansya/140817hijiri02.jpg
    # http://blog-imgs-61.fc2.com/o/m/o/omochi6262/20130402080220583.jpg
    # http://blog.fc2.com/g/b/o/gbot/20071023195141.jpg
    in (/^blog-imgs-\d+(-origin)?$/ | "blog"), "fc2", "com", /^\w$/, /^\w$/, /^\w$/, username, file
      @file = file
      @username = username
      @page_url = "http://#{username}.blog.fc2.com/img/#{file}"
      @profile_url = "http://#{username}.blog.fc2.com"

    # http://diary.fc2.com/user/yuuri/img/2005_12/26.jpg
    # http://diary1.fc2.com/user/kou_48/img/2006_8/14.jpg
    # http://diary.fc2.com/user/kazuharoom/img/2015_5/22.jpg
    in /diary\d*$/, "fc2", "com", "user", username, "img", date, file
      @file = file
      @username = username
      @year, @month = date.split("_")
      @day = filename
      @page_url = "http://#{host}/cgi-sys/ed.cgi/#{username}?Y=#{@year}&M=#{@month}&D=#{@day}"
      @profile_url = "http://diary.fc2.com/cgi-sys/ed.cgi/#{username}"

    # http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom/?Y=2012&M=10&D=22
    in /diary\d*$/, "fc2", "com", "cgi-sys", "ed.cgi", username
      @username = username
      @profile_url = "http://diary.fc2.com/cgi-sys/ed.cgi/#{username}"

    else
      nil
    end
  end
end
