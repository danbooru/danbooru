# frozen_string_literal: true

class Source::URL::Imgbb < Source::URL
  site "Imgbb", url: "https://imgbb.com"

  attr_reader :username

  def self.match?(url)
    url.domain == "imgbb.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
      # https://meliach.imgbb.com
      # https://meliach.imgbb.com/albums
    in username, "imgbb.com", *_rest unless subdomain.in?(["www", nil])
      @username = username
    else
      nil
    end
  end

  def site_name
    "ImgBB"
  end

  def profile_url
    "https://#{username}.imgbb.com" if username.present?
  end
end
