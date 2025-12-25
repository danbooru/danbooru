# frozen_string_literal: true

# Tistory uses daumcdn.net and kakaocdn.net image URLs, which are also used by other sites besides Tistory. They're
# handled in Source::URL::Kakao and Source::Extractor::Kakao.
#
# Tistory supports blogs on custom domains (ex: https://panchokworkshop.com/520). They're detected in Source::Extractor::Null.
#
# @see Source::URL::Kakao
# @see Source::Extractor::Kakao
# @see Source::Extractor::Tistory
# @see Source::Extractor::Null
class Source::URL::Tistory < Source::URL
  RESERVED_SUBDOMAINS = [nil, "www"]

  attr_reader :username, :post_id, :post_title

  def self.match?(url)
    url.domain == "tistory.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # http://cfile9.uf.tistory.com/image/1935713C4E8B51B0165990
    # http://cfs14.tistory.com/image/33/tistory/2008/11/13/00/16/491af335ea4dd
    # http://cfs7.tistory.com/original/33/tistory/2008/09/17/19/46/48d0dfec46aca
    # http://cfs2.tistory.com/upload_control/download.blog?fhandle=YmxvZzQ2ODg4QGZzMi50aXN0b3J5LmNvbTovYXR0YWNoLzAvMjkuanBn
    in _, "tistory.com", *rest if image_url?
      nil

    # https://caswac1.tistory.com/entry/용사의-선택지가-이상하다
    in _, _, "entry", post_title
      @username = subdomain unless custom_domain? || subdomain.in?(RESERVED_SUBDOMAINS)
      @post_title = post_title

    # https://caswac1.tistory.com/m/entry/용사의-선택지가-이상하다
    in _, _, "m", "entry", post_title
      @username = subdomain unless custom_domain? || subdomain.in?(RESERVED_SUBDOMAINS)
      @post_title = post_title

    # https://primemeeting.tistory.com/25
    # https://panchokworkshop.com/520
    in _, _, /^\d+$/ => post_id
      @username = subdomain unless custom_domain? || subdomain.in?(RESERVED_SUBDOMAINS)
      @post_id = post_id

    # https://primemeeting.tistory.com/m/25
    # https://panchokworkshop.com/m/520
    in _, _, "m", /^\d+$/ => post_id
      @username = subdomain unless custom_domain? || subdomain.in?(RESERVED_SUBDOMAINS)
      @post_id = post_id

    # https://primemeeting.tistory.com
    # https://primemeeting.tistory.com/m
    # https://primemeeting.tistory.com/category
    in _, "tistory.com", *rest
      @username = subdomain unless custom_domain? || subdomain.in?(RESERVED_SUBDOMAINS)

    # https://t1.daumcdn.net/cfile/tistory/99A3CF4B5C2AFDF806?original (full; see Source::URL::Kakao)
    # https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg (full; see Source::URL::Kakao)
    else
      nil
    end
  end

  def custom_domain?
    domain != "tistory.com"
  end

  def image_url?
    # http://cfile9.uf.tistory.com/image/1935713C4E8B51B0165990
    # http://cfs7.tistory.com/original/33/tistory/2008/09/17/19/46/48d0dfec46aca
    subdomain in /^cfs\d+$/ | /^cfile\d+\.uf$/
  end

  def page_url
    if profile_url.present? && post_id.present?
      "#{profile_url}/#{post_id}"
    elsif username.present? && post_title.present?
      "#{profile_url}/entry/#{post_title}"
    end
  end

  def mobile_page_url
    if profile_url.present? && post_id.present?
      "#{profile_url}/m/#{post_id}"
    elsif username.present? && post_title.present?
      "#{profile_url}/m/entry/#{post_title}"
    end
  end

  def profile_url
    if custom_domain?
      site
    elsif username.present?
      "https://#{username}.tistory.com"
    end
  end
end
