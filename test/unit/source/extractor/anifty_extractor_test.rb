require "test_helper"

module Source::Tests::Extractor
  class AniftyExtractorTest < ActiveSupport::TestCase
    context "An anifty post" do
      strategy_should_work(
        "https://anifty.jp/ja/creations/1500",
        image_urls: ["https://storage.googleapis.com/anifty-media/creation/0x0913be22dd08f7e092e00d4f8c2f61778dc6df94/a5bb2c63b8a602aba6cfd93d2147bef23b6b9bc2.jpg"],
        profile_url: "https://anifty.jp/@inamihatoko",
        page_url: "https://anifty.jp/creations/1500",
        display_name: "inami hatoko",
        username: "inamihatoko",
        other_names: ["inami hatoko", "inamihatoko", "井波ハトコ"],
        tags: ["background", "girl"],
        artist_commentary_title: "Escape",
        artist_commentary_desc: "Let's get out of there.",
      )
    end

    context "An anifty image hosted on imgix" do
      strategy_should_work(
        "https://anifty.imgix.net/creation/0x9942a21fdc78fe2c3973d219a1d705a4efd056b4/22f4c9694dd2f1f32b610d1d75a18621c5c2d6d8.jpg?w=3840&q=undefined&auto=compress",
        image_urls: %w[https://storage.googleapis.com/anifty-media/creation/0x9942a21fdc78fe2c3973d219a1d705a4efd056b4/22f4c9694dd2f1f32b610d1d75a18621c5c2d6d8.jpg],
        media_files: [{ file_size: 20_607_538 }],
        page_url: nil,
        profile_urls: %w[https://anifty.jp/@unagi189],
        display_name: "yunagi",
        username: "unagi189",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An anifty image hosted on googleapis" do
      strategy_should_work(
        "https://storage.googleapis.com/anifty-media/profile/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/a6d2c366a3e876ddbf04fc269b63124be18af424.png",
        image_urls: ["https://storage.googleapis.com/anifty-media/profile/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/a6d2c366a3e876ddbf04fc269b63124be18af424.png"],
        profile_url: "https://anifty.jp/@hightree",
        page_url: nil,
        display_name: "Knoy Konome",
        username: "hightree",
        other_names: ["Knoy Konome", "hightree", "木芽のい"],
        tags: [],
        artist_commentary_title: nil,
        artist_commentary_desc: nil,
      )
    end

    context "A deleted or non-existing anifty post" do
      strategy_should_work("https://anifty.jp/zh/creations/373123123", deleted: true, profile_url: nil)
    end
  end
end
