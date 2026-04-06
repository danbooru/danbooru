# frozen_string_literal: true

class Source::URL::Minitokyo < Source::URL
  RESERVED_USERNAMES = %w[forum gallery my static www]

  site "Minitokyo", url: "http://www.minitokyo.net"

  attr_reader :work_id, :page, :username, :full_image_url, :image_type

  def self.match?(url)
    url.domain == "minitokyo.net"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://static.minitokyo.net/downloads/31/33/764181.jpg
    # http://static2.minitokyo.net/view/39/41/332089.jpg (sample)
    # http://static3.minitokyo.net/thumbs/01/26/318801.jpg
    # http://static1.minitokyo.net/thumbs/42/26/571342-2.jpg
    # http://static.minitokyo.net/downloads/42/26/571342-3.jpg
    in /^static/, "minitokyo.net", ("downloads" | "view" | "thumbs") => image_type, /^\d{2}$/ => subdir1, /^\d{2}$/ => subdir2, file
      @work_id, @page = filename.split("-", 2)
      @image_type = image_type
      @full_image_url = "http://static.minitokyo.net/downloads/#{subdir1}/#{subdir2}/#{file}"

    # http://gallery.minitokyo.net/download/571342/1
    in "gallery", "minitokyo.net", "download", work_id, page
      @work_id = work_id
      @page = page

    # http://gallery.minitokyo.net/view/365677
    # http://gallery.minitokyo.net/download/571342
    in "gallery", "minitokyo.net", ("view" | "download"), work_id
      @work_id = work_id

    # http://deto15.minitokyo.net
    in username, "minitokyo.net" unless username.in?(RESERVED_USERNAMES)
      @username = username

    # http://www.minitokyo.net/Touhou
    else
      nil
    end
  end

  def image_sample?
    image_url? && image_type != "downloads"
  end

  def page_url
    if work_id.present?
      "http://gallery.minitokyo.net/view/#{work_id}"
    end
  end

  def profile_url
    "http://#{username}.minitokyo.net" if username.present?
  end
end
