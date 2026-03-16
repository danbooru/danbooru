# frozen_string_literal: true

class Source::URL::Allmylinks < Source::URL
  site "AllMyLinks", url: "https://allmylinks.com"

  attr_reader :username

  def self.match?(url)
    url.domain == "allmylinks.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://allmylinks.com/hieumayart
    in _, "allmylinks.com", username
      @username = username
    else
      nil
    end
  end

  def site_name
    "AllMyLinks"
  end

  def profile_url
    "https://allmylinks.com/#{username}" if username.present?
  end
end
