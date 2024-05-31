# frozen_string_literal: true

class Source::URL::ArtStation < Source::URL
  RESERVED_SUBDOMAINS = %w[www cdn cdna cdnb]
  RESERVED_USERNAMES = %w[about blogs challenges guides jobs learning marketplace prints schools search studios subscribe]

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

    # https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4
    in "cdn-animation.artstation.com", "p", "video_sources", *subdirs, file
      nil

    # https://www.artstation.com/artwork/04XA4
    # https://www.artstation.com/artwork/cody-from-sf (old; redirects to https://www.artstation.com/artwork/3JJA)
    # https://sa-dui.artstation.com/projects/DVERn
    # https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041
    in _, ("artwork" | "projects"), work_id
      @work_id = work_id
      @username = subdomain unless subdomain.in?(RESERVED_SUBDOMAINS)

    # https://artstation.com/artist/sa-dui
    # https://www.artstation.com/artist/sa-dui
    # https://www.artstation.com/artist/chicle/albums/all/
    in _, "artist", username, *rest
      @username = username

    # http://artstation.com/sha_sha
    # https://www.artstation.com/sa-dui
    # https://www.artstation.com/felipecartin/profile
    # https://www.artstation.com/chicle/albums/all
    # https://www.artstation.com/h-battousai/albums/1480261
    # http://www.artstation.com/envie_dai/prints
    in ("www.artstation.com" | "artstation.com"), username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://sa-dui.artstation.com
    # https://hosi_na.artstation.com
    # https://heyjay.artstation.com/store/art_posters
    in *rest unless subdomain.in?(RESERVED_SUBDOMAINS)
      @username = subdomain

    else
      nil
    end
  end

  def image_url?
    subdomain.to_s.starts_with?("cdn")
  end

  def full_image_url(size = "original")
    return nil unless image_url?

    if @asset_type.present? && @asset_subdir.present? && @file.present? && @timestamp.present?
      "https://cdn.artstation.com/p/assets/#{@asset_type}/images/#{@asset_subdir}/#{size}/#{@file}?#{@timestamp}"
    elsif @asset_type.present? && @asset_subdir.present? && @file.present?
      "https://cdn.artstation.com/p/assets/#{@asset_type}/images/#{@asset_subdir}/#{size}/#{@file}"
    else
      to_s
    end
  end

  def page_url
    "https://www.artstation.com/artwork/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://www.artstation.com/#{username}" if username.present?
  end
end
