# frozen_string_literal: true

class Source::URL::Boosty < Source::URL
  site "Boosty", url: "https://boosty.to"

  attr_reader :username, :post_id, :image_id, :user_id, :full_image_url

  def self.match?(url)
    url.domain == "boosty.to"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://images.boosty.to/image/ede74f96-b31b-4059-9f8d-8a3dd7314711
    # https://images.boosty.to/image/ede74f96-b31b-4059-9f8d-8a3dd7314711?change_time=1716964397&mw=80
    in "images", "boosty.to", "image", image_id
      @image_id = image_id
      @full_image_url = "https://images.boosty.to/image/#{image_id}"

    # https://images.boosty.to/user/9186794/avatar?change_time=1706076492
    # https://images.boosty.to/blog/9186794/cover?change_time=1768400706
    in "images", "boosty.to", ("user" | "blog"), user_id, ("avatar" | "cover")
      @user_id = user_id
      @full_image_url = without(:query).to_s

    # https://boosty.to/rebeccagod/posts/f76e3d79-39b5-42fa-b7a1-0f8dc5261654
    in _, "boosty.to", username, "posts", post_id
      @username = username
      @post_id = post_id

    # https://boosty.to/rebeccagod/blog/media/f76e3d79-39b5-42fa-b7a1-0f8dc5261654/ede74f96-b31b-4059-9f8d-8a3dd7314711
    in _, "boosty.to", username, "blog", "media", post_id, image_id
      @username = username
      @post_id = post_id
      @image_id = image_id

    # https://boosty.to/rebeccagod/about
    # https://boosty.to/rebeccagod/about/media/015d83f0-60d6-4bb2-bd8c-9c211b2c5052?from=about_author
    in _, "boosty.to", username, "about", *rest
      @username = username

    # https://boosty.to/rebeccagod
    in _, "boosty.to", username
      @username = username

    else
      nil
    end
  end

  def image_url?
    full_image_url.present?
  end

  def page_url
    "https://boosty.to/#{username}/posts/#{post_id}" if username.present? && post_id.present?
  end

  def profile_url
    "https://boosty.to/#{username}" if username.present?
  end
end
