require "test_helper"

module Source::Tests::URL
  class PinterestUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://i.pinimg.com/736x/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.jpg",
          "https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png",
        ],
        page_urls: [
          "https://pinterest.com/pin/551409548144250908/",
          "https://www.pinterest.com/pin/551409548144250908/",
          "https://www.pinterest.jp/pin/551409548144250908/",
          "https://www.pinterest.co.uk/pin/551409548144250908/",
          "https://jp.pinterest.com/pin/551409548144250908/",
          "https://www.pinterest.com/pin/AVBZICDCT7hRTla-jHiJ6w2eVUK1wuq7WRYG8P_uqZIziXisjxatHMA/",
          "https://www.pinterest.com/pin/580612576989556785/sent/?invite_code=9e94baa7faae405d84a7787593fa46fd&sender=580612714368486682&sfo=1",
          "https://www.pinterest.co.uk/pin/super-mario--600175087827955508/",
        ],
        profile_urls: [
          "https://pinterest.com/uchihajake/",
          "https://www.pinterest.com/uchihajake/",
          "https://www.pinterest.com/uchihajake/_created",
          "https://www.pinterest.ph/uchihajake/",
          "https://www.pinterest.jp/uchihajake/",
          "https://www.pinterest.com.mx/uchihajake/",
          "https://www.pinterest.co.uk/uchihajake/",
          "https://pl.pinterest.com/uchihajake/",
          "https://www.pinterest.jp/totikuma/自作イラスト-my-illustrations/",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://www.pinterest.com/ideas/people/935950727927/",
          "https://api.pinterest.com/url_shortener/4A1N0Rd5W/redirect/",
        ],
      )
    end
  end
end
