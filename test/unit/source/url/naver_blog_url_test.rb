require "test_helper"

module Source::Tests::URL
  class NaverBlogUrlTest < ActiveSupport::TestCase
    context "NaverBlog URLs" do
      should be_page_url(
        "https://blog.naver.com/kkid9624/223421884109",
        "https://m.blog.naver.com/goam2/221647025085",
        "https://m.blog.naver.com/PostView.naver?blogId=fishtailia&logNo=223434964582",
      )

      should be_profile_url(
        "https://blog.naver.com/yanusunya",
        "https://m.blog.naver.com/goam2?tab=1",
        "https://m.blog.naver.com/rego/BlogUserInfo.naver?blogId=fishtailia",
        "https://blog.naver.com/PostList.naver?blogId=yanusunya&categoryNo=86&skinType=&skinId=&from=menu&userSelectMenu=true",
        "https://blog.naver.com/NBlogTop.naver?isHttpsRedirect=true&blogId=mgrtt3132003",
        "https://blog.naver.com/prologue/PrologueList.nhn?blogId=tobsua",
        "https://blog.naver.com/profile/intro.naver?blogId=rlackswnd58",
        "https://rss.blog.naver.com/yanusunya.xml",
        "https://mirun2.blog.me",
      )
    end

    should parse_url("https://blog.naver.com/kkid9624/223421884109").into(site_name: "Naver Blog")

    should parse_url("https://m.blog.naver.com/PostView.naver?blogId=fishtailia&logNo=223434964582").into(username: "fishtailia", post_id: "223434964582")
    should parse_url("https://m.blog.naver.com/PostView.naver?blogId=../x&logNo=1?x=1").into(username: nil, post_id: nil)
  end
end
