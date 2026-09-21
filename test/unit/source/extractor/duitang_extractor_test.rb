require "test_helper"

module Source::Tests::Extractor
  class DuitangExtractorTest < ActiveSupport::ExtractorTestCase
    context "A https://www.duitang.com/blog/?id=:id url" do
      strategy_should_work(
        "https://www.duitang.com/blog/?id=1026135391",
        image_urls: %w[https://a-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.jpg],
        media_files: [{ file_size: 463_527 }],
        page_url: "https://www.duitang.com/blog/?id=1026135391",
        profile_url: "https://www.duitang.com/people/?id=9044306",
        profile_urls: %w[https://www.duitang.com/people/?id=9044306],
        display_name: "三月间矛盾体",
        username: nil,
        published_at: Time.parse("2018-12-02T14:06:13.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "希尔 崩坏3 ask",
      )
    end

    context "A dtstatic.com image url" do
      strategy_should_work(
        "https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.thumb.400_0.jpg",
        image_urls: %w[https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.jpg],
        media_files: [{ file_size: 463_527 }],
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

    context "A dtstatic.com avatar url" do
      strategy_should_work(
        "https://c-ssl.dtstatic.com/uploads/avatar/202012/15/20201215234506_75e25.thumb.200_200_c.jpg",
        image_urls: %w[https://c-ssl.dtstatic.com/uploads/avatar/202012/15/20201215234506_75e25.jpg],
        media_files: [{ file_size: 189_655 }],
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
  end
end
