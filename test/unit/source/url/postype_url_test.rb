require "test_helper"

module Source::Tests::URL
  class PostypeUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://d3mcojo3jv0dbr.cloudfront.net/2021/03/19/20/57/7e8c74bfe4a77f6a037ed8b02194955c.webp?w=240&h=180&q=65",
          "https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg",
          "https://i.postype.com/2017/01/27/01/28/22c423dd569a1c2aaec66bc551c54d5b.png?w=1000",
          "https://c3.postype.com/2017/07/04/21/29/42fc32581770dd593788cce89652f757.png",
          "https://www.postype.com/_next/image?url=https%3A%2F%2Fd3mcojo3jv0dbr.cloudfront.net%2F2024%2F04%2F03%2F12%2F46%2F1ffb36f1881b16a5c5881fc6eaa06179.jpeg%3Fw%3D1000%26h%3D700%26q%3D65&w=3840&q=75",
        ],
        page_urls: [
          "https://luland.postype.com/post/11659399",
          "https://www.postype.com/@fruitsnoir/post/5316533",
        ],
        profile_urls: [
          "https://luland.postype.com",
          "https://luland.postype.com/posts",
          "https://www.postype.com/profile/@ep58bc",
          "https://www.postype.com/profile/@ep58bc/posts",
          "https://www.postype.com/@fruitsnoir",
          "https://www.postype.com/@fruitsnoir/post",
        ],
      )
    end
  end
end
