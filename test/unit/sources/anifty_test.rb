require "test_helper"

module Sources
  class AniftyTest < ActiveSupport::TestCase
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
        artist_commentary_desc: "Let's get out of there."
      )
    end

    context "An anifty image hosted on imgix" do
      strategy_should_work(
        "https://anifty.imgix.net/creation/0x9942a21fdc78fe2c3973d219a1d705a4efd056b4/22f4c9694dd2f1f32b610d1d75a18621c5c2d6d8.jpg?w=3840&q=undefined&auto=compress",
        image_urls: ["https://storage.googleapis.com/anifty-media/creation/0x9942a21fdc78fe2c3973d219a1d705a4efd056b4/22f4c9694dd2f1f32b610d1d75a18621c5c2d6d8.jpg"],
        profile_url: "https://anifty.jp/@unagi189",
        page_url: "https://anifty.jp/creations/1585",
        display_name: "yunagi",
        username: "unagi189",
        other_names: ["yunagi", "unagi189"],
        tags: ["background", "girl", "uniform"],
        artist_commentary_title: "Sound!",
        artist_commentary_desc: "This work was created in 2017 and partially modified for exhibition.I created this work with the image of after-school for the girls in the brass band."
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
        artist_commentary_desc: nil
      )
    end

    context "A deleted or non-existing anifty post" do
      strategy_should_work("https://anifty.jp/zh/creations/373123123", deleted: true, profile_url: nil)
    end

    should "Parse Anifty URLs correctly" do
      assert(Source::URL.image_url?("https://anifty.imgix.net/creation/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/20d5ce5b5163a71258e1d0ee152a0347bf40c7da.png?w=660&h=660&fit=crop&crop=focalpoint&fp-x=0.76&fp-y=0.5&fp-z=1&auto=compress"))
      assert(Source::URL.image_url?("https://storage.googleapis.com/anifty-media/creation/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/20d5ce5b5163a71258e1d0ee152a0347bf40c7da.png"))
      assert(Source::URL.page_url?("https://anifty.jp/creations/373"))
      assert(Source::URL.profile_url?("https://anifty.jp/@hightree"))
    end
  end
end
