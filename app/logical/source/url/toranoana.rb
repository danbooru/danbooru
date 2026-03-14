# frozen_string_literal: true

class Source::URL::Toranoana < Source::URL
  attr_reader :work_id

  def self.match?(url)
    url.domain == "toranoana.jp"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg
    # http://img.toranoana.jp/popup_img18/04/0010/22/87/040010228714-1p.jpg
    # http://img.toranoana.jp/popup_blimg/04/0030/08/30/040030083068-1p.jpg
    # http://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg
    in ("img" | "ecdnimg"), "toranoana.jp", *_subdirs, /^\d{2}$/, /^\d{4}$/, /^\d{2}$/, /^\d{2}$/, /^(\d{12})-\d+p\./
      @work_id = Regexp.last_match(1)
    else
      nil
    end
  end

  def page_url
    "https://ec.toranoana.jp/tora_r/ec/item/#{work_id}" if work_id.present?
  end
end
