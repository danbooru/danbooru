# frozen_string_literal: true

# SpinSpin was previously known as spinspin.net.
class Source::URL::Spinspin < Source::URL
  site "SpinSpin", url: "https://spin-spin.com", domains: %w[spin-spin.com spinspin.net cloudfront.net]

  attr_reader :username, :post_id

  def self.match?(url)
    url.domain.in?(%w[spin-spin.com spinspin.net]) || url.host == "d320v6c020sgby.cloudfront.net"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://d320v6c020sgby.cloudfront.net/1755495584110.png
    in "d320v6c020sgby", "cloudfront.net", *_rest
      nil

    # https://spin-spin.com/post/68a2bc7a619eacd84fb04cb4
    # https://spinspin.net/post/68a2bc7a619eacd84fb04cb4
    in _, _, "post", post_id
      @post_id = post_id

    # https://spin-spin.com/UhgMa
    # https://spin-spin.com/UhgMa/request
    # https://spinspin.net/UhgMa
    in _, _, username, *_rest
      @username = username

    else
      nil
    end
  end

  def image_url?
    domain == "cloudfront.net"
  end

  def page_url
    "https://spin-spin.com/post/#{post_id}" if post_id.present?
  end

  def profile_url
    "https://spin-spin.com/#{username}" if username.present?
  end
end
