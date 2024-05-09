# frozen_string_literal: true

# This handles generic Google CDN URLs that may be used across multiple different services, including Youtube, Google Photos, etc.
#
# @see Source::URL::Blogger
# @see Source::URL::Youtube
# @see Source::Extractor::Google
class Source::URL::Google < Source::URL
  attr_reader :full_image_url

  def self.match?(url)
    [url.subdomain, url.domain] in /lh/, ("ggpht.com" | "googleusercontent.com")
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://lh3.googleusercontent.com/qAhRBhfciCcosUoYHPJr5WtNYSJ81vpSqcQwbQitZtsR3mB2aCUj7J5LvhJOCfWn-CWqiLB18SyTr1VJvm_HI7B72opIAMZiZvg=s0 (sample)
    # https://lh3.googleusercontent.com/qAhRBhfciCcosUoYHPJr5WtNYSJ81vpSqcQwbQitZtsR3mB2aCUj7J5LvhJOCfWn-CWqiLB18SyTr1VJvm_HI7B72opIAMZiZvg=d (original)
    # https://lh3.googleusercontent.com/C6yBYozE1sXc9o_jsrh29_AYQ6ffCKO-fpooQ5nwuu7FSgQvdGtfSbcJVBUGSDi1VXE9TqYT2g=s0?imgmax=s0 (sample)
    # https://lh3.googleusercontent.com/C6yBYozE1sXc9o_jsrh29_AYQ6ffCKO-fpooQ5nwuu7FSgQvdGtfSbcJVBUGSDi1VXE9TqYT2g=d (original)
    # https://lh3.googleusercontent.com/u/0/d/1IzBIuWQTTlxhnx-KghudVQOmoCNvvARt=s0
    # https://play-lh.googleusercontent.com/n8xsLUPjbQnT4q0DgZtLmx3LMe8kRFh1j0cpANE5QQM75ukQJIpHaa6R7W6mwP6pNBw=s0
    in /lh/, "googleusercontent.com", *subdirs, image_id
      image_id = image_id.split("=").first
      @full_image_url = ["https://#{host}", *subdirs, "#{image_id}=d"].join("/")

    # http://lh3.ggpht.com/_0qYlQ9JkXnE/Ryz9b1yXRDI/AAAAAAAAAu4/Iv0WPaT7uWY/016.jpg
    # http://lh6.ggpht.com/_McwONtqkVLo/S8EZLNU8DfI/AAAAAAAAAKk/NhV7npfiU-U/whitebeard%20death[6].jpg?imgmax=800
    # http://lh5.ggpht.com/Xornotgenesis/R_8w6z6-mII/AAAAAAAABSw/HanR9XEW3h8/zankuro.png
    in /^lh\d+$/, "ggpht.com", dir1, dir2, dir3, dir4, file if file_ext.present?
      @full_image_url = "https://#{host}/#{dir1}/#{dir2}/#{dir3}/#{dir4}/d/#{file}"

    # http://lh5.ggpht.com/-ykP8cKuqOfU/UKEOptJJvoI/AAAAAAAAMAY/Kp7qo5A50E8/d/0027.jpg
    # http://lh5.ggpht.com/-ykP8cKuqOfU/UKEOptJJvoI/AAAAAAAAMAY/Kp7qo5A50E8/d/
    # http://lh5.ggpht.com/-ykP8cKuqOfU/UKEOptJJvoI/AAAAAAAAMAY/Kp7qo5A50E8/
    in /^lh\d+$/, "ggpht.com", dir1, dir2, dir3, dir4, *rest
      file = rest[1]
      @full_image_url = "https://#{host}/#{dir1}/#{dir2}/#{dir3}/#{dir4}/d/#{file}"

    else
      nil
    end
  end

  def image_url?
    true
  end
end
