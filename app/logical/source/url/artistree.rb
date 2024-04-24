# frozen_string_literal: true

class Source::URL::Artistree < Source::URL
  RESERVED_USERNAMES = %w[artist-guide blog cookie-policy contact faq mission press privacy-policy search static team terms-and-conditions]

  attr_reader :username, :commission_id

  def self.match?(url)
    url.domain == "artistree.io" || url.host == "dwxo6p939as9l.cloudfront.net"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://dwxo6p939as9l.cloudfront.net/seraexecfia/Anime Illustration/s6-s1lkmz.jpg
    # https://dwxo6p939as9l.cloudfront.net/niroira/Headshot/ScreenShot20230902at4-s0du6y.49.41PM.png
    # https://dwxo6p939as9l.cloudfront.net/niroira/Waist-Up/Ichigo-s3xbgp.jpg
    # https://dwxo6p939as9l.cloudfront.net/alysonsega/Full render (Character and/or Background/Object)/Sonicandmariotransparent-rkdqe1.png
    # https://dwxo6p939as9l.cloudfront.net/alysonsega/Lineart%20%20Flats/CapturadePantalla20221026alas16-rkdqzo.42.49.png
    # https://dwxo6p939as9l.cloudfront.net/alysonsega/e1e4b980-dfb4-4670-8b59-38c97adf0187/autoretrato-jaja-rqxg8p.jpg (profile pic)
    # https://dwxo6p939as9l.cloudfront.net/crestfallen163/81434378-aaf2-40a1-ab1a-7b5bd6a3f237/banner/Illustration201-2-s5bn67.png (profile banner)
    in _, "cloudfront.net", username, *rest
      @username = username

    # https://artistree.io/crestfallen163
    # https://artistree.io/crestfallen163#d2ca3306-0a5d-426e-925a-191593e6cfe1
    in _, "artistree.io", username unless username.in?(RESERVED_USERNAMES)
      @username = username
      @commission_id = fragment

    # https://artistree.io/request/adolfozapp
    # https://artistree.io/queue/akefesauce
    in _, "artistree.io", ("request" | "queue"), username
      @username = username

    else
      nil
    end
  end

  def page_url
    if username.present? && commission_id.present?
      "https://artistree.io/#{username}##{commission_id}"
    else
      "https://artistree.io/#{username}"
    end
  end

  def profile_url
    "https://artistree.io/#{username}" if username.present?
  end

  def profile_url?
    profile_url.present? && page_url == profile_url && !image_url?
  end
end
