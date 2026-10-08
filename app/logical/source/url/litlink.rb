# frozen_string_literal: true

class Source::URL::Litlink < Source::URL
  site "Lit.link", url: "https://lit.link"

  attr_reader :username

  def self.match?(url)
    url.domain == "lit.link"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://lit.link/upn2o
    in nil, "lit.link", username
      @username = username

    # https://lit.link/en/upn2o
    in nil, "lit.link", "en", username
      @username = username

    else
      nil
    end
  end

  def profile_url
    "https://lit.link/#{username}" if username.present?
  end
end
