require "test_helper"

module Source::Tests::Extractor
  class DotpictExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Dotpict sample image URL" do
      strategy_should_work(
        "https://img.dotpicko.net/thumbnail_work/2023/06/09/20/57/thumb_e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.png",
        image_urls: %w[https://img.dotpicko.net/work/2023/06/09/20/57/e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.gif],
        media_files: [{ file_size: 41_780 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Dotpict full image URL" do
      strategy_should_work(
        "https://img.dotpicko.net/work/2023/06/09/20/57/e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.gif",
        image_urls: %w[https://img.dotpicko.net/work/2023/06/09/20/57/e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.gif],
        media_files: [{ file_size: 41_780 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Dotpict post" do
      strategy_should_work(
        "https://dotpict.net/works/4834127",
        image_urls: %w[https://img.dotpicko.net/work/2023/06/17/09/16/7b521ec23333cd299dc277f75ea130aeeefe85c2d821fdef3f0eae31dd56a0e4.png],
        media_files: [{ file_size: 19_790 }],
        page_url: "https://dotpict.net/works/4834127",
        profile_url: "https://dotpict.net/users/786555",
        profile_urls: %w[https://dotpict.net/users/786555 https://dotpict.net/@ycsawampfp],
        display_name: "⭐️ YCSAWAMPFP (YCS) 3600+ ⭐️",
        username: "ycsawampfp",
        tags: [
          ["RainyDay2023", "https://dotpict.net/search/works/tag/RainyDay2023"],
          ["YCSAWAMPFP's Art", "https://dotpict.net/search/works/tag/YCSAWAMPFP's Art"],
        ],
        dtext_artist_commentary_title: "Rainy Day",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          I wish it was raining sometimes... Partly influenced by "rain - momone momo" by lvnarlii (YouTube) 時々雨が降ってくれたらいいのに… lvnarlii の「rain - momone momo」（YouTube）に一部影響を受けています。
        EOS
      )
    end

    context "A deleted or nonexistent Dotpict post" do
      strategy_should_work(
        "https://dotpict.net/works/999999999",
        image_urls: [],
        page_url: "https://dotpict.net/works/999999999",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
