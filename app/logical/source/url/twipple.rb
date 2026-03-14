# frozen_string_literal: true

class Source::URL::Twipple < Source::URL
  attr_reader :work_id, :username

  def self.match?(url)
    url.domain.in?(%w[twpl.jp twipple.jp])
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://p.twpl.jp/show/orig/DTaCZ
    # http://p.twipple.jp/show/orig/vXqaU
    in _, ("twpl.jp" | "twipple.jp"), "show", ("large" | "orig"), work_id
      @work_id = work_id

    # https://twpf.jp/swacoro
    in _, "twpl.jp", username
      @username = username

    else
      nil
    end
  end

  def page_url
    "http://p.twipple.jp/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://twpf.jp/#{username}" if username.present?
  end
end
