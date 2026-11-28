require "test_helper"

module Source::Tests::Extractor
  class PixelJointExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Pixel Joint full image URL" do
      strategy_should_work(
        "https://pixeljoint.com/files/icons/full/cat__r16042437891.png",
        image_urls: %w[https://pixeljoint.com/files/icons/full/cat__r16042437891.png],
        media_files: [{ file_size: 6_171 }],
        page_url: nil,
        profile_url: nil,
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

    context "A Pixel Joint full image URL with a referer" do
      strategy_should_work(
        "https://pixeljoint.com/files/icons/full/cat__r16042437891.png",
        referer: "https://pixeljoint.com/pixelart/165655.htm",
        image_urls: %w[https://pixeljoint.com/files/icons/full/cat__r16042437891.png],
        media_files: [{ file_size: 6_171 }],
        page_url: "https://pixeljoint.com/pixelart/165655.htm",
        profile_url: "https://pixeljoint.com/p/243789.htm",
        profile_urls: %w[https://pixeljoint.com/p/243789.htm],
        display_name: nil,
        username: "CJDMAX",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["Misc", "https://pixeljoint.com/pixelart/2003/Miscellaneous.htm"],
        ],
        dtext_artist_commentary_title: "cat",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Pixel Joint thumbnail URL" do
      strategy_should_work(
        "https://pixeljoint.com/files/icons/cat_icon.png",
        image_urls: %w[https://pixeljoint.com/files/icons/cat_icon.png],
        media_files: [{ file_size: 2_567 }],
        page_url: nil,
        profile_url: nil,
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

    context "A Pixel Joint post" do
      strategy_should_work(
        "https://pixeljoint.com/pixelart/165655.htm",
        image_urls: %w[https://pixeljoint.com/files/icons/full/cat__r16042437891.png],
        media_files: [{ file_size: 6_171 }],
        page_url: "https://pixeljoint.com/pixelart/165655.htm",
        profile_url: "https://pixeljoint.com/p/243789.htm",
        profile_urls: %w[https://pixeljoint.com/p/243789.htm],
        display_name: nil,
        username: "CJDMAX",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["Misc", "https://pixeljoint.com/pixelart/2003/Miscellaneous.htm"],
        ],
        dtext_artist_commentary_title: "cat",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Pixel Joint post with multiple categories" do
      strategy_should_work(
        "https://pixeljoint.com/pixelart/165296.htm",
        image_urls: %w[https://pixeljoint.com/files/icons/full/png001.png],
        media_files: [{ file_size: 1_520 }],
        page_url: "https://pixeljoint.com/pixelart/165296.htm",
        profile_url: "https://pixeljoint.com/p/243789.htm",
        profile_urls: %w[https://pixeljoint.com/p/243789.htm],
        display_name: nil,
        username: "CJDMAX",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["Weekly Challenges Only", "https://pixeljoint.com/pixelart/2341/Weekly_Challenges_Only.htm"],
          ["Misc", "https://pixeljoint.com/pixelart/2003/Miscellaneous.htm"],
        ],
        dtext_artist_commentary_title: "chanllenge",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A nonexistent Pixel Joint post" do
      strategy_should_work(
        "https://pixeljoint.com/pixelart/999999999.htm",
        image_urls: [],
        page_url: "https://pixeljoint.com/pixelart/999999999.htm",
        profile_url: nil,
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
  end
end
