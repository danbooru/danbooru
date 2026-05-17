# frozen_string_literal: true

class Source::URL::Paheal < Source::URL
  site "Paheal", url: "https://rule34.paheal.net"

  attr_reader :md5, :work_id

  def self.match?(url)
    url.domain == "paheal.net"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://tulip.paheal.net/_images/4f309b2b680da9c3444ed462bb172214/3910816%20-%20Dark_Magician_Girl%20MINK343%20Yu-Gi-Oh!.jpg
    # http://rule34-data-002.paheal.net/_images/2ab55f9291c8f2c68cdbeac998714028/2401510%20-%20Ash_Ketchum%20Lillie%20Porkyman.jpg
    # http://rule34-images.paheal.net/c4710f05e76bdee22fcd0d62bf1ac840/262685%20-%20mabinogi%20nao.jpg
    in _, "paheal.net", *_subdirs, /^\h{32}$/ => md5, /^(\d+)/
      @md5 = md5
      @work_id = Regexp.last_match(1)

    # http://rule34.paheal.net/post/list/Reach025/
    else
      nil
    end
  end

  def page_url
    "https://rule34.paheal.net/post/view/#{work_id}" if work_id.present?
  end
end
