require "test_helper"

module Source::Tests::URL
  class NaverComicUrlTest < ActiveSupport::TestCase
    context "NaverComic URLs" do
      should be_page_url(
        "https://comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3",
        "https://m.comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3",
        "https://comic.naver.com/bestChallenge/list.nhn?titleId=717924",
        "https://comic.naver.com/challenge/list?titleId=846023",
        "https://comic.naver.com/webtoon/list?titleId=817631",
        "https://m.comic.naver.com/webtoon/list?titleId=817631",
        "https://comic.naver.com/challenge/detail?titleId=846023&no=8",
        "https://comic.naver.com/webtoon/detail?titleId=183559&no=1",
        "https://comic.naver.com/bestChallenge/detail.nhn?titleId=717924&no=1",
      )

      should be_profile_url(
        "https://comic.naver.com/community/u/_q40ec1",
        "https://comic.naver.com/community/u/_rbv5l",
      )

      should_not be_bad_source(
        "https://comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3",
      )

      should parse_url("https://comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3").into(
        page_url: "https://comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3",
        profile_url: "https://comic.naver.com/community/u/_q40ec1",
        user_id: "_q40ec1",
        post_id: "0-q40ec1-3",
      )

      should parse_url("https://comic.naver.com/bestChallenge/list.nhn?titleId=717924").into(
        page_url: "https://comic.naver.com/webtoon/list?titleId=717924",
        title_id: "717924",
      )

      should parse_url("https://m.comic.naver.com/webtoon/list?titleId=817631").into(
        page_url: "https://comic.naver.com/webtoon/list?titleId=817631",
        title_id: "817631",
      )

      should parse_url("https://comic.naver.com/challenge/detail?titleId=846023&no=8").into(
        page_url: "https://comic.naver.com/webtoon/detail?titleId=846023&no=8",
        title_id: "846023",
        chapter_no: "8",
      )

      should parse_url("https://comic.naver.com/bestChallenge/detail.nhn?titleId=717924&no=1").into(
        page_url: "https://comic.naver.com/webtoon/detail?titleId=717924&no=1",
        title_id: "717924",
        chapter_no: "1",
      )
    end

    should parse_url("https://comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3").into(site_name: "Naver Comic")
  end
end
