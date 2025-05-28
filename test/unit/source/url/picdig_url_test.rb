require "test_helper"

module Source::Tests::URL
  class PicdigUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2021/11/7954f986-e471-4d41-9d06-16a1a695b42d.png",
          "https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/2022/01/141e8e69-d9cd-46ab-9b9b-62fd8a0d6e7e.png",
          "https://picdig.net/images/e2fc48ae-7391-44a3-993a-ce093f797510/45057c9b-2709-4c1f-b00c-d9b44898db98/2022/04/365f52cb-3007-401e-a762-5452d774210d.png",
        ],
        page_urls: [
          "https://picdig.net/ema/projects/9d99151f-6d3e-4084-9cc0-082d386122ca",
        ],
        profile_urls: [
          "https://picdig.net/ema/portfolio",
        ],
      )
    end
  end
end
