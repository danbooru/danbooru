# frozen_string_literal: true

class Source::URL::YachiyoRoom < Source::URL
  site "Yachiyo's Room", url: "https://yachiyo-room.com/", domains: %w[yachiyo-room.com cloudfront.net]

  attr_reader :image_id, :timestamp, :hash, :artist_name

  def self.match?(url)
    url.domain == "yachiyo-room.com" || url.host == "d3icawwrjcmhat.cloudfront.net"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://yachiyo-room.com/oekaki/1059
    in _, "yachiyo-room.com", "oekaki", image_id
      @image_id = image_id

    # https://yachiyo-room.com/gallery?name=んぽょ。
    # https://yachiyo-room.com/gallery?name=んぽょ。&name_mode=exact
    in _, "yachiyo-room.com", "gallery" if params["name"].present? && (!params["name_mode"].present? || params["name_mode"] == "exact")
      @artist_name = params["name"]

    # https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1774796101015-w8euiu.png
    in "d3icawwrjcmhat", "cloudfront.net", "prod", "oekaki", filename
      m = filename.match(/^(\d+)-(.+)\.png$/)
      @timestamp = m[1].to_i
      @hash = m[2]

    else
      nil
    end
  end

  def page_url
    "https://yachiyo-room.com/oekaki/#{@image_id}" if @image_id.present?
  end

  def profile_url
    "https://yachiyo-room.com/gallery?name=#{artist_name}" if @artist_name.present?
  end

  def image_url?
    @timestamp.present?
  end

  def page_url?
    @image_id.present?
  end

  def profile_url?
    @artist_name.present?
  end
end
