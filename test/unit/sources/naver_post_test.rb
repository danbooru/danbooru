# frozen_string_literal: true

require "test_helper"

module Sources
  class NaverPostTest < ActiveSupport::TestCase
    context "Naver Post:" do
      should "Parse URLs correctly" do
        assert(Source::URL.page_url?("https://m.post.naver.com/viewer/postView.naver?volumeNo=33304944&memberNo=7662880"))
        assert(Source::URL.page_url?("https://post.naver.com/viewer/postView.nhn?volumeNo=33304944&memberNo=7662880"))

        assert(Source::URL.profile_url?("https://m.post.naver.com/author/board.naver?memberNo=7662880"))
        assert(Source::URL.profile_url?("https://post.naver.com/my.nhn?memberNo=6072169"))
        assert(Source::URL.profile_url?("https://post.naver.com/my/followingList.naver?memberNo=6072169&navigationType=push"))
        assert(Source::URL.profile_url?("https://post.naver.com/my/like/list.naver?memberNo=6072169&navigationType=push"))
        assert(Source::URL.profile_url?("https://post.naver.com/my/followerList.naver?followNo=6072169&navigationType=push"))
        assert(Source::URL.profile_url?("https://post.naver.com/dltkdrlf92"))
      end
    end
  end
end
