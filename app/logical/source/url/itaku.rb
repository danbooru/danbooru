# frozen_string_literal: true

class Source::URL::Itaku < Source::URL
  RESERVED_USERNAMES = %w[about help home tags]

  attr_reader :username, :image_id, :post_id, :file_id, :candidate_full_image_urls, :full_image_url

  def self.match?(url)
    url.domain == "itaku.ee"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB/xl.jpg (sample)
    # https://itaku.ee/api/media_2/gallery_imgs/IMG_3015_4PXa7zH/sm.jpg (sample)
    # https://itaku.ee/api/media_2/gallery_imgs/IMG_3015_4PXa7zH/lg.jpg (sample)
    # https://itaku.ee/api/media_2/gallery_imgs/IMG_3015_4PXa7zH/xl.jpg (sample)
    # https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA/xl.jpg (sample)
    # https://itaku.ee/api/media/gallery_imgs/Final_16-9_zKcwTHG/sm.jpg (video thumbnail)
    in _, _, "api", /media/ => media, /gallery/ => gallery, /_([a-zA-Z0-9]+)\z/ => image_filename, sample_filename
      @file_id = $1
      @candidate_full_image_urls = %w[png jpg gif].map { |ext| "#{site}/api/#{media}/#{gallery}/#{image_filename}.#{ext}" }

    # https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png (full)
    # https://itaku.ee/api/media_2/gallery_imgs/IMG_3015_4PXa7zH.png (full)
    # https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA.png (full)
    # https://itaku.ee/api/media/gallery_vids/Final_16-9_ckftagX.mp4
    in _, _, "api", /media/, /gallery/, /_([a-zA-Z0-9]+)\z/ => file
      @file_id = $1
      @full_image_url = to_s

    # https://itaku.ee/images/812661 (belongs to https://itaku.ee/posts/130073)
    in _, _, "images", image_id
      @image_id = image_id

    # https://itaku.ee/api/galleries/images/812661/comments/
    in _, _, "api", "galleries", "images", image_id, *rest
      @image_id = image_id

    # https://itaku.ee/posts/130073
    in _, _, "posts", post_id
      @post_id = post_id

    # https://itaku.ee/api/posts/130073/comments/
    in _, _, "api", "posts", post_id, *rest
      @post_id = post_id

    # https://itaku.ee/profile/advosart
    # https://itaku.ee/profile/advosart/gallery
    in _, _, "profile", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://itaku.ee/api/media_2/profile_pics/profile_pics/pfp9_kI67Jq5_oyZ4mO8/sm.jpg
    # https://itaku.ee/api/media_2/cover_pics/Banner3_plain_5T9aMBP.png
    else
      nil
    end
  end

  def page_url
    if post_id.present?
      "https://itaku.ee/posts/#{post_id}"
    elsif image_id.present?
      "https://itaku.ee/images/#{image_id}"
    end
  end

  def profile_url
    "https://itaku.ee/profile/#{username}" if username.present?
  end
end
