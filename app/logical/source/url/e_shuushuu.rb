# frozen_string_literal: true

class Source::URL::EShuushuu < Source::URL
  site "E-Shuushuu", url: "https://e-shuushuu.net", domains: %w[e-shuushuu.net]

  attr_reader :work_id

  def self.match?(url)
    url.domain == "e-shuushuu.net"
  end

  def site_name
    "E-Shuushuu"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://e-shuushuu.net/images/2017-07-19-915628.jpeg
    in _, "e-shuushuu.net", "images", /^\d{4}-\d{2}-\d{2}-(\d+)\./
      @date = filename
      @work_id = filename.split("-").last
    else
      nil
    end
  end

  def page_url
    "https://e-shuushuu.net/image/#{work_id}" if work_id.present?
  end
end
