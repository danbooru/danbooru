require "test_helper"

module Source::Tests::Extractor
  class ZerochanExtractorTest < ActiveSupport::ExtractorTestCase
    context "A SFW post url" do
      strategy_should_work(
        "https://www.zerochan.net/4090352",
        image_urls: %w[https://static.zerochan.net/Kira.Yamato.full.4090352.jpg],
        media_files: [{ file_size: 1_604_018 }],
        page_url: "https://www.zerochan.net/4090352#full",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [
          ["Male", "https://www.zerochan.net/Male"],
          ["Fanart", "https://www.zerochan.net/Fanart"],
          ["Brown Hair", "https://www.zerochan.net/Brown+Hair"],
          ["Purple Eyes", "https://www.zerochan.net/Purple+Eyes"],
          ["Short Hair", "https://www.zerochan.net/Short+Hair"],
          ["Uniform", "https://www.zerochan.net/Uniform"],
          ["Military Uniform", "https://www.zerochan.net/Military+Uniform"],
          ["Kira Yamato", "https://www.zerochan.net/Kira+Yamato"],
          ["Mobile Suit Gundam SEED Destiny", "https://www.zerochan.net/Mobile+Suit+Gundam+SEED+Destiny"],
          ["Mobile Suit Gundam SEED", "https://www.zerochan.net/Mobile+Suit+Gundam+SEED"],
          ["Pixiv", "https://www.zerochan.net/Pixiv"],
          ["Solo", "https://www.zerochan.net/Solo"],
          ["Fanart from Pixiv", "https://www.zerochan.net/Fanart+from+Pixiv"],
          ["ususio 11", "https://www.zerochan.net/ususio+11"],
          ["Kira Yamato (Orb Military Uniform)", "https://www.zerochan.net/Kira+Yamato+%28Orb+Military+Uniform%29"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A NSFW post url" do
      strategy_should_work(
        "http://www.zerochan.net/full/90674",
        image_urls: ["https://static.zerochan.net/Full.Moon.wo.Sagashite.full.90674.jpg"],
        media_files: [{ file_size: 2_600_709 }],
        page_url: "https://www.zerochan.net/90674#full",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [
          ["Female", "https://www.zerochan.net/Female"],
          ["Ecchi", "https://www.zerochan.net/Ecchi"],
          ["Fanart", "https://www.zerochan.net/Fanart"],
          ["Twin Tails", "https://www.zerochan.net/Twin+Tails"],
          ["Wings", "https://www.zerochan.net/Wings"],
          ["Brown Hair", "https://www.zerochan.net/Brown+Hair"],
          ["Red Eyes", "https://www.zerochan.net/Red+Eyes"],
          ["Strawberry", "https://www.zerochan.net/Strawberry"],
          ["Gloves", "https://www.zerochan.net/Gloves"],
          ["Pink Hair", "https://www.zerochan.net/Pink+Hair"],
          ["Hat", "https://www.zerochan.net/Hat"],
          ["Full Moon wo Sagashite", "https://www.zerochan.net/Full+Moon+wo+Sagashite"],
          ["Meroko Yui", "https://www.zerochan.net/Meroko+Yui"],
          ["Usagimimi", "https://www.zerochan.net/Usagimimi"],
          ["Bow (Fashion)", "https://www.zerochan.net/Bow+%28Fashion%29"],
          ["Two Girls", "https://www.zerochan.net/Two+Girls"],
          ["Black Eyes", "https://www.zerochan.net/Black+Eyes"],
          ["Kemonomimi", "https://www.zerochan.net/Kemonomimi"],
          ["Duo", "https://www.zerochan.net/Duo"],
          ["Text", "https://www.zerochan.net/Text"],
          ["Red Gloves", "https://www.zerochan.net/Red+Gloves"],
          ["Japanese Text", "https://www.zerochan.net/Japanese+Text"],
          ["Hat Bow", "https://www.zerochan.net/Hat+Bow"],
          ["Kouyama Mitsuki", "https://www.zerochan.net/Kouyama+Mitsuki"],
          ["Red Handwear", "https://www.zerochan.net/Red+Handwear"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted post url" do
      strategy_should_work(
        "https://www.zerochan.net/1",
        deleted: true,
        page_url: "https://www.zerochan.net/1#full",
        image_urls: [],
        tags: [],
      )
    end

    context "A sample url" do
      strategy_should_work(
        "https://static.zerochan.net/Fullmetal.Alchemist.600.2831797.png",
        image_urls: %w[https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png],
        media_files: [{ file_size: 247_504 }],
        page_url: "https://www.zerochan.net/2831797#full",
        profile_urls: [],
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
        dtext_artist_commentary_desc: "",
      )
    end

    context "An image url" do
      strategy_should_work(
        "https://static.zerochan.net/THE.iDOLM%40STER.full.1262006.jpg",
        image_urls: ["https://static.zerochan.net/THE.iDOLM@STER.full.1262006.jpg"],
        page_url: "https://www.zerochan.net/1262006#full",
      )
    end

    context "An old image url" do
      strategy_should_work(
        "http://static.zerochan.net/full/24/13/90674.jpg",
        image_urls: ["https://static.zerochan.net/full/24/13/90674.jpg"],
        media_files: [{ file_size: 2_600_709 }],
        page_url: "https://www.zerochan.net/90674#full",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [
          ["Female", "https://www.zerochan.net/Female"],
          ["Ecchi", "https://www.zerochan.net/Ecchi"],
          ["Fanart", "https://www.zerochan.net/Fanart"],
          ["Twin Tails", "https://www.zerochan.net/Twin+Tails"],
          ["Wings", "https://www.zerochan.net/Wings"],
          ["Brown Hair", "https://www.zerochan.net/Brown+Hair"],
          ["Red Eyes", "https://www.zerochan.net/Red+Eyes"],
          ["Strawberry", "https://www.zerochan.net/Strawberry"],
          ["Gloves", "https://www.zerochan.net/Gloves"],
          ["Pink Hair", "https://www.zerochan.net/Pink+Hair"],
          ["Hat", "https://www.zerochan.net/Hat"],
          ["Full Moon wo Sagashite", "https://www.zerochan.net/Full+Moon+wo+Sagashite"],
          ["Meroko Yui", "https://www.zerochan.net/Meroko+Yui"],
          ["Usagimimi", "https://www.zerochan.net/Usagimimi"],
          ["Bow (Fashion)", "https://www.zerochan.net/Bow+%28Fashion%29"],
          ["Two Girls", "https://www.zerochan.net/Two+Girls"],
          ["Black Eyes", "https://www.zerochan.net/Black+Eyes"],
          ["Kemonomimi", "https://www.zerochan.net/Kemonomimi"],
          ["Duo", "https://www.zerochan.net/Duo"],
          ["Text", "https://www.zerochan.net/Text"],
          ["Red Gloves", "https://www.zerochan.net/Red+Gloves"],
          ["Japanese Text", "https://www.zerochan.net/Japanese+Text"],
          ["Hat Bow", "https://www.zerochan.net/Hat+Bow"],
          ["Kouyama Mitsuki", "https://www.zerochan.net/Kouyama+Mitsuki"],
          ["Red Handwear", "https://www.zerochan.net/Red+Handwear"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An old sample url" do
      strategy_should_work(
        "https://static.zerochan.net/600/24/13/90674.jpg",
        image_urls: ["https://static.zerochan.net/full/24/13/90674.jpg"],
        page_url: "https://www.zerochan.net/90674#full",
      )
    end
  end
end
