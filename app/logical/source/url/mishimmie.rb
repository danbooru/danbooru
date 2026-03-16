# frozen_string_literal: true

class Source::URL::Mishimmie < Source::URL
  site "Mishimmie", url: "https://shimmie.katawa-shoujo.com"

  attr_reader :work_id

  def self.match?(url)
    url.host == "shimmie.katawa-shoujo.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
      # http://shimmie.katawa-shoujo.com/image/3657.jpg
    in "shimmie", "katawa-shoujo.com", "image", _file
      @work_id = filename
    else
      nil
    end
  end

  def site_name
    "Mishmmie"
  end

  def page_url
    "https://shimmie.katawa-shoujo.com/post/view/#{work_id}" if work_id.present?
  end
end
