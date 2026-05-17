# frozen_string_literal: true

class Source::URL::Baidu < Source::URL
  site "Baidu", url: "https://hi.baidu.com"

  attr_reader :username

  def self.match?(url)
    url.domain == "baidu.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://hi.baidu.com/new/mocaorz
    in "hi", "baidu.com", "new", username
      @username = username

    # http://hi.baidu.com/lizzydom
    # http://hi.baidu.com/longbb1127/home
    # http://hi.baidu.com/daidaishi/ihome/ihomefeed
    in "hi", "baidu.com", username, *_rest
      @username = username

    else
      nil
    end
  end

  def profile_url
    "http://hi.baidu.com/#{username}" if username.present?
  end
end
