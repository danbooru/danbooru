# frozen_string_literal: true

class Source::URL::Marshmallow < Source::URL
  RESERVED_USERNAMES = %w[about auth attributions broadcasts help me messages users session settings terms]

  attr_reader :username

  def self.match?(url)
    url.domain.in?(%w[marshmallow-qa.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://marshmallow-qa.com/horyu999
    # https://marshmallow-qa.com/horyu999#new_message
    in _, _, username unless username.in?(RESERVED_USERNAMES)
      @username = username

    else
      nil
    end
  end

  def profile_url
    "https://marshmallow-qa.com/#{username}" if username.present?
  end
end
