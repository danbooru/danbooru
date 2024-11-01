# frozen_string_literal: true

class Source::URL::Odaibako < Source::URL
  attr_reader :username, :odai_id, :post_id, :image_hash, :original_file_ext

  def self.match?(url)
    url.domain == "odaibako.net"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://ccs.odaibako.net/w=1600/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg.webp
    # https://ccs.odaibako.net/w=1600/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg
    # https://ccs.odaibako.net/_/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg
    in _, _, _, "post_images", username, /^(\h+?)\.(\w+)(?:\.webp)?$/
      @username = username
      @image_hash = $1
      @original_file_ext = $2

    # https://odaibako.net/odais/d811a8ae-cc45-4922-9652-d2dcfb9d3492
    in _, _, "odais", odai_id
      @odai_id = odai_id

    # https://odaibako.net/posts/01923bc559bc0fd9ac983610d654ea2d
    in _, _, "posts", post_id
      @post_id = post_id

    # https://odaibako.net/u/aaaaaariko
    in _, _, "u", username
      @username = username

    else
      nil
    end
  end

  def full_image_url
    if username.present? && image_hash.present? && original_file_ext.present?
      "https://ccs.odaibako.net/_/post_images/#{username}/#{image_hash}.#{original_file_ext}"
    end
  end

  def page_url
    if odai_id.present?
      "https://odaibako.net/odais/#{odai_id}"
    elsif post_id.present?
      "https://odaibako.net/posts/#{post_id}"
    end
  end

  def profile_url
    "https://skeb.jp/@#{username}" if username.present?
  end
end
