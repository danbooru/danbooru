require "test_helper"

module Source::Tests::URL
  class TistoryUrlTest < ActiveSupport::TestCase
    context "Tistory URLs" do
      should be_image_url(
        "https://t1.daumcdn.net/cfile/tistory/99A3CF4B5C2AFDF806",
        "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FRA1tu%2FbtsFf2xGLbg%2FVzHK4tqMEWkeqUgDBxSkkK%2Fimg.jpg",
        "https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg",
        "http://cfile9.uf.tistory.com/image/1935713C4E8B51B0165990",
        "http://cfs7.tistory.com/original/33/tistory/2008/09/17/19/46/48d0dfec46aca",
        "http://cfs2.tistory.com/upload_control/download.blog?fhandle=YmxvZzQ2ODg4QGZzMi50aXN0b3J5LmNvbTovYXR0YWNoLzAvMjkuanBn",
      )

      should be_page_url(
        "https://primemeeting.tistory.com/25",
        "https://primemeeting.tistory.com/m/25",
        "https://caswac1.tistory.com/entry/용사의-선택지가-이상하다",
        "https://caswac1.tistory.com/m/entry/용사의-선택지가-이상하다",
      )

      should be_profile_url(
        "https://primemeeting.tistory.com",
        "https://primemeeting.tistory.com/m",
      )
    end
  end
end
