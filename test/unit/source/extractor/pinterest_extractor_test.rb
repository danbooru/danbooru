require "test_helper"

module Source::Tests::Extractor
  class PinterestExtractorTest < ActiveSupport::TestCase
    context "A pinimg.com sample image" do
      strategy_should_work(
        "https://i.pinimg.com/736x/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.jpg",
        image_urls: ["https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png"],
        media_files: [{ file_size: 465_970 }],
        page_url: nil,
        profile_url: nil,
        display_name: nil,
        username: nil,
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A pinimg.com original image" do
      strategy_should_work(
        "https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png",
        image_urls: ["https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png"],
        media_files: [{ file_size: 465_970 }],
        page_url: nil,
        profile_url: nil,
        display_name: nil,
        username: nil,
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
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
        display_name: "Arty EDO",
        username: "EDO_ARTY",
        tag_name: "edo_arty",
        other_names: ["Arty EDO", "EDO_ARTY"],
        dtext_artist_commentary_title: "Flat_Head Boy Naruto Fanart Naruto Anime",
        dtext_artist_commentary_desc: "",
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
        display_name: nil,
        username: nil,
        other_names: [],
        dtext_artist_commentary_title: "",
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
        tags: [],
        dtext_artist_commentary_title: "X. It’s what’s happening",
        dtext_artist_commentary_desc: "From breaking news and entertainment to sports and politics, get the full story with all the live commentary.",
      )
    end
  end
end
