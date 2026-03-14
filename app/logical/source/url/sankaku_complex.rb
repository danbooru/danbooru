# frozen_string_literal: true

class Source::URL::SankakuComplex < Source::URL
  attr_reader :md5

  def self.match?(url)
    url.domain == "sankakucomplex.com"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://cs.sankakucomplex.com/data/68/6c/686ceee03af38fe4ceb45bf1c50947e0.jpg?e=1591893718&m=fLlJfTrK_j2Rnc0uIHNC3w
    # https://v.sankakucomplex.com/data/24/ff/24ff5da1fd7ed051b083b36e4e51de8e.mp4?e=1644999580&m=-OtZg2QdtKbibMte8vlsdw&expires=1644999580&token=0YUdUKKwTmvpozhG1WW_nRvSUQw3WJd574andQv-KYY
    # https://cs.sankakucomplex.com/data/sample/2a/45/sample-2a45c67281b0fcfd26208063f81a3114.jpg?e=1590609355&m=cexHhVyJguoZqPB3z3N7aA
    # https://c3.sankakucomplex.com/data/sample/8a/44/preview8a44211650e818ef07e5d00284c20a14.jpg
    in _, "sankakucomplex.com", "data", *_subdirs, /^(?:preview|sample-)?(\h{32})\./
      @md5 = Regexp.last_match(1)

    # https://chan.sankakucomplex.com/?tags=user%3ASubridet
    else
      nil
    end
  end

  def site_name
    "Sankaku Complex"
  end

  def page_url
    "https://chan.sankakucomplex.com/post/show?md5=#{md5}" if md5.present?
  end
end
