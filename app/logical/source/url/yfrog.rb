# frozen_string_literal: true

class Source::URL::Yfrog < Source::URL
  attr_reader :post_id, :username

  def self.match?(url)
    url.domain == "yfrog.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://yfrog.com/gyi1smoj
    in nil, "yfrog.com", post_id unless image_url?
      @post_id = post_id

    # http://twitter.yfrog.com/z/oe3umiifj
    in "twitter", "yfrog.com", "z", post_id
      @post_id = post_id

    # http://yfrog.com/user/0128sinonome/photos
    in _, "yfrog.com", "user", username, *_rest
      @username = username

    else
      nil
    end
  end

  def page_url
    "http://yfrog.com/#{post_id}" if post_id.present?
  end

  def profile_url
    "http://yfrog.com/user/#{username}/photos" if username.present?
  end
end
