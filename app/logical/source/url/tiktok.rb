# frozen_string_literal: true

class Source::URL::Tiktok < Source::URL
  site "TikTok", url: "https://www.tiktok.com", domains: %w[tiktok.com tiktokcdn-us.com]
  extractors { [Source::Extractor::Null, Source::Extractor::URLShortener] }

  attr_reader :username, :work_type, :work_id, :redirect_id

  def self.match?(url)
    url.domain.in?(%w[tiktok.com tiktokcdn-us.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://www.tiktok.com/@ashshae0/video/7618903378113924373
    # https://www.tiktok.com/@pyromannce/photo/7584709238878915858?_r=1&_t=ZS-93TCD3c5ooM
    in _, "tiktok.com", /^@[\w.]+$/ => username, ("video" | "photo") => work_type, work_id
      @username = username
      @work_type = work_type
      @work_id = work_id

    # https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1
    # https://www.tiktok.com/@h.panda_12
    # https://www.tiktok.com/@lenn0n__?
    in _, "tiktok.com", /^@[\w.]+$/ => username
      @username = username

    # https://vt.tiktok.com/ZSa9V7ert/
    # => https://www.tiktok.com/@pyromannce/photo/7584709238878915858?_r=1&_t=ZS-93TCD3c5ooM
    in "vt", "tiktok.com", redirect_id
      @redirect_id = redirect_id

    # https://www.tiktok.com/t/ZSa9V7ert/
    in _, "tiktok.com", "t", redirect_id
      @redirect_id = redirect_id

    # https://p16-common-sign.tiktokcdn-us.com/tos-useast5-i-photomode-tx/c997051aa88446328e44de163d83a30c~tplv-photomode-image.jpeg?dr=9616&x-expires=1774238400&x-signature=mnDyZBX35%2BTC4y8Uvno95%2FiewDU%3D&t=4d5b0474&ps=13740610&shp=81f88b70&shcp=9b759fb9&idc=useast5&ftpl=1
    else
      nil
    end
  end

  def extractor_class
    redirect_id.present? ? Source::Extractor::URLShortener : Source::Extractor::Null
  end

  def page_url
    "https://www.tiktok.com/#{username}/#{work_type}/#{work_id}" if username.present? && work_type.present? && work_id.present?
  end

  def profile_url
    "https://www.tiktok.com/#{username}" if username.present?
  end
end
