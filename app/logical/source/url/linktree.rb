# frozen_string_literal: true

class Source::URL::Linktree < Source::URL
  attr_reader :username

  def self.match?(url)
    url.domain == "linktr.ee"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://linktr.ee/cxlinray
    # https://linktr.ee/seamonkey_op?utm_source=linktree_admin_share
    in _, "linktr.ee", username
      @username = username

    else
      nil
    end
  end

  def profile_url
    "https://linktr.ee/#{username}" if username.present?
  end
end