require 'test_helper'

module Sources
  class E621Test < ActiveSupport::TestCase
    context "A normal post URL" do
      strategy_should_work(
        "https://e621.net/posts/3728701",
        image_urls: %w[https://static1.e621.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png],
        media_files: [{ file_size: 1_563_179 }],
        page_url: "https://e621.net/posts/3728701",
        profile_urls: %w[https://www.pixiv.net/users/1549213 https://www.pixiv.net/stacc/daga2626],
        display_name: "DAGASI",
        username: "daga2626",
        tags: [
          ["acting_like_a_cat", "https://e621.net/posts?tags=acting_like_a_cat"],
          ["ambiguous_feral", "https://e621.net/posts?tags=ambiguous_feral"],
          ["ambiguous_gender", "https://e621.net/posts?tags=ambiguous_gender"],
          ["bath", "https://e621.net/posts?tags=bath"],
          ["blush", "https://e621.net/posts?tags=blush"],
          ["bubble", "https://e621.net/posts?tags=bubble"],
          ["daww", "https://e621.net/posts?tags=daww"],
          ["disembodied_hand", "https://e621.net/posts?tags=disembodied_hand"],
          ["duo", "https://e621.net/posts?tags=duo"],
          ["fangs", "https://e621.net/posts?tags=fangs"],
          ["feral", "https://e621.net/posts?tags=feral"],
          ["fur", "https://e621.net/posts?tags=fur"],
          ["grass", "https://e621.net/posts?tags=grass"],
          ["heart_symbol", "https://e621.net/posts?tags=heart_symbol"],
          ["open_mouth", "https://e621.net/posts?tags=open_mouth"],
          ["plant", "https://e621.net/posts?tags=plant"],
          ["red_blush", "https://e621.net/posts?tags=red_blush"],
          ["soap", "https://e621.net/posts?tags=soap"],
          ["solo_focus", "https://e621.net/posts?tags=solo_focus"],
          ["suds", "https://e621.net/posts?tags=suds"],
          ["teeth", "https://e621.net/posts?tags=teeth"],
          ["uvula", "https://e621.net/posts?tags=uvula"],
          ["dagasi", "https://e621.net/posts?tags=dagasi"],
          ["nintendo", "https://e621.net/posts?tags=nintendo"],
          ["pokemon", "https://e621.net/posts?tags=pokemon"],
          ["generation_9_pokemon", "https://e621.net/posts?tags=generation_9_pokemon"],
          ["pokemon_(species)", "https://e621.net/posts?tags=pokemon_(species)"],
          ["sprigatito", "https://e621.net/posts?tags=sprigatito"],
          ["2022", "https://e621.net/posts?tags=2022"],
          ["digital_media_(artwork)", "https://e621.net/posts?tags=digital_media_(artwork)"],
          ["hi_res", "https://e621.net/posts?tags=hi_res"],
          ["rating:s", "https://e621.net/posts?tags=rating:s"],
        ],
        dtext_artist_commentary_title: "とても良い子に育ちました",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A sample URL" do
      strategy_should_work(
        "https://static1.e926.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg",
        image_urls: %w[https://static1.e621.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png],
        media_files: [{ file_size: 1_563_179 }],
        page_url: "https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a",
      )
    end

    context "A self-uploaded post with external source" do
      strategy_should_work(
        "https://e621.net/posts/4835259",
        image_urls: %w[https://static1.e621.net/data/9e/be/9ebe277e202ef0a8e275fe0598c0527d.png],
        # media_files: [{ file_size: 1_786_869 }],
        page_url: "https://e621.net/posts/4835259",
        profile_urls: %w[https://e621.net/users/205980 https://inkbunny.net/DAGASI https://www.pixiv.net/users/1549213 https://fantia.jp/fanclubs/34875 https://www.furaffinity.net/user/dagasl https://dagasi.fanbox.cc https://twitter.com/DAGASl https://baraag.net/@DAGASI https://x.com/DAGASl2 https://www.pixiv.net/stacc/daga2626],
        display_name: "DAGASI",
        username: "daga2626",
        dtext_artist_commentary_title: "ロボを狂わせる度し難いニオイ",
        dtext_artist_commentary_desc: <<~EOS.chomp
          その後
          FANBOX【<https://dagasi.fanbox.cc/posts/8017927>】
          fantia【<https://fantia.jp/posts/2785563>】
        EOS
      )
    end

    context "A sourceless self-uploaded post" do
      strategy_should_work(
        "https://e621.net/posts/3599343",
        image_urls: %w[https://static1.e621.net/data/53/98/53983ea953512a86c81d6fdb5f9b1df1.png],
        # media_files: [{ file_size: 3_058_658 }],
        page_url: "https://e621.net/posts/3599343",
        profile_urls: %w[https://e621.net/users/366015 https://linktr.ee/bnbigus https://bnbigus.tumblr.com https://twitter.com/bnbigus https://www.patreon.com/Bnbigus https://www.furaffinity.net/user/bnbigus https://bnbigus.newgrounds.com https://discord.com/invite/8kpwCUm https://twitter.com/intent/user?user_id=1069662959243313153],
        display_name: "BnBigus",
        username: "bnbigus",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "Man accidentally buys a sapient sex machine, an honest mistake really."
      )
    end

    context "A sourceless second-party post" do
      strategy_should_work(
        "https://e621.net/posts/4574233",
        image_urls: %w[https://static1.e621.net/data/6a/96/6a962c7056db60fba0c4ca52d8d5266d.png],
        # media_files: [{ file_size: 13_919_143 }],
        page_url: "https://e621.net/posts/4574233",
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil
      )
    end

    context "A login-blocked post" do
      strategy_should_work(
        "https://e621.net/posts/2816118",
        image_urls: %w[https://static1.e621.net/data/a7/f4/a7f439e253c82433656ad7ce62bc9b64.png],
        # media_files: [{ file_size: 5_623_796 }],
        page_url: "https://e621.net/posts/2816118",
        profile_urls: %w[https://baraag.net/@Butterchalk],
        display_name: nil,
        username: "Butterchalk",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    should "Parse e621 URLs correctly" do
      assert(Source::URL.image_url?("https://static1.e621.net/data/sample/ae/ae/aeaed0dfba6468ec992c6e5cc46763c1_720p.mp4"))
      assert(Source::URL.image_url?("https://static1.e926.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg"))
      assert(Source::URL.image_url?("https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png"))

      assert_equal("https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a", Source::URL.page_url("https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png"))

      assert(Source::URL.page_url?("https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a"))
      assert(Source::URL.page_url?("https://e621.net/posts/3728701"))
      assert(Source::URL.page_url?("https://e926.net/posts/3728701"))

      assert(Source::URL.profile_url?("https://e621.net/users/205980"))
    end
  end
end
