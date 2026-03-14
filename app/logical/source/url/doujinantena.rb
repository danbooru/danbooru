# frozen_string_literal: true

class Source::URL::Doujinantena < Source::URL
  attr_reader :md5

  def self.match?(url)
    url.domain == "doujinantena.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://com2.doujinantena.com/contents_jpg/cf0224563cf7a75450596308fe651d5f/018.jpg
    # http://sozai.doujinantena.com/contents_jpg/cf0224563cf7a75450596308fe651d5f/009.jpg
    in _, "doujinantena.com", "contents_jpg", /^\h{32}$/ => md5, *_rest
      @md5 = md5

    else
      nil
    end
  end

  def page_url
    "http://doujinantena.com/page.php?id=#{md5}" if md5.present?
  end
end
