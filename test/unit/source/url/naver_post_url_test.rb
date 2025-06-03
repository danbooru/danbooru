require "test_helper"

module Source::Tests::URL
  class NaverPostUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        page_urls: [
          "https://m.post.naver.com/viewer/postView.naver?volumeNo=33304944&memberNo=7662880",
          "https://post.naver.com/viewer/postView.nhn?volumeNo=33304944&memberNo=7662880",
        ],
        profile_urls: [
          "https://m.post.naver.com/author/board.naver?memberNo=7662880",
          "https://post.naver.com/my.nhn?memberNo=6072169",
          "https://post.naver.com/my/followingList.naver?memberNo=6072169&navigationType=push",
          "https://post.naver.com/my/like/list.naver?memberNo=6072169&navigationType=push",
          "https://post.naver.com/my/followerList.naver?followNo=6072169&navigationType=push",
          "https://post.naver.com/dltkdrlf92",
        ],
      )
    end
  end
end
