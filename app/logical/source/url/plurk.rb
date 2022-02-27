# frozen_string_literal: true

# Notes
#
# * Posts can have up to 10 images.
# * Artists commonly post extra images by replying to their own post.
# * Adult posts are hidden for logged out users. The main images can be found by
#   scraping a <script> tag, but an API call is needed to get the images in the replies.
#
# Image URLs
#
# * https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg
#
# Thumbnail URLs
#
# * https://images.plurk.com/mx_5wj6WD0r6y4rLN0DL3sqag.jpg
#
# Page URLs
#
# * https://www.plurk.com/p/om6zv4 (non-adult, single image)
# * https://www.plurk.com/p/okxzae (non-adult, multiple images, with replies)
# * https://www.plurk.com/p/omc64y (adult, multiple images, with replies)
# * https://www.plurk.com/m/p/omc64y
#
# Profile URLs
#
# * https://www.plurk.com/redeyehare
# * https://www.plurk.com/m/redeyehare

class Source::URL::Plurk < Source::URL
  attr_reader :username, :work_id

  def self.match?(url)
    url.domain == "plurk.com"
  end

  def parse
    case [domain, *path_segments]

    # https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg
    # https://images.plurk.com/mx_5wj6WD0r6y4rLN0DL3sqag.jpg
    in "plurk.com", /^(mx_)?(\w{22})\.(\w+)$/
      @image_id = $2

    # https://www.plurk.com/p/om6zv4
    in "plurk.com", "p", work_id
      @work_id = work_id

    # https://www.plurk.com/m/p/okxzae
    in "plurk.com", "m", "p", work_id
      @work_id = work_id

    # https://www.plurk.com/redeyehare
    in "plurk.com", username
      @username = username

    # https://www.plurk.com/m/redeyehare
    in "plurk.com", "m", username
      @username = username

    else
    end
  end

  def image_url?
    host == "images.plurk.com"
  end
end
