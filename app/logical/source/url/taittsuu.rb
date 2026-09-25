# frozen_string_literal: true

class Source::URL::Taittsuu < Source::URL
  site "Taittsuu", url: "https://taittsuu.com"

  attr_reader :username, :post_id

  def self.match?(url)
    url.domain.in?(%w[taittsuu.com taittsuu-media.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://files.taittsuu-media.com/taiitsus/9/9532/8609d69324245020c588483a3a6f34382b01846e4fc2dc09.jpg
    # https://files.taittsuu-media.com/profiles/94/53323c3e53b84b53d4ed105d55523297a338e4ed2d92f266.jpg?bd5ae6ec60
    in _, "taittsuu-media.com", *_rest
      nil

    # https://taittsuu.com/users/razukichi/status/9532242
    in _, "taittsuu.com", "users", username, "status", post_id
      @username = username
      @post_id = post_id

    # https://taittsuu.com/users/razukichi
    in _, "taittsuu.com", "users", username, *_rest
      @username = username

    else
      nil
    end
  end

  def image_url?
    domain == "taittsuu-media.com"
  end

  def page_url
    "https://taittsuu.com/users/#{username}/status/#{post_id}" if username.present? && post_id.present?
  end

  def profile_url
    "https://taittsuu.com/users/#{username}" if username.present?
  end
end
