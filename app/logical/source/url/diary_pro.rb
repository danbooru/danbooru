# frozen_string_literal: true

# Web Diary Professional is an old CGI script used by multiple sites as a self-hosted blogging system.
# https://www.web-liberty.net/download/diarypro/index.html
class Source::URL::DiaryPro < Source::URL
  site "Diary Pro", url: "https://www.web-liberty.net/download/diarypro/index.html"

  attr_reader :work_id, :base_url

  def self.match?(url)
    # http://webknight0.sakura.ne.jp/cgi-bin/diarypro/data/upfile/9-1.jpg
    # http://www.yanbow.com/~myanie/diarypro/diary.cgi?mode=image&upfile=279-1.jpg
    [url.subdomain, url.domain, *url.path_segments] in *, "diarypro", ("data" | "diary.cgi"), *
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://nekomataya.net/diarypro/data/upfile/66-1.jpg
    # http://www117.sakura.ne.jp/~cat_rice/diarypro/data/upfile/31-1.jpg
    # http://webknight0.sakura.ne.jp/cgi-bin/diarypro/data/upfile/9-1.jpg
    in _, _, *subdirs, "diarypro", "data", "upfile", /^(\d+)-\d+\./
      @work_id = $1
      @base_url = [site, *subdirs].join("/")

    # http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=723-4.jpg
    # http://www.danshaku.sakura.ne.jp/cgi-bin/diarypro/diary.cgi?mode=image&upfile=56-1.jpg
    # http://www.yanbow.com/~myanie/diarypro/diary.cgi?mode=image&upfile=279-1.jpg
    in _, _, *subdirs, "diarypro", "diary.cgi" if params[:mode] == "image" && params[:upfile].present?
      @work_id = params[:upfile][/^\d+/]
      @base_url = [site, *subdirs].join("/")
    end
  end

  def page_url
    "#{base_url}/diarypro/diary.cgi?no=#{@work_id}" if base_url.present? && work_id.present?
  end
end
