require "test_helper"

module Sources
  class PinterestTest < ActiveSupport::TestCase
    context "Pinterest:" do
      context "A pinimg.com sample image" do
        strategy_should_work(
          "https://i.pinimg.com/736x/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.jpg",
          image_urls: ["https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png"],
          media_files: [{ file_size: 465_970 }],
          page_url: nil,
          profile_url: nil,
          artist_name: nil,
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A pinimg.com original image" do
        strategy_should_work(
          "https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png",
          image_urls: ["https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png"],
          media_files: [{ file_size: 465_970 }],
          page_url: nil,
          profile_url: nil,
          artist_name: nil,
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Pinterest native pin" do
        strategy_should_work(
          "https://www.pinterest.com/pin/1066086543015109244/",
          image_urls: ["https://i.pinimg.com/originals/d1/8a/d8/d18ad850e89dee4d1297f6a53f32f679.jpg"],
          media_files: [{ file_size: 66_293 }],
          page_url: "https://www.pinterest.com/pin/1066086543015109244/",
          profile_url: "https://www.pinterest.com/EDO_ARTY/",
          profile_urls: ["https://www.pinterest.com/EDO_ARTY/"],
          artist_name: "Arty EDO",
          other_names: ["Arty EDO", "EDO_ARTY"],
          dtext_artist_commentary_title: "Flat_Head Boy Naruto Fanart Naruto Anime",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Pinterest repin" do
        strategy_should_work(
          "https://www.pinterest.com/pin/668292032234493917/",
          image_urls: ["https://i.pinimg.com/originals/f3/5a/ba/f35abaea99aa637650b1c395656c18a4.jpg"],
          media_files: [{ file_size: 44_003 }],
          page_url: "https://www.pinterest.com/pin/668292032234493917/",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          other_names: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Pinterest pin with a non-numeric ID" do
        strategy_should_work(
          "https://www.pinterest.com/pin/AVBZICDCT7hRTla-jHiJ6w2eVUK1wuq7WRYG8P_uqZIziXisjxatHMA/",
          image_urls: ["https://i.pinimg.com/originals/2e/7a/35/2e7a35193c293902b896863a7f7d2a18.jpg"],
          media_files: [{ file_size: 171_954 }],
          page_url: "https://www.pinterest.com/pin/AVBZICDCT7hRTla-jHiJ6w2eVUK1wuq7WRYG8P_uqZIziXisjxatHMA/",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          other_names: [],
          dtext_artist_commentary_title: "となみ (@tona_bnkz) on Twitter",
          dtext_artist_commentary_desc: "Embedded"
        )
      end

      should "Parse Pinterest URLs correctly" do
        assert(Source::URL.image_url?("https://i.pinimg.com/736x/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.jpg"))
        assert(Source::URL.image_url?("https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png"))

        assert(Source::URL.page_url?("https://pinterest.com/pin/551409548144250908/"))
        assert(Source::URL.page_url?("https://www.pinterest.com/pin/551409548144250908/"))
        assert(Source::URL.page_url?("https://www.pinterest.jp/pin/551409548144250908/"))
        assert(Source::URL.page_url?("https://www.pinterest.co.uk/pin/551409548144250908/"))
        assert(Source::URL.page_url?("https://jp.pinterest.com/pin/551409548144250908/"))

        assert(Source::URL.page_url?("https://www.pinterest.com/pin/AVBZICDCT7hRTla-jHiJ6w2eVUK1wuq7WRYG8P_uqZIziXisjxatHMA/"))
        assert(Source::URL.page_url?("https://www.pinterest.com/pin/580612576989556785/sent/?invite_code=9e94baa7faae405d84a7787593fa46fd&sender=580612714368486682&sfo=1"))
        assert(Source::URL.page_url?("https://www.pinterest.co.uk/pin/super-mario--600175087827955508/"))

        assert(Source::URL.profile_url?("https://pinterest.com/uchihajake/"))
        assert(Source::URL.profile_url?("https://www.pinterest.com/uchihajake/"))
        assert(Source::URL.profile_url?("https://www.pinterest.com/uchihajake/_created"))

        assert(Source::URL.profile_url?("https://www.pinterest.ph/uchihajake/"))
        assert(Source::URL.profile_url?("https://www.pinterest.jp/uchihajake/"))
        assert(Source::URL.profile_url?("https://www.pinterest.com.mx/uchihajake/"))
        assert(Source::URL.profile_url?("https://www.pinterest.co.uk/uchihajake/"))
        assert(Source::URL.profile_url?("https://pl.pinterest.com/uchihajake/"))
        assert(Source::URL.profile_url?("https://www.pinterest.jp/totikuma/自作イラスト-my-illustrations/"))

        assert_not(Source::URL.profile_url?("https://www.pinterest.com/ideas/people/935950727927/"))
        assert_not(Source::URL.profile_url?("https://api.pinterest.com/url_shortener/4A1N0Rd5W/redirect/"))
      end
    end
  end
end
