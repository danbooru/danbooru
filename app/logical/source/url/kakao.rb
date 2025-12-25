# frozen_string_literal: true

# This handles daumcdn.net and kakaocdn.net image URLs that are used by Tistory, Daum.net, and other Daum/Kakao sites.
# (They may also be used in Naver Post blogs, even though Naver and Kakao are different companies?)
#
# @see Source::Extractor::Tistory
# @see Source::Extractor::NaverPost
class Source::URL::Kakao < Source::URL
  attr_reader :full_image_url

  def self.match?(url)
    url.domain.in?(%w[daumcdn.net kakaocdn.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://i1.daumcdn.net/thumb/C450x300/?fname=https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg (thumbnail)
    # https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FRA1tu%2FbtsFf2xGLbg%2FVzHK4tqMEWkeqUgDBxSkkK%2Fimg.jpg (sample)
    # https://img1.daumcdn.net/thumb/R720x0.q80/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F99A3CF4B5C2AFDF806 (sample)
    in _, "daumcdn.net", "thumb", *rest if params[:fname].present?
      @full_image_url = Source::URL.parse(params[:fname]).try(:full_image_url) || params[:fname]

    # https://t1.daumcdn.net/cfile/tistory/99A3CF4B5C2AFDF806 (sample)
    # https://t1.daumcdn.net/cfile/tistory/99A3CF4B5C2AFDF806?original (full)
    in _, "daumcdn.net", "cfile", "tistory", _
      @full_image_url = with(query: "original").to_s

    # https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg (full)
    # https://k.kakaocdn.net/dn/mQLkt/btqAWceNev9/YzuxTjBjxF11aPc79RWo10/img.png (full)
    else
      nil
    end
  end

  def image_url?
    true
  end
end
