# frozen_string_literal: true

class Source::URL::Imgur < Source::URL
  attr_reader :image_id, :album_id, :image, :username

  def self.match?(url)
    url.domain.in?(%w[imgur.com imgur.io])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://i.imgur.com/c7EXjJu.jpeg (full image)
    # https://i.imgur.com/c7EXjJu.png (extension doesn't matter; still jpeg)
    # https://i.imgur.com/c7EXjJu_d.jpeg?maxwidth=200&shape=thumb&fidelity=high (sample)
    # https://i.imgur.com/c7EXjJub.jpeg (sample)
    # https://i.imgur.com/c7EXjJug.jpeg (sample)
    # https://i.imgur.com/c7EXjJuh.jpeg (sample)
    # https://i.imgur.com/c7EXjJul.jpeg (sample)
    # https://i.imgur.com/c7EXjJum.jpeg (sample)
    # https://i.imgur.com/c7EXjJur.jpeg (sample)
    # https://i.imgur.com/c7EXjJus.jpeg (sample)
    # https://i.imgur.com/c7EXjJut.jpeg (sample)
    # https://i.imgur.com/Kp9TdlX.gifv (.mp4 embedded in html page)
    # https://i.imgur.com/Kp9TdlX.mp4 (sample; original image is .gif)
    in "i", _, _
      # Imgur IDs are 5 characters or 7 characters; if it has 6 or 8, then the last character indicates the sample image type.
      @image_id = filename[/([[:alnum:]]{7}|[[:alnum:]]{5})/, 1]
      @image = true

    # https://imgur.com/download/c7EXjJu/
    # https://imgur.com/download/c7EXjJu/undefined
    in _, _, "download", image_id, *rest
      @image_id = image_id
      @image = true

    # https://imgur.com/c7EXjJu
    # https://imgur.io/c7EXjJu
    # https://m.imgur.com/c7EXjJu
    in _, _, image_id
      @image_id = image_id

    # https://imgur.com/gallery/0BDNq
    # https://imgur.com/a/0BDNq
    # https://imgur.com/a/0BDNq/zip (zip download)
    # https://imgur.com/a/0BDNq/all (old layout)
    # https://imgur.com/a/2tWSH1c (hidden (unlisted) album; https://imgur.com/gallery/2tWSH1c doesn't work)
    # https://alanbox.imgur.com/a/lDRB2 (very old album)
    in _, _, ("gallery" | "a"), album_id, *rest
      @album_id = album_id

    # https://imgur.com/t/anime/g0ua0kg
    in _, _, "t", tag, album_id
      @album_id = album_id

    # https://imgur.io/r/anime/h9U6X22 -> https://imgur.com/a/h9U6X22
    # https://imgur.io/r/anime/5Os4IW2 -> https://imgur.com/5Os4IW2
    in _, _, "r", subreddit, id
      # XXX This could be an album ID or an image ID - no way to tell which.

    # https://imgur.com/user/naugrim2875
    # https://imgur.com/user/naugrim2875/posts
    in _, _, "user", username, *rest
      @username = username

    else
    end
  end

  def full_image_url
    if image_id.present? && file_ext.present?
      ext = (file_ext == "gifv" ? "gif" : file_ext)
      "https://i.imgur.com/#{image_id}.#{ext}"
    elsif image_id.present?
      "https://imgur.com/download/#{image_id}"
    end
  end

  def image_url?
    !!image
  end

  def page_url
    if album_id.present?
      "https://imgur.com/a/#{album_id}"
    elsif image_id.present?
      "https://imgur.com/#{image_id}"
    end
  end

  def profile_url
    "https://imgur.com/user/#{username}" if username.present?
  end
end
