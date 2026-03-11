require "test_helper"

module Source::Tests::Extractor
  class PinterestExtractorTest < ActiveSupport::ExtractorTestCase
    context "A pinimg.com sample image" do
      strategy_should_work(
        "https://i.pinimg.com/736x/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.jpg",
        image_urls: %w[https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png],
        media_files: [{ file_size: 465_970 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A pinimg.com original image" do
      strategy_should_work(
        "https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png",
        image_urls: %w[https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png],
        media_files: [{ file_size: 465_970 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Pinterest native pin" do
      strategy_should_work(
        "https://www.pinterest.com/pin/1066086543015109244/",
        image_urls: %w[https://i.pinimg.com/originals/d1/8a/d8/d18ad850e89dee4d1297f6a53f32f679.jpg],
        media_files: [{ file_size: 66_293 }],
        page_url: "https://www.pinterest.com/pin/1066086543015109244/",
        profile_urls: %w[https://www.pinterest.com/EDO_ARTY/],
        display_name: "Arty EDO",
        username: "EDO_ARTY",
        published_at: Time.parse("2022-04-10T03:26:09.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "Flat_Head Boy Naruto Fanart Naruto Anime",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Pinterest repin" do
      strategy_should_work(
        "https://www.pinterest.com/pin/668292032234493917/",
        image_urls: %w[https://i.pinimg.com/originals/f3/5a/ba/f35abaea99aa637650b1c395656c18a4.jpg],
        media_files: [{ file_size: 44_003 }],
        page_url: "https://www.pinterest.com/pin/668292032234493917/",
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: Time.parse("2024-04-10T05:34:29.000000Z"),
        updated_at: nil,
        tags: [],
        # dtext_artist_commentary_title: "Purring Meme", # XXX flaky test
        # dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Pinterest pin with a non-numeric ID" do
      strategy_should_work(
        "https://www.pinterest.com/pin/AWmv0p_rB3LBl0lwa6L4DYNr6WTtDB5lPFXvbO-_QmBcRjNUTxY5MTU/",
        image_urls: %w[https://i.pinimg.com/originals/9f/27/6f/9f276f58706ac7b78401115fd59b9ce6.png],
        media_files: [{ file_size: 120_389 }],
        page_url: "https://www.pinterest.com/pin/AWmv0p_rB3LBl0lwa6L4DYNr6WTtDB5lPFXvbO-_QmBcRjNUTxY5MTU/",
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        published_at: Time.parse("2019-04-30T05:44:44.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "Twitter. It's what's happening.",
        dtext_artist_commentary_desc: "From breaking news and entertainment to sports and politics, get the full story with all the live commentary.",
      )
    end

    context "A Pinterest pin with hashtags" do
      strategy_should_work(
        "https://www.pinterest.com/pin/761389880798012681/",
        image_urls: %w[https://i.pinimg.com/originals/3f/cf/fd/3fcffdc71266e99e5bb643c948e6ed26.png],
        media_files: [{ file_size: 2_383_747 }],
        page_url: "https://www.pinterest.com/pin/761389880798012681/",
        profile_urls: %w[https://www.pinterest.com/m0thsis/],
        display_name: "m0thsis",
        username: "m0thsis",
        published_at: Time.parse("2025-02-23T03:15:46.000000Z"),
        updated_at: nil,
        tags: [
          ["haibanerenmei", "https://www.pinterest.com/search/pins/?q=%23haibanerenmei"],
          ["rakka", "https://www.pinterest.com/search/pins/?q=%23rakka"],
          ["lain", "https://www.pinterest.com/search/pins/?q=%23lain"],
          ["lainiwakura", "https://www.pinterest.com/search/pins/?q=%23lainiwakura"],
          ["serialexperimentslain", "https://www.pinterest.com/search/pins/?q=%23serialexperimentslain"],
          ["letsalllovelain", "https://www.pinterest.com/search/pins/?q=%23letsalllovelain"],
          ["milkoutsideabag", "https://www.pinterest.com/search/pins/?q=%23milkoutsideabag"],
          ["milkchan", "https://www.pinterest.com/search/pins/?q=%23milkchan"],
          ["молоковнутрипакета", "https://www.pinterest.com/search/pins/?q=%23молоковнутрипакета"],
          ["милкчан", "https://www.pinterest.com/search/pins/?q=%23милкчан"],
          ["icons", "https://www.pinterest.com/search/pins/?q=%23icons"],
          ["icon", "https://www.pinterest.com/search/pins/?q=%23icon"],
          ["poster", "https://www.pinterest.com/search/pins/?q=%23poster"],
        ],
        dtext_artist_commentary_title: "тгк m0thsis",
        dtext_artist_commentary_desc: "#haibanerenmei #rakka #lain #lainiwakura #serialexperimentslain #letsalllovelain #milkoutsideabag #milkchan #молоковнутрипакета #милкчан #icons #icon #poster",
      )
    end
  end
end
