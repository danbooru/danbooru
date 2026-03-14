# frozen_string_literal: true

class Source::URL::Ameba < Source::URL
  attr_reader :username

  def self.match?(url)
    url.domain.in?(%w[ameblo.jp ameba.jp])
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://marilyn77.ameblo.jp/
    in username, "ameblo.jp", *_rest unless subdomain.in?(["www", "s", nil])
      @username = username

    # http://ameblo.jp/g8set55679
    # http://ameblo.jp/hanauta-os/entry-11860045489.html
    # http://s.ameblo.jp/ma-chi-no/
    in _, "ameblo.jp", username, *_rest
      @username = username

    # http://stat.ameba.jp/user_images/20130802/21/moment1849/38/bd/p
    # http://stat.ameba.jp/user_images/20140618/04/hanauta-os/d9/9d/j/o0480069212976538309.jpg?caw=1125
    # http://stat001.ameba.jp/user_images/20100212/15/weekend00/74/31/j/
    in /^stat\d*$/, "ameba.jp", "user_images", date, _, username, *_rest
      @date = date
      @username = username

    # https://profile.ameba.jp/ameba/kbnr32rbfs
    in "profile", "ameba.jp", "ameba", username
      @username = username

    # https://ameblo.jp/hanauta-os/image-11879922697-12976538309.html
    # https://stat.profile.ameba.jp/profile_images/20180310/23/2f/aY/g/o01400140p_1520691270256_dymla.gif (https://ameblo.jp/hanauta-os/entry-11860045489.html)
    else
      nil
    end
  end

  def profile_url
    "https://ameblo.jp/#{username}" if username.present?
  end
end
