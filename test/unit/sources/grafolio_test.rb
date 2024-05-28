# frozen_string_literal: true

require "test_helper"

module Sources
  class GrafolioTest < ActiveSupport::TestCase
    context "Grafolio:" do
      context "A thumbnail URL" do
        strategy_should_work(
          "https://files.grafolio.ogq.me/preview/v1/content/real/8b0d026e01fc4affa9a2f232388b0edf/IMAGE/e0180515-9d3a-412e-a09b-8a55e78b282e.png?type=THUMBNAIL",
          image_urls: %w[https://files.grafolio.ogq.me/real/8b0d026e01fc4affa9a2f232388b0edf/IMAGE/e0180515-9d3a-412e-a09b-8a55e78b282e.png],
          media_files: [{ file_size: 6_047_661 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A full image URL" do
        strategy_should_work(
          "https://files.grafolio.ogq.me/real/566beece588b3/IMAGE/cb2c9f31-44f4-4d6a-9630-6476b5234ce6.gif",
          image_urls: %w[https://files.grafolio.ogq.me/real/566beece588b3/IMAGE/cb2c9f31-44f4-4d6a-9630-6476b5234ce6.gif],
          media_files: [{ file_size: 8_891_325 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A cover image URL" do
        strategy_should_work(
          "https://preview.files.api.ogq.me/v1/cover/MEDIUM/NEW-PROFILE_COVER/8fa37d34/60d7843d73af8/b407e9c70b284e559816d5e787823ee2.png",
          image_urls: %w[https://preview.files.api.ogq.me/v1/cover/MEDIUM/NEW-PROFILE_COVER/8fa37d34/60d7843d73af8/b407e9c70b284e559816d5e787823ee2.png],
          media_files: [{ file_size: 249_184 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A project URL" do
        strategy_should_work(
          "https://grafolio.ogq.me/project/detail/1753d7a25ae146dc9f86d8a93217baa1",
          image_urls: %w[https://files.grafolio.ogq.me/real/56ea56156e18e/IMAGE/ebd0fce0-1853-4987-b347-221e22966b1a.png],
          media_files: [{ file_size: 1_339_697 }],
          page_url: "https://grafolio.ogq.me/project/detail/1753d7a25ae146dc9f86d8a93217baa1",
          profile_urls: %w[https://grafolio.ogq.me/profile/soupbowlstudio/projects],
          display_name: nil,
          username: "soupbowlstudio",
          tags: [],
          dtext_artist_commentary_title: "기차",
          dtext_artist_commentary_desc: <<~EOS.chomp
            뭔가 삶이 기차 같다는 생각이 들어서 그린그림

            자글자글하 구절초를 그리느라 꽤나 고생했지만

            다그리고 나니 뿌듯하다

            종점을 향해 달려가는 우리들...

            잠시 고개를 들어 창밖의 풍경도 들여다보는

            그런 일상이기를 바라본다

            인스타 팔로우 해주세요!

            "[u]https://www.instagram.com/soupbowl_studio/[/u]":[https://www.instagram.com/soupbowl_studio/]
          EOS
        )
      end

      context "A deleted or nonexistent project" do
        strategy_should_work(
          "https://grafolio.ogq.me/project/detail/999999999",
          image_urls: [],
          page_url: "https://grafolio.ogq.me/project/detail/999999999",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://files.grafolio.ogq.me/preview/v1/content/real/566beece588b3/IMAGE/4718c558-2de0-442f-bbd8-54428c4fae7c.jpg?type=THUMBNAIL"))
        assert(Source::URL.image_url?("https://files.grafolio.ogq.me/real/566beece588b3/IMAGE/cb2c9f31-44f4-4d6a-9630-6476b5234ce6.gif"))
        assert(Source::URL.image_url?("https://files.grafolio.ogq.me/real/8b0d026e01fc4affa9a2f232388b0edf/IMAGE/e0180515-9d3a-412e-a09b-8a55e78b282e.png"))
        assert(Source::URL.image_url?("https://preview.files.api.ogq.me/v1/profile/LARGE/NEW-PROFILE/e8dce1f7/60e527f1ecd8e/b3f7f23745594ad19c5f26386110d6d8.png"))
        assert(Source::URL.image_url?("https://preview.files.api.ogq.me/v1/cover/MEDIUM/NEW-PROFILE_COVER/8fa37d34/60d7843d73af8/b407e9c70b284e559816d5e787823ee2.png"))

        assert(Source::URL.page_url?("https://grafolio.ogq.me/project/detail/ccb07e90bdce4a868737abfca5136413"))

        assert(Source::URL.profile_url?("https://grafolio.ogq.me/profile/리니/projects"))
        assert(Source::URL.profile_url?("https://grafolio.ogq.me/profile/리니/like"))
      end
    end
  end
end
