# frozen_string_literal: true

class Source::URL::Carrd < Source::URL
  DOMAINS = %w[carrd.co crd.co]
  RESERVED_SUBDOMAINS = [nil, "www"]

  attr_reader :username, :page_id, :full_image_url, :candidate_full_image_urls

  def self.match?(url)
    url.domain.in?(DOMAINS)
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://caminukai-art.carrd.co/assets/images/gallery12/690db30b.jpg?v=3850522b (cropped thumbnail)
    # https://caminukai-art.carrd.co/assets/images/gallery13/ddc31be4_original.jpg?v=3850522b (full)
    # https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg?v=c6f079b5 (full)
    # https://rosymiz.carrd.co/assets/videos/video02.mp4.jpg?v=c6f079b5 (video cover)
    # https://rosymiz.carrd.co/assets/videos/video02.mp4?v=c6f079b5 (video)
    # https://rosymiz.carrd.co/assets/images/image01.jpg?v=c6f079b5 (profile image)
    # https://hyphensam.com/assets/images/image04.jpg?v=208ad020
    # https://otonokj.crd.co/assets/images/gallery13/cf6083f7.jpg?v=adc9c9a1
    in _, _, "assets", ("images" | "videos"), *rest
      @username = subdomain unless custom_domain? || subdomain.in?(RESERVED_SUBDOMAINS)
      @image_url = true

      if basename.ends_with?(".mp4") || filename.ends_with?("_original")
        @full_image_url = without(:query).to_s
      else
        @candidate_full_image_urls = [without(:query).with(filename: "#{filename}_original").to_s]
      end

    # https://caminukai-art.carrd.co
    # https://caminukai-art.carrd.co/#fanart-shadowheartguidance (post with single image)
    # https://caminukai-art.carrd.co/#characterdesign (gallery page with multiple posts)
    # https://lytell.carrd.co/#portfolio (gallery page with multiple images)
    # https://otonokj.crd.co/#info
    # https://hyphensam.com/#test-image
    else
      @username = subdomain unless custom_domain? || subdomain.in?(RESERVED_SUBDOMAINS)
      @page_id = fragment if fragment in /^[a-zA-Z0-9-]+$/
    end
  end

  def custom_domain?
    !domain.in?(DOMAINS)
  end

  def image_url?
    @image_url == true
  end

  def page_url
    "#{profile_url}/##{page_id}" if profile_url.present? && page_id.present?
  end

  def profile_url
    if username.present?
      # https://caminukai-art.carrd.co
      # https://otonokj.crd.co
      "https://#{username}.#{domain}"
    elsif custom_domain?
      site
    end
  end
end
