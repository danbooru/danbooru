require "test_helper"

module Source::Tests::URL
  class EntyUrlTest < ActiveSupport::TestCase
    context "Enty URLs" do
      should be_image_url(
        "https://img01.enty.jp/uploads/post/thumbnail/141598/post_show_b6c7d85c-b63c-4950-9152-e4bf30678022.png",
        "https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png",
        "https://entyjp.s3-ap-northeast-1.amazonaws.com/uploads/post/attachment/141598/20211227_130_030_100.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIMO6YQGDXLXXJKQA%2F20230214%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221225T003003Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=0ecb359544a7c8a3569aef5162e482664e1c7d98412dfdd445851e3db11523f8",
        "https://img01.enty.jp/uploads/entertainer/wallpaper/2044/post_show_enty_top.png",
      )

      should be_page_url(
        "https://enty.jp/posts/141598",
        "https://enty.jp/en/posts/141598",
        "https://enty.jp/posts/141598?ref=newest_post_pc",
      )

      should be_profile_url(
        "https://enty.jp/kouyoumatsunaga?active_tab=posts#2",
      )
    end

    should parse_url("https://img01.enty.jp/uploads/post/thumbnail/141598/post_show_b6c7d85c-b63c-4950-9152-e4bf30678022.png").into(site_name: "Enty")
  end
end
