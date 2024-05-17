# frozen_string_literal: true

require "test_helper"

module Sources
  class DotpictTest < ActiveSupport::TestCase
    context "Dotpict:" do
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
          dtext_artist_commentary_desc: ""
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
          dtext_artist_commentary_desc: ""
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
          display_name: "+{《YCSAWAMPFP/YCS》}+",
          username: "ycsawampfp",
          other_names: ["+{《YCSAWAMPFP/YCS》}+", "ycsawampfp"],
          tags: [
            ["RainyDay2023", "https://dotpict.net/search/works/tag/RainyDay2023"],
            ["YCSAWAMPFP's Art", "https://dotpict.net/search/works/tag/YCSAWAMPFP's Art"],
          ],
          dtext_artist_commentary_title: "Rainy Day",
          dtext_artist_commentary_desc: <<~EOS.chomp
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
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse Dotpict URLs correctly" do
        assert(Source::URL.image_url?("https://img.dotpicko.net/thumbnail_work/2023/06/09/20/57/thumb_e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.png"))
        assert(Source::URL.image_url?("https://img.dotpicko.net/work/2023/06/09/20/57/e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.gif"))
        assert(Source::URL.image_url?("https://img.dotpicko.net/0a50367ceece3eb2dda17e2e9643486f4b4950e1677bfc061ecce3c7a71c5f20.png"))
        assert(Source::URL.image_url?("https://img.dotpicko.net/header_3bd62384fba07600a7247cb6093ad1ecd271adca72b8c15a5eb4263ca26c5ae2.png"))

        assert(Source::URL.page_url?("https://dotpict.net/works/4814277"))
        assert(Source::URL.page_url?("https://jumpanaatta.dotpict.net/works/5356301"))

        assert(Source::URL.profile_url?("https://dotpict.net/users/2011866"))
        assert(Source::URL.profile_url?("https://dotpict.net/@your_moms_house"))
        assert(Source::URL.profile_url?("https://jumpanaatta.dotpict.net"))
        assert(Source::URL.profile_url?("https://www.dotpict.net"))
      end
    end
  end
end
