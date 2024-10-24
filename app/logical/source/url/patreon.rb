# frozen_string_literal: true

class Source::URL::Patreon < Source::URL
  RESERVED_USERNAMES = %w[api bePatron card-teaser-image collection checkout file home join
                          login m messages notifications policy posts profile search settings user]

  attr_reader :username, :user_id, :post_id, :attachment_id, :title, :media_hash, :media_params

  def self.match?(url)
    url.domain.in?(%w[patreon.com patreonusercontent.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJ3Ijo2MjB9/1.jpg?token-time=1668384000&token-hash=9ORWv7LJBzmvzmHTi_xGFQ47Uis9fNzTPp2WweThDj4%3D (sample)
    # https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJxIjoxMDAsIndlYnAiOjB9/1.jpg?token-time=1668384000&token-hash=FW6zNYKm5RWPfzwKIUBZ9ZuAY5Y-eIOHU-ipt5e7NSA%3D (full)
    in _, "patreonusercontent.com", _, "patreon-media", "p", "post", post_id, media_hash, media_params, *rest
      @post_id = post_id
      @media_hash = media_hash
      @media_params = Base64.decode64(media_params).parse_json || {}

    # https://c10.patreonusercontent.com/4/patreon-media/p/user/4045578/3101d8b9ba8348c592b68227f23b3568/eyJ3IjoyMDB9/1.jpeg?token-time=2145916800&token-hash=SQjWsty-7_MZqPt8R9_ZuJfzkW5F2pO3aqRV8iwZUIA%3D (profile picture)
    in _, "patreonusercontent.com", _, "patreon-media", "p", "user", user_id, media_hash, media_params, *rest
      @user_id = user_id
      @media_hash = media_hash
      @media_params = Base64.decode64(media_params).parse_json || {}

    # https://www.patreon.com/posts/71057815
    # https://www.patreon.com/posts/sparkle-71057815
    # https://www.patreon.com/posts/sparkle-71057815/edit
    in _, "patreon.com", "posts", slug, *rest
      @title, _, @post_id = slug.rpartition("-")

    # https://www.patreon.com/m/posts/sparkle-71057815
    in _, "patreon.com", "m", "posts", slug, *rest
      @title, _, @post_id = slug.rpartition("-")

    # https://www.patreon.com/checkout/1041uuu?rid=0
    # https://www.patreon.com/join/twistedgrim/checkout?rid=704013&redirect_uri=/posts/noi-dorohedoro-39394158
    # https://www.patreon.com/m/1041uuu/about
    in _, "patreon.com", ("checkout" | "join" | "m"), username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://www.patreon.com/bePatron?u=4045578
    # https://www.patreon.com/user?u=5993691
    # https://www.patreon.com/user/posts?u=84592583
    in _, "patreon.com", *rest if params[:u].present?
      @user_id = params[:u]

    # https://www.patreon.com/file?h=23563293&i=3053667
    in _, "patreon.com", "file"
      @post_id = params[:h]
      @attachment_id = params[:i]

    # https://www.patreon.com/api/posts/71057815
    in _, "patreon.com", "api", "posts", post_id
      @post_id = post_id

    # https://www.patreon.com/api/user/4045578
    in _, "patreon.com", "api", "user", user_id
      @user_id = user_id

    # https://www.patreon.com/1041uuu
    # https://www.patreon.com/1041uuu/about
    in _, "patreon.com", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://www.patreon.com/collection/90818
    # https://c10.patreonusercontent.com/4/patreon-media/p/campaign/518884/e980febbb38c4d33adf077458b7c3e03/eyJ3Ijo2MjB9/1.jpeg?token-time=1716163200&token-hash=PmbmjS7ldbk8xs0kqUaPO_cN4IM9Pn6nwvWNg5mRXuI%3D
    # https://c10.patreonusercontent.com/4/patreon-media/p/campaign/518884/60ba9a9ac04845e4bd38988476eadc8c/eyJ3IjoxOTIwLCJ3ZSI6MX0%3D/1.png?token-time=1717459200&token-hash=OpwBC3MWoCcmCkIzebTNHFQwm_iTZZfJwSm5f3wQY7A%3D (banner image)
    # https://c7.patreon.com/https%3A%2F%2Fwww.patreon.com%2F%2Fcard-teaser-image%2Fpost%2F99630172%2Flandscape%3Fc=1709435027.0/selector/%23post-teaser%2C.png
    # https://www.patreon.com/card-teaser-image/post/99630172/landscape?c=1709435027.0/selector/#post-teaser,.png
    # https://www.patreon.com/bePatron?patAmt=0.01&c=518884
    # https://www.patreon.com/api/media/165866535
    else
      nil
    end
  end

  def image_url?
    domain == "patreonusercontent.com" || attachment_id.present?
  end

  def page_url
    if title.present? && post_id.present?
      "https://www.patreon.com/posts/#{title}-#{post_id}"
    elsif post_id.present?
      "https://www.patreon.com/posts/#{post_id}"
    end
  end

  def profile_url
    if username.present?
      "https://www.patreon.com/#{username}"
    elsif user_id.present?
      "https://www.patreon.com/user?u=#{user_id}"
    end
  end
end
