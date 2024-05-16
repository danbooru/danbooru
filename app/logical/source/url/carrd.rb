# frozen_string_literal: true

class Source::URL::Carrd < Source::URL
  RESERVED_SUBDOMAINS = [nil, "www"]

  attr_reader :username, :page_id, :full_image_url, :candidate_full_image_urls

  def self.match?(url)
    url.domain == "carrd.co"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://caminukai-art.carrd.co/assets/images/gallery12/690db30b.jpg?v=3850522b (cropped thumbnail)
    # https://caminukai-art.carrd.co/assets/images/gallery13/ddc31be4_original.jpg?v=3850522b (full)
    # https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg?v=c6f079b5 (full)
    # https://rosymiz.carrd.co/assets/videos/video02.mp4.jpg?v=c6f079b5 (video cover)
    # https://rosymiz.carrd.co/assets/videos/video02.mp4?v=c6f079b5 (video)
    # https://rosymiz.carrd.co/assets/images/image01.jpg?v=c6f079b5 (profile image)
    in username, "carrd.co", "assets", *rest unless username.in?(RESERVED_SUBDOMAINS)
      @username = username

      if basename.ends_with?(".mp4") || filename.ends_with?("_original")
        @full_image_url = without(:query).to_s
      else
        @candidate_full_image_urls = [without(:query).with(filename: "#{filename}_original").to_s]
      end

    # https://caminukai-art.carrd.co
    # https://caminukai-art.carrd.co/#fanart-shadowheartguidance (post with single image)
    # https://caminukai-art.carrd.co/#characterdesign (gallery page with multiple posts)
    # https://lytell.carrd.co/#portfolio (gallery page with multiple images)
    in username, "carrd.co" unless username.in?(RESERVED_SUBDOMAINS)
      @username = username
      @page_id = fragment

    else
      nil
    end
  end

  def page_url
    "#{profile_url}/##{page_id}" if profile_url.present? && page_id.present?
  end

  def profile_url
    if username.present?
      "https://#{username}.carrd.co"
    elsif domain != "carrd.co"
      site
    end
  end
end
