# frozen_string_literal: true

class Source::URL::Tiktok < Source::URL
  site "TikTok", url: "https://www.tiktok.com"

  attr_reader :username

  def self.match?(url)
    url.domain == "tiktok.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1
    # https://www.tiktok.com/@h.panda_12
    # https://www.tiktok.com/@lenn0n__?
    in _, "tiktok.com", /^@[\w.]+$/ => username
      @username = username
    else
      nil
    end
  end

  def profile_url
    "https://www.tiktok.com/#{username}" if username.present?
  end
end
