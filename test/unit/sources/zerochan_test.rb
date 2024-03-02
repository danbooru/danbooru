require "test_helper"

module Sources
  class ZerochanTest < ActiveSupport::TestCase
    context "Zerochan:" do
      context "A SFW post url" do
        strategy_should_work(
          "https://www.zerochan.net/4090352",
          image_urls: ["https://static.zerochan.net/Kira.Yamato.full.4090352.jpg"],
          page_url: "https://www.zerochan.net/4090352#full",
          tags: ["Male", "Fanart", "Brown Hair", "Purple Eyes", "Short Hair", "Kira Yamato", "Mobile Suit Gundam SEED Destiny", "Mobile Suit Gundam SEED", "Pixiv", "Solo", "Fanart from Pixiv", "ususio 11"]
        )
      end

      context "A NSFW post url" do
        strategy_should_work(
          "http://www.zerochan.net/full/90674",
          image_urls: ["https://static.zerochan.net/Full.Moon.wo.Sagashite.full.90674.jpg"],
          page_url: "https://www.zerochan.net/90674#full",
          tags: [
            "Female", "Ecchi", "Fanart", "Twin Tails", "Wings", "Brown Hair",
            "Red Eyes", "Strawberry", "Gloves", "Pink Hair", "Hat",
            "Full Moon wo Sagashite", "Meroko Yui", "Usagimimi", "Bows (Fashion)",
            "Two Girls", "Black Eyes", "Kemonomimi", "Duo", "Text", "Red Gloves",
            "Japanese Text", "Hat Bow", "Kouyama Mitsuki", "Red Handwear",
          ]
        )
      end

      context "A deleted post url" do
        strategy_should_work(
          "https://www.zerochan.net/1",
          deleted: true,
          page_url: "https://www.zerochan.net/1#full",
          image_urls: [],
          tags: []
        )
      end
      context "A sample url" do
        strategy_should_work(
          "https://static.zerochan.net/Fullmetal.Alchemist.600.2831797.png",
          image_urls: ["https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png"],
          page_url: "https://www.zerochan.net/2831797#full",
          tags: [
            "Male", "Fanart", "Monochrome", "Long Hair", "Black Hair", "Short Hair",
            "Happy", "Shoes", "Fullmetal Alchemist", "Jacket", "Top", "Sweatdrop",
            "Pants", "Open Mouth", "Muscles", "Grin", "Teeth", "Ling Yao", "Spiky Hair",
            "Fullmetal Alchemist Brotherhood", "Greed (FMA)", "Vest", "Waving", "Standing",
            "Smile", "Smirk", "KANapy", "Open Clothes", "Open Jacket", "Sleeveless", "Homunculi",
            "Looking At Camera", "Hungry", "Black Pants", "Sleeveless Top", "Xing Country",
            "Full Body", "Open Vest", "Twitter", "Exposed Shoulders", "Confidence",
          ]
        )
      end

      context "An image url" do
        strategy_should_work(
          "https://static.zerochan.net/THE.iDOLM%40STER.full.1262006.jpg",
          image_urls: ["https://static.zerochan.net/THE.iDOLM@STER.full.1262006.jpg"],
          page_url: "https://www.zerochan.net/1262006#full"
        )
      end

      context "An old image url" do
        strategy_should_work(
          "http://static.zerochan.net/full/24/13/90674.jpg",
          image_urls: ["https://static.zerochan.net/full/24/13/90674.jpg"],
          page_url: "https://www.zerochan.net/90674#full",
          tags: [
            "Female", "Ecchi", "Fanart", "Twin Tails", "Wings", "Brown Hair",
            "Red Eyes", "Strawberry", "Gloves", "Pink Hair", "Hat",
            "Full Moon wo Sagashite", "Meroko Yui", "Usagimimi", "Bows (Fashion)",
            "Two Girls", "Black Eyes", "Kemonomimi", "Duo", "Text", "Red Gloves",
            "Japanese Text", "Hat Bow", "Kouyama Mitsuki", "Red Handwear",
          ]
        )
      end

      context "An old sample url" do
        strategy_should_work(
          "https://static.zerochan.net/600/24/13/90674.jpg",
          image_urls: ["https://static.zerochan.net/full/24/13/90674.jpg"],
          page_url: "https://www.zerochan.net/90674#full"
        )
      end

      should "Parse Zerochan URLs correctly" do
        assert(Source::URL.image_url?("https://s4.zerochan.net/600/24/13/90674.jpg"))
        assert(Source::URL.image_url?("http://static.zerochan.net/full/24/13/90674.jpg"))
        assert(Source::URL.image_url?("https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png"))
        assert(Source::URL.image_url?("https://static.zerochan.net/THE.iDOLM%40STER.full.1262006.jpg"))
        assert(Source::URL.image_url?("https://static.zerochan.net/Lancer.(Fate.stay.night).full.2600383.jpg"))

        assert(Source::URL.page_url?("http://www.zerochan.net/full/1567893"))
        assert(Source::URL.page_url?("http://www.zerochan.net/1567893"))
        assert(Source::URL.page_url?("http://www.zerochan.net/1567893#full"))

        assert_equal("1567893", Source::URL.parse("http://www.zerochan.net/full/1567893").work_id)
        assert_equal("1567893", Source::URL.parse("http://www.zerochan.net/1567893").work_id)
        assert_equal("1567893", Source::URL.parse("http://www.zerochan.net/1567893#full").work_id)

        assert_equal("2831797", Source::URL.parse("https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png").work_id)
        assert_equal("90674", Source::URL.parse("https://s4.zerochan.net/600/24/13/90674.jpg").work_id)
        assert_equal("2600383", Source::URL.parse("https://static.zerochan.net/Lancer.(Fate.stay.night).full.2600383.jpg").work_id)
      end
    end
  end
end
