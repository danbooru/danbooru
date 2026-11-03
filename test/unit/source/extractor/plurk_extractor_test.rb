require "test_helper"

module Source::Tests::Extractor
  class PlurkExtractorTest < ActiveSupport::ExtractorTestCase
    context "An image URL" do
      strategy_should_work(
        "https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg",
        image_urls: %w[https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg],
        # XXX Flaky test due to Cloudflare Polish changing the file size.
        # media_files: [{ file_size: 627_697 }],
        page_url: nil,
      )
    end

    context "A plurk post" do
      strategy_should_work(
        "https://www.plurk.com/p/om6zv4",
        image_urls: %w[https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg],
        # media_files: [{ file_size: 627_697 }],
        page_url: "https://www.plurk.com/p/om6zv4",
        profile_url: "https://www.plurk.com/redeyehare",
        profile_urls: %w[https://www.plurk.com/redeyehare],
        display_name: "紅眼兔@不務正業",
        username: "redeyehare",
        tag_name: "redeyehare",
        other_names: ["紅眼兔@不務正業", "redeyehare"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          <https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg>

          Trick or Treat!
          很久沒畫萬聖賀圖了，畫一波大的  感覺持續復健中
        EOS
      )
    end

    context "An adult plurk post with replies by the author in the comments" do
      strategy_should_work(
        "https://www.plurk.com/p/omc64y",
        image_urls: %w[
          https://images.plurk.com/yfnumBJqqoQt50Em6xKwf.png
          https://images.plurk.com/5NaqqO3Yi6bQW1wKXq1Dc2.png
          https://images.plurk.com/3HzNcbMhCozHPk5YY8j9fI.png
          https://images.plurk.com/2e0duwn8BpSW9MGuUvbrim.png
          https://images.plurk.com/1OuiMDp82hYPEUn64CWFFB.png
          https://images.plurk.com/3F3KzZOabeMYkgTeseEZ0r.png
          https://images.plurk.com/7onKKTAIXkY4pASszrBys8.png
          https://images.plurk.com/6aotmjLGbtMLiI3slN7ODv.png
          https://images.plurk.com/6pzn7jE2nkj9EV7H25L0x1.png
          https://images.plurk.com/yA8egjDuhy0eNG9yxRj1d.png
        ],
        page_url: "https://www.plurk.com/p/omc64y",
        profile_url: "https://www.plurk.com/BOW99",
        profile_urls: %w[https://www.plurk.com/BOW99],
        display_name: "BOW🔞",
        username: "BOW99",
        tag_name: "bow99",
        other_names: ["BOW🔞", "BOW99"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          [十月號]

          <https://images.plurk.com/yfnumBJqqoQt50Em6xKwf.png>

          <https://images.plurk.com/5NaqqO3Yi6bQW1wKXq1Dc2.png>

          <https://images.plurk.com/3HzNcbMhCozHPk5YY8j9fI.png>

          <https://images.plurk.com/2e0duwn8BpSW9MGuUvbrim.png>

          <https://images.plurk.com/1OuiMDp82hYPEUn64CWFFB.png>

          <https://images.plurk.com/3F3KzZOabeMYkgTeseEZ0r.png>

          <https://images.plurk.com/7onKKTAIXkY4pASszrBys8.png>

          <https://images.plurk.com/6aotmjLGbtMLiI3slN7ODv.png>

          <https://images.plurk.com/6pzn7jE2nkj9EV7H25L0x1.png>

          <https://images.plurk.com/yA8egjDuhy0eNG9yxRj1d.png>
        EOS
      )
    end

    context "A plurk comment by the author in reply to their own post" do
      strategy_should_work(
        "https://www.plurk.com/p/omc64y?r=7605743002",
        image_urls: %w[
          https://images.plurk.com/7bk2kYN2fEVV0kiT5qoiuO.png
          https://images.plurk.com/6mgCwWjSqOfi0BtSg6THcZ.png
          https://images.plurk.com/3BwtMvr6S13gr96r5TLIFd.png
          https://images.plurk.com/22CPzkRM71frDR5eRMPthC.png
          https://images.plurk.com/1IFScoxA7m0FXNu6XirBwa.jpg
          https://images.plurk.com/5v1ZXQxbS7ocV4BybwbCSs.jpg
          https://images.plurk.com/4n1og7pg4KP3wRYSKpFzF7.png
          https://images.plurk.com/5gK1PyPTrVYoeZBr10lEYu.png
          https://images.plurk.com/3m8YZS3D9vaAH8Lw1LDTix.png
          https://images.plurk.com/3oy7joPrEFm0Wlo7NplXOl.png
        ],
        page_url: "https://www.plurk.com/p/omc64y?r=7605743002",
        profile_url: "https://www.plurk.com/BOW99",
        profile_urls: %w[https://www.plurk.com/BOW99],
        display_name: "BOW🔞",
        username: "BOW99",
        tag_name: "bow99",
        other_names: ["BOW🔞", "BOW99"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A plurk post with an external link card in the commentary" do
      strategy_should_work(
        "https://www.plurk.com/p/3fqo1xpr2g",
        image_urls: %w[https://images.plurk.com/4ZvWUcIEgaOKclXC9AcW37.png],
        # media_files: [{ file_size: 400_752 }],
        page_url: "https://www.plurk.com/p/3fqo1xpr2g",
        profile_url: "https://www.plurk.com/SollyzSundyz",
        profile_urls: %w[https://www.plurk.com/SollyzSundyz],
        display_name: "SollyzSundyz",
        username: "SollyzSundyz",
        tag_name: "sollyzsundyz",
        other_names: ["SollyzSundyz"],
        tags: [
          ["furry", "https://www.plurk.com/search?q=furry"],
          ["wediz", "https://www.plurk.com/search?q=wediz"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          <https://images.plurk.com/4ZvWUcIEgaOKclXC9AcW37.png>

          Smily~ uncle Wediz

          support my OC here :

          <https://www.patreon.com/sollyz_gallery>

          #furry #wediz
        EOS
      )
    end

    # XXX Doesn't grab the external image or the hashtag. Should it?
    context "A plurk post with an embedded image from a different site" do
      strategy_should_work(
        "https://www.plurk.com/p/i701j1",
        image_urls: %w[],
        media_files: [],
        page_url: "https://www.plurk.com/p/i701j1",
        profile_url: "https://www.plurk.com/NetKidz",
        profile_urls: %w[https://www.plurk.com/NetKidz],
        display_name: "18+NetKidz",
        username: "NetKidz",
        tag_name: "netkidz",
        other_names: ["18+NetKidz", "NetKidz"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          <https://4.bp.blogspot.com/-HPXVpK9ukb4/USX0700w-uI/AAAAAAAALok/7MSx8yVhR7M/s1600/18_GWTB6.jpg>

          #隨爆而逝
          感謝噗友 "emilwu":[http://www.plurk.com/emilwu] 整理:

          <https://imgur.com/a/Y8YFV>
        EOS
      )
    end
  end
end
