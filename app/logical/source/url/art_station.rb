# frozen_string_literal: true

class Source::URL::ArtStation < Source::URL
  RESERVED_SUBDOMAINS = %w[www cdn cdna cdnb]
  IMAGE_SUBDOMAINS = %w[cdn cdna cdnb]

  attr_reader :username, :work_id

  def self.match?(url)
    url.domain == "artstation.com"
  end

  def site_name
    "ArtStation"
  end

  def parse
    case [host, *path_segments]

    # https://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236
    # https://cdnb.artstation.com/p/assets/images/images/014/410/217/smaller_square/bart-osz-bartosz1812041.jpg?1543866276
    # https://cdna.artstation.com/p/assets/images/images/007/253/680/4k/ina-wong-demon-girl-done-ttd-comp.jpg?1504793833
    # https://cdna.artstation.com/p/assets/covers/images/007/262/828/small/monica-kyrie-1.jpg?1504865060
    in _, "p", "assets", ("images" | "covers") => asset_type, "images", *subdirs, size, file
      @asset_type = asset_type
      @asset_subdir = subdirs.join("/")
      @file = file
      @timestamp = query if query&.match?(/^\d+$/)

    # https://www.artstation.com/artwork/04XA4
    # https://www.artstation.com/artwork/cody-from-sf (old; redirects to https://www.artstation.com/artwork/3JJA)
    # https://sa-dui.artstation.com/projects/DVERn
    # https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041
    in _, ("artwork" | "projects"), work_id
      @work_id = work_id
      @username = subdomain unless subdomain.in?(RESERVED_SUBDOMAINS)

    # https://www.artstation.com/artist/sa-dui
    in "www.artstation.com", "artist", username
      @username = username

    # https://www.artstation.com/sa-dui
    # https://www.artstation.com/felipecartin/profile
    in "www.artstation.com", username, *rest
      @username = username

    # https://sa-dui.artstation.com
    # https://hosi_na.artstation.com
    in *rest unless subdomain.in?(RESERVED_SUBDOMAINS)
      @username = subdomain

    else
    end
  end

  def image_url?
    @file.present?
  end

  def full_image_url(size = "original")
    return nil unless image_url?

    if @timestamp.present?
      "https://cdn.artstation.com/p/assets/#{@asset_type}/images/#{@asset_subdir}/#{size}/#{@file}?#{@timestamp}"
    else
      "https://cdn.artstation.com/p/assets/#{@asset_type}/images/#{@asset_subdir}/#{size}/#{@file}"
    end
  end

  def profile_url
    "https://www.artstation.com/#{username}" if username.present?
  end
end
