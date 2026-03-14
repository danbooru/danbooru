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
    # http://stat001.ameba.jp/user_images/20100212/15/weekend00/74/31/j/
    in /^stat\d*$/, "ameba.jp", "user_images", date, _, username, *_rest
      @date = date
      @username = username

    # https://profile.ameba.jp/ameba/kbnr32rbfs
    in "profile", "ameba.jp", "ameba", username
      @username = username

    else
      nil
    end
  end

  def profile_url
    "https://ameblo.jp/#{username}" if username.present?
  end
end
