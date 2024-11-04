# frozen_string_literal: true

class Source::URL::Privatter < Source::URL
  attr_reader :filename, :post_id, :username, :blog_id

  def self.match?(url)
    url.domain == "privatter.net" || url.host == "d2pqhom6oey9wx.cloudfront.net"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://privatter.net/i/7184521
    in _, "privatter.net", "i", /\A\d+\z/ => post_id
      @post_id = post_id

    # https://privatter.net/p/8037485
    in _, "privatter.net", "p", /\A\d+\z/ => blog_id
      @blog_id = blog_id

    # https://privatter.net/u/GLK_Sier
    # https://privatter.net/m/minami_152133
    in _, "privatter.net", ("u" | "m"), username
      @username = username

    # https://d2pqhom6oey9wx.cloudfront.net/img_original/6501563076473624f29c22.png
    in "d2pqhom6oey9wx", "cloudfront.net", "img_resize" | "img_original", filename
      @filename = filename

    else
      nil
    end
  end

  def full_image_url
    "https://d2pqhom6oey9wx.cloudfront.net/img_original/#{filename}" if filename.present?
  end

  def page_url
    if post_id.present?
      "https://privatter.net/i/#{post_id}"
    elsif blog_id.present?
      "https://privatter.net/p/#{blog_id}"
    end
  end

  def profile_url
    "https://privatter.net/u/#{username}" if username.present?
  end
end
