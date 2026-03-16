# frozen_string_literal: true

class Source::URL::Minitokyo < Source::URL
  site "Minitokyo", url: "http://www.minitokyo.net"

  attr_reader :work_id

  def self.match?(url)
    url.domain == "minitokyo.net"
  end

  def parse
    case [subdomain, domain, *path_segments]
      # http://static.minitokyo.net/downloads/31/33/764181.jpg
    in _, "minitokyo.net", "downloads", /^\d{2}$/, /^\d{2}$/, _file
      @work_id = filename
    else
      nil
    end
  end

  def page_url
    "http://gallery.minitokyo.net/view/#{work_id}" if work_id.present?
  end
end
