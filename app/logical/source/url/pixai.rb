# frozen_string_literal: true

class Source::URL::Pixai < Source::URL
  attr_reader :artwork_id, :username, :file_path, :file_name

  def self.match?(url)
    url.domain.in?(%w[pixai.art imagedelivery.net])
  end

  def parse
    case [domain, *path_segments]

    # https://pixai.art/artwork/1553702739525334835
    in "pixai.art", "artwork", artwork_id
      @artwork_id = artwork_id

    # https://pixai.art/@kit
    in "pixai.art", /^@/ => username
      @username = username.delete_prefix("@")

    # https://imagedelivery.net/5ejkUOtsMH5sf63fw6q33Q/ace59f44-0f29-47c9-855d-516edb5bcc00/public
    in "imagedelivery.net", path, file, ("public" | "thumbnail")
      @file_path = path
      @file_name = file

    else
      nil
    end
  end

  def page_url
    "https://pixai.art/artwork/#{artwork_id}" if artwork_id.present?
  end

  def profile_url
    "https://pixai.art/@#{username}" if username.present?
  end

  def image_url?
    domain == "imagedelivery.net"
  end

  def full_image_url
    "https://imagedelivery.net/#{file_path}/#{file_name}/public"
  end
end
