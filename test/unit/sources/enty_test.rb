require "test_helper"

module Sources
  class EntyTest < ActiveSupport::TestCase
    context "Enty:" do
      context "A public Enty page URL" do
        strategy_should_work(
          "https://enty.jp/posts/141598?ref=newest_post_pc",
          image_urls: [
            "https://img01.enty.jp/uploads/post/thumbnail/141598/post_show_b6c7d85c-b63c-4950-9152-e4bf30678022.png",
            "https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png",
            %r{https://entyjp\.s3-ap-northeast-1\.amazonaws\.com/uploads/post/attachment/141598/20211227_130_030_100\.png\?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=.+&X-Amz-Date=.+&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=\h+},
          ],
          profile_url: "https://enty.jp/kouyoumatsunaga",
          profile_urls: %w[
            https://fantia.jp/fanclubs/322
            https://kouyoumatsunaga.fanbox.cc
            https://twitter.com/kouyoumatsunaga
            https://www.pixiv.net/users/440400
            https://www.tinami.com/creator/profile/10262
          ],
          page_url: "https://enty.jp/posts/141598",
          display_name: "松永紅葉",
          username: "kouyoumatsunaga",
          other_names: ["松永紅葉", "kouyoumatsunaga"],
          artist_commentary_title: "今日の一枚3127 (1:30+0:30+1:00)",
          dtext_artist_commentary_desc: "",
          tags: [],
        )
      end

      context "A public Enty image URL with a referer" do
        strategy_should_work(
          "https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png",
          referer: "https://enty.jp/posts/141598?ref=newest_post_pc",
          image_urls: %w[
            https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png
          ],
          profile_url: "https://enty.jp/kouyoumatsunaga",
          profile_urls: %w[
            https://fantia.jp/fanclubs/322
            https://kouyoumatsunaga.fanbox.cc
            https://twitter.com/kouyoumatsunaga
            https://www.pixiv.net/users/440400
            https://www.tinami.com/creator/profile/10262
          ],
          page_url: "https://enty.jp/posts/141598",
          display_name: "松永紅葉",
          username: "kouyoumatsunaga",
          other_names: ["松永紅葉", "kouyoumatsunaga"],
          artist_commentary_title: "今日の一枚3127 (1:30+0:30+1:00)",
          dtext_artist_commentary_desc: "",
          tags: [],
        )
      end

      context "A public Enty image URL without a referer" do
        strategy_should_work(
          "https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png",
          image_urls: %w[
            https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png
          ],
          profile_url: nil,
          profile_urls: [],
          page_url: nil,
          display_name: nil,
          username: nil,
          other_names: [],
          artist_commentary_title: nil,
          artist_commentary_desc: nil,
          tags: []
        )
      end

      should "Parse Enty URLs correctly" do
        assert(Source::URL.image_url?("https://img01.enty.jp/uploads/post/thumbnail/141598/post_show_b6c7d85c-b63c-4950-9152-e4bf30678022.png"))
        assert(Source::URL.image_url?("https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png"))
        assert(Source::URL.image_url?("https://entyjp.s3-ap-northeast-1.amazonaws.com/uploads/post/attachment/141598/20211227_130_030_100.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIMO6YQGDXLXXJKQA%2F20230214%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221225T003003Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=0ecb359544a7c8a3569aef5162e482664e1c7d98412dfdd445851e3db11523f8"))
        assert(Source::URL.image_url?("https://img01.enty.jp/uploads/entertainer/wallpaper/2044/post_show_enty_top.png"))

        assert(Source::URL.page_url?("https://enty.jp/posts/141598"))
        assert(Source::URL.page_url?("https://enty.jp/en/posts/141598"))
        assert(Source::URL.page_url?("https://enty.jp/posts/141598?ref=newest_post_pc"))

        assert(Source::URL.profile_url?("https://enty.jp/kouyoumatsunaga?active_tab=posts#2"))
      end
    end
  end
end
