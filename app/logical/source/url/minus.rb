# frozen_string_literal: true

class Source::URL::Minus < Source::URL
  attr_reader :work_id

  def self.match?(url)
    url.domain == "minus.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://i1.minus.com/ibb0DuE2Ds0yE6.jpg
    # http://i5.minus.com/ik26grnRJAmYh.jpg
    in _, "minus.com", /^[ij]([a-zA-Z0-9]{12,})\.(jpg|png|gif)$/
      @work_id = Regexp.last_match(1)
    else
      nil
    end
  end

  def page_url
    "http://minus.com/i/#{work_id}" if work_id.present?
  end
end
