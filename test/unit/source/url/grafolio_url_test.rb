require "test_helper"

module Source::Tests::URL
  class GrafolioUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://files.grafolio.ogq.me/preview/v1/content/real/566beece588b3/IMAGE/4718c558-2de0-442f-bbd8-54428c4fae7c.jpg?type=THUMBNAIL",
          "https://files.grafolio.ogq.me/real/566beece588b3/IMAGE/cb2c9f31-44f4-4d6a-9630-6476b5234ce6.gif",
          "https://files.grafolio.ogq.me/real/8b0d026e01fc4affa9a2f232388b0edf/IMAGE/e0180515-9d3a-412e-a09b-8a55e78b282e.png",
          "https://preview.files.api.ogq.me/v1/profile/LARGE/NEW-PROFILE/e8dce1f7/60e527f1ecd8e/b3f7f23745594ad19c5f26386110d6d8.png",
          "https://preview.files.api.ogq.me/v1/cover/MEDIUM/NEW-PROFILE_COVER/8fa37d34/60d7843d73af8/b407e9c70b284e559816d5e787823ee2.png",
        ],
        page_urls: [
          "https://grafolio.ogq.me/project/detail/ccb07e90bdce4a868737abfca5136413",
        ],
        profile_urls: [
          "https://grafolio.ogq.me/profile/리니/projects",
          "https://grafolio.ogq.me/profile/리니/like",
        ],
      )
    end
  end
end
