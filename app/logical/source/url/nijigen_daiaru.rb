# frozen_string_literal: true

class Source::URL::NijigenDaiaru < Source::URL
  site "Nijigen Daiaru", url: "http://nijigen-daiaru.com"

  attr_reader :work_id

  def self.match?(url)
    url.domain == "nijigen-daiaru.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://jpg.nijigen-daiaru.com/7364/013.jpg
    in "jpg", "nijigen-daiaru.com", /^\d+$/ => work_id, _file
      @work_id = work_id
    else
      nil
    end
  end

  def page_url
    "http://nijigen-daiaru.com/book.php?idb=#{work_id}" if work_id.present?
  end
end
