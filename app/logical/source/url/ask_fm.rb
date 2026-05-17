# frozen_string_literal: true

class Source::URL::AskFm < Source::URL
  site "Ask.fm", url: "https://ask.fm"

  attr_reader :username

  def self.match?(url)
    url.domain == "ask.fm"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://ask.fm/kiminaho
    # https://m.ask.fm/kiminaho
    # http://ask.fm/cyoooooon/best
    in _, "ask.fm", username, *_rest
      @username = username
    else
      nil
    end
  end

  def profile_url
    "https://ask.fm/#{username}" if username.present?
  end
end
