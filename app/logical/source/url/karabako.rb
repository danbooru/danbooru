# frozen_string_literal: true

class Source::URL::Karabako < Source::URL
  attr_reader :work_id

  def self.match?(url)
    url.domain == "karabako.net"
  end

  def parse
    case [subdomain, domain, *path_segments]
      # http://www.karabako.net/images/karabako_43878.jpg
      # http://www.karabako.net/imagesub/karabako_43222_215.jpg
    in _, "karabako.net", ("images" | "imagesub"), /^karabako_(\d+)/
      @work_id = Regexp.last_match(1)
    else
      nil
    end
  end

  def page_url
    "http://www.karabako.net/post/view/#{work_id}" if work_id.present?
  end
end
