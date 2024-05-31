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
          image_urls: %w[https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png],
          media_files: [{ file_size: 247_504 }],
          page_url: "https://www.zerochan.net/2831797#full",
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tags: [
            ["Male", "https://www.zerochan.net/Male"],
            ["Fanart", "https://www.zerochan.net/Fanart"],
            ["Monochrome", "https://www.zerochan.net/Monochrome"],
            ["Long Hair", "https://www.zerochan.net/Long+Hair"],
            ["Black Hair", "https://www.zerochan.net/Black+Hair"],
            ["Short Hair", "https://www.zerochan.net/Short+Hair"],
            ["Happy", "https://www.zerochan.net/Happy"],
            ["Shoes", "https://www.zerochan.net/Shoes"],
            ["Fullmetal Alchemist", "https://www.zerochan.net/Fullmetal+Alchemist"],
            ["Jacket", "https://www.zerochan.net/Jacket"],
            ["Top", "https://www.zerochan.net/Top"],
            ["Sweatdrop", "https://www.zerochan.net/Sweatdrop"],
            ["Pants", "https://www.zerochan.net/Pants"],
            ["Open Mouth", "https://www.zerochan.net/Open+Mouth"],
            ["Muscles", "https://www.zerochan.net/Muscles"],
            ["Grin", "https://www.zerochan.net/Grin"],
            ["Teeth", "https://www.zerochan.net/Teeth"],
            ["Ling Yao", "https://www.zerochan.net/Ling+Yao"],
            ["Spiky Hair", "https://www.zerochan.net/Spiky+Hair"],
            ["Fullmetal Alchemist Brotherhood", "https://www.zerochan.net/Fullmetal+Alchemist+Brotherhood"],
            ["Greed (FMA)", "https://www.zerochan.net/Greed+%28FMA%29"],
            ["Vest", "https://www.zerochan.net/Vest"],
            ["Waving", "https://www.zerochan.net/Waving"],
            ["Standing", "https://www.zerochan.net/Standing"],
            ["Smile", "https://www.zerochan.net/Smile"],
            ["Smirk", "https://www.zerochan.net/Smirk"],
            ["KANapy", "https://www.zerochan.net/KANapy"],
            ["Open Clothes", "https://www.zerochan.net/Open+Clothes"],
            ["Open Jacket", "https://www.zerochan.net/Open+Jacket"],
            ["Sleeveless", "https://www.zerochan.net/Sleeveless"],
            ["Homunculi", "https://www.zerochan.net/Homunculi"],
            ["Looking At Camera", "https://www.zerochan.net/Looking+At+Camera"],
            ["Hungry", "https://www.zerochan.net/Hungry"],
            ["Black Pants", "https://www.zerochan.net/Black+Pants"],
            ["Sleeveless Top", "https://www.zerochan.net/Sleeveless+Top"],
            ["Xing Country", "https://www.zerochan.net/Xing+Country"],
            ["Full Body", "https://www.zerochan.net/Full+Body"],
            ["Open Vest", "https://www.zerochan.net/Open+Vest"],
            ["X (Twitter)", "https://www.zerochan.net/X+%28Twitter%29"],
            ["Exposed Shoulders", "https://www.zerochan.net/Exposed+Shoulders"],
            ["Confidence", "https://www.zerochan.net/Confidence"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
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
