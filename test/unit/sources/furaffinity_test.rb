require "test_helper"

module Sources
  class FuraffinityTest < ActiveSupport::TestCase
    context "A furaffinity post" do
      strategy_should_work(
        "https://www.furaffinity.net/view/46821705/",
        image_urls: ["https://d.furaffinity.net/art/iwbitu/1650222955/1650222955.iwbitu_yubi.jpg"],
        profile_url: "https://www.furaffinity.net/user/iwbitu",
        page_url: "https://www.furaffinity.net/view/46821705",
        artist_name: "iwbitu",
        artist_commentary_title: "Yubi",
        artist_commentary_desc: /little gift doodle for/
      )
    end

    context "A furaffinity image" do
      strategy_should_work(
        "https://d.furaffinity.net/art/iwbitu/1650222955/1650222955.iwbitu_yubi.jpg",
        image_urls: ["https://d.furaffinity.net/art/iwbitu/1650222955/1650222955.iwbitu_yubi.jpg"],
        profile_url: "https://www.furaffinity.net/user/iwbitu",
        artist_name: "iwbitu",
        page_url: nil,
        artist_commentary_title: nil
      )
    end

    context "An adult age-restricted furaffinity post" do
      strategy_should_work(
        "https://www.furaffinity.net/view/46590097/",
        image_urls: ["https://d.furaffinity.net/art/iwbitu/1648803766/1648803766.iwbitu_nyopu_tori.jpg"],
        profile_url: "https://www.furaffinity.net/user/iwbitu",
        page_url: "https://www.furaffinity.net/view/46590097",
        artist_name: "iwbitu",
        tags: [],
        artist_commentary_title: "Nyopu and Tori",
        artist_commentary_desc: /UwU/
      )
    end

    context "A deleted or non-existing furaffinity post" do
      strategy_should_work("https://www.furaffinity.net/view/3404111", deleted: true, profile_url: nil)
    end

    context "A furaffinity post with non-ascii image url" do
      strategy_should_work(
        "https://www.furaffinity.net/view/20762907/",
        image_urls: ["https://d.furaffinity.net/art/fhedge/1470365580/1470365580.fhedge_ミストランサーまとめアートボード_1.jpg"]
      )
    end

    context "A furaffinity post with relative URLs in the commentary" do
      strategy_should_work(
        "https://www.furaffinity.net/view/24228367",
        image_urls: ["https://d.furaffinity.net/art/mazen234/1500679554/1500679554.mazen234_foxgirl.png"],
        artist_name: "mazen234",
        artist_commentary_title: "Miko Sleeping at the beach~",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Mikey went to get some things from the shop, so Miko probably took some time to herself to rest! Not saying Mikey might be a handful sometimes :P

          Glad you loved this piece, Sheep! ^_^

          Miko @ The Lovely "silentsheep silentsheep":[https://www.furaffinity.net/user/silentsheep]

          Art @ CuteSexyRoButts from DeviantArt
        EOS
      )
    end

    should "Parse Furaffinity URLs correctly" do
      assert(Source::URL.image_url?("https://d.furaffinity.net/art/iwbitu/1650222955/1650222955.iwbitu_yubi.jpg"))
      assert(Source::URL.page_url?("https://www.furaffinity.net/view/46821705/"))
      assert(Source::URL.page_url?("https://www.furaffinity.net/full/46821705/"))
      assert(Source::URL.profile_url?("https://www.furaffinity.net/user/iwbitu"))
      assert(Source::URL.profile_url?("https://www.furaffinity.net/gallery/iwbitu"))
      assert(Source::URL.profile_url?("https://www.furaffinity.net/gallery/iwbitu/folder/133763/Regular-commissions"))
      assert(Source::URL.profile_url?("https://www.furaffinity.net/stats/duskmoor/submissions/"))

      assert_equal("https://www.furaffinity.net/view/1234", Source::URL.page_url("https://fxraffinity.net/view/1234"))
      assert_equal("https://www.furaffinity.net/view/1234", Source::URL.page_url("https://fxfuraffinity.net/view/1234"))
      assert_equal("https://www.furaffinity.net/view/1234", Source::URL.page_url("https://vxfuraffinity.net/view/1234"))
      assert_equal("https://www.furaffinity.net/view/1234", Source::URL.page_url("https://xfuraffinity.net/view/1234"))
    end
  end
end
