# frozen_string_literal: true

class Source::URL::Postype < Source::URL
  RESERVED_SUBDOMAINS = %w[about blog c3 i www]

  attr_reader :full_image_url, :post_id, :series_id, :blogname, :username

  def self.match?(url)
    url.domain == "postype.com" || url.host.in?(%w[d2ufj6gm1gtdrc.cloudfront.net d3mcojo3jv0dbr.cloudfront.net d33pksfia2a94m.cloudfront.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://d3mcojo3jv0dbr.cloudfront.net/2021/03/19/20/57/7e8c74bfe4a77f6a037ed8b02194955c.webp?w=240&h=180&q=65 (thumbnail)
    # https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg?w=1200&q=90 (sample)
    # https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg (full)
    # https://i.postype.com/2017/01/27/01/28/22c423dd569a1c2aaec66bc551c54d5b.png?w=1000 (old images, no longer used)
    # https://c3.postype.com/2017/07/04/21/29/42fc32581770dd593788cce89652f757.png
    in _, _, /^\d{4}$/, /^\d{2}$/, /^\d{2}$/, /^\d{2}$/, /^\d{2}$/, file
      @full_image_url = without(:query).to_s

    # https://www.postype.com/_next/image?url=https%3A%2F%2Fd3mcojo3jv0dbr.cloudfront.net%2F2024%2F04%2F03%2F12%2F46%2F1ffb36f1881b16a5c5881fc6eaa06179.jpeg%3Fw%3D1000%26h%3D700%26q%3D65&w=3840&q=75
    in _, "postype.com", "_next", "image" if params[:url].present?
      @full_image_url = Source::URL.parse(params[:url]).try(:full_image_url)

    # https://luland.postype.com/post/11659399
    # https://www.postype.com/post/11659399
    in blogname, "postype.com", "post", post_id unless blogname.in?(RESERVED_SUBDOMAINS)
      @blogname = blogname
      @post_id = post_id

    # https://www.postype.com/@fruitsnoir/post/5316533
    in _, "postype.com", /^@/ => blogname, "post", /^\d+$/ => post_id
      @blogname = blogname.delete_prefix("@")
      @post_id = post_id

    # https://nanbongman0.postype.com/series/964724/타투리소스
    in blogname, "postype.com", "series", series_id, *rest unless blogname.in?(RESERVED_SUBDOMAINS)
      @blogname = blogname
      @series_id = series_id

    # https://www.postype.com/@fruitsnoir/series/450088
    in _, "postype.com", /^@/ => blogname, "series", /^\d+$/ => series_id
      @blogname = blogname.delete_prefix("@")
      @series_id = series_id

    # https://luland.postype.com
    # https://luland.postype.com/posts
    in blogname, "postype.com", *rest unless blogname.in?(RESERVED_SUBDOMAINS)
      @blogname = blogname

    # https://www.postype.com/@fruitsnoir
    # https://www.postype.com/@fruitsnoir/post
    in _, "postype.com", /^@/ => blogname, *rest
      @blogname = blogname.delete_prefix("@")

    # https://www.postype.com/profile/@ep58bc
    # https://www.postype.com/profile/@ep58bc/posts
    in _, "postype.com", "profile", username, *rest
      @username = username.delete_prefix("@")

    # https://d33pksfia2a94m.cloudfront.net/assets/img/brand/favicon.png
    else
      nil
    end
  end

  def image_url?
    super || full_image_url.present?
  end

  def page_url
    "https://www.postype.com/@#{blogname}/post/#{post_id}" if blogname.present? && post_id.present?
  end

  def profile_url
    if blogname.present?
      "https://www.postype.com/@#{blogname}"
    elsif username.present?
      "https://www.postype.com/profile/@#{username}"
    end
  end
end
