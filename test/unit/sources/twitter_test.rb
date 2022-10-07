require 'test_helper'

module Sources
  class TwitterTest < ActiveSupport::TestCase
    setup do
      skip "Twitter credentials are not configured" if !Source::Extractor::Twitter.enabled?
    end

    context "A https://twitter.com/:username/status/:id url" do
      strategy_should_work(
        "https://twitter.com/motty08111213/status/943446161586733056",
        page_url: "https://twitter.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        download_size: 275_713,
        profile_url: "https://twitter.com/motty08111213",
        artist_name: "えのぐマネージャー 丸茂",
        tag_name: "motty08111213",
        tags: ["岩本町芸能社", "女優部"]
      )
    end

    context "A https://twitter.com/i/web/status/:id url" do
      strategy_should_work(
        "https://twitter.com/i/web/status/943446161586733056",
        page_url: "https://twitter.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        download_size: 275_713,
        profile_url: "https://twitter.com/motty08111213",
        artist_name: "えのぐマネージャー 丸茂",
        tag_name: "motty08111213",
        tags: ["岩本町芸能社", "女優部"]
      )
    end

    context "A https://twitter.com/i/status/:id url" do
      strategy_should_work(
        "https://twitter.com/i/status/943446161586733056",
        page_url: "https://twitter.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        download_size: 275_713,
        profile_url: "https://twitter.com/motty08111213",
        artist_name: "えのぐマネージャー 丸茂",
        tag_name: "motty08111213",
        tags: ["岩本町芸能社", "女優部"]
      )
    end

    context "A video tweet" do
      strategy_should_work(
        "https://twitter.com/CincinnatiZoo/status/859073537713328129",
        image_urls: ["https://video.twimg.com/ext_tw_video/859073467769126913/pu/vid/1280x720/cPGgVROXHy3yrK6u.mp4"],
        page_url: "https://twitter.com/CincinnatiZoo/status/859073537713328129",
        download_size: 8_602_983
      )
    end

    context "A video thumbnail" do
      # https://twitter.com/Kekeflipnote/status/1241038667898118144
      strategy_should_work(
        "https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:small",
        image_urls: ["https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:orig"],
        download_size: 18_058
      )
    end

    context "An external video thumbnail" do
      strategy_should_work(
        "https://pbs.twimg.com/ext_tw_video_thumb/1578376127801761793/pu/img/oGcUqPnwRYYhk-gi.jpg:small",
        image_urls: ["https://pbs.twimg.com/ext_tw_video_thumb/1578376127801761793/pu/img/oGcUqPnwRYYhk-gi.jpg:orig"],
        download_size: 243_227
      )
    end

    context "An amplify video thumbnail" do
      # https://twitter.com/UNITED_CINEMAS/status/1223138847417978881
      strategy_should_work(
        "https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:small",
        image_urls: ["https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:orig"],
        download_size: 106_942
      )
    end

    context "A tweet with an animated gif" do
      strategy_should_work(
        "https://twitter.com/i/web/status/1252517866059907073",
        image_urls: ["https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4"],
        download_size: 542_833
      )
    end

    context "A restricted tweet" do
      strategy_should_work(
        "https://mobile.twitter.com/Strangestone/status/556440271961858051",
        image_urls: ["https://pbs.twimg.com/media/B7jfc1JCcAEyeJh.png:orig"],
        page_url: "https://twitter.com/Strangestone/status/556440271961858051",
        profile_url: "https://twitter.com/Strangestone",
        profile_urls: ["https://twitter.com/Strangestone", "https://twitter.com/intent/user?user_id=93332575"],
        tag_name: "Strangestone",
        artist_name: "比村奇石",
        dtext_artist_commentary_desc: "ブレザーが描きたかったのでJK鈴谷"
      )
    end

    context "A tweet without any images" do
      strategy_should_work(
        "https://twitter.com/teruyo/status/1058452066060853248",
        profile_url: "https://twitter.com/teruyo",
        image_urls: []
      )
    end

    context "A direct image url" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EBGp2YdUYAA19Uj?format=jpg&name=small",
        image_urls: ["https://pbs.twimg.com/media/EBGp2YdUYAA19Uj.jpg:orig"],
        download_size: 229_661,
        profile_url: nil
      )
    end

    context "A direct image url with dashes" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg",
        image_urls: ["https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg:orig"],
        download_size: 842_373,
        profile_url: nil
      )
    end

    context "A deleted tweet" do
      strategy_should_work(
        "https://twitter.com/masayasuf/status/870734961778630656",
        deleted: true,
        tag_name: "masayasuf",
        profile_url: "https://twitter.com/masayasuf"
      )
    end

    context "A tweet from a suspended user" do
      strategy_should_work(
        "https://twitter.com/tanso_panz/status/1192429800717029377",
        tag_name: "tanso_panz",
        profile_url: "https://twitter.com/tanso_panz",
        image_urls: []
      )
    end

    context "A profile banner image" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696",
        image_urls: ["https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/1500x500"],
        download_size: 128_141,
        profile_url: nil
        # profile_url: "https://twitter.com/intent/user?user_id=780804311529906176"
        # XXX we COULD fully support these by setting the page_url to https://twitter.com/Kekeflipnote/header_photo, but it's a lot of work for a niche case
      )
    end

    context "A profile banner image sample" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/600x200",
        image_urls: ["https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/1500x500"],
        download_size: 128_141,
        profile_url: nil
      )
    end

    context "A tweet with hashtags with normalizable prefixes" do
      strategy_should_work(
        "https://twitter.com/kasaishin100/status/1186658635226607616",
        tags: ["西住みほ生誕祭2019"],
        normalized_tags: ["西住みほ"]
      )
    end

    context "A tweet with mentions that can be converted to dtext" do
      strategy_should_work(
        "https://twitter.com/noizave/status/875768175136317440",
        dtext_artist_commentary_desc: 'test "#foo":[https://twitter.com/hashtag/foo] "#ホワイトデー":[https://twitter.com/hashtag/ホワイトデー] "@noizave":[https://twitter.com/noizave]\'s blah http://www.example.com <>& 😀'
      )
    end

    context "A tweet with normalizable unicode text" do
      strategy_should_work(
        "https://twitter.com/aprilarcus/status/367557195186970624",
        artist_commentary_desc: "𝖸𝗈 𝐔𝐧𝐢𝐜𝐨𝐝𝐞 𝗅 𝗁𝖾𝗋𝖽 𝕌 𝗅𝗂𝗄𝖾 𝑡𝑦𝑝𝑒𝑓𝑎𝑐𝑒𝑠 𝗌𝗈 𝗐𝖾 𝗉𝗎𝗍 𝗌𝗈𝗆𝖾 𝚌𝚘𝚍𝚎𝚙𝚘𝚒𝚗𝚝𝚜 𝗂𝗇 𝗒𝗈𝗎𝗋 𝔖𝔲𝔭𝔭𝔩𝔢𝔪𝔢𝔫𝔱𝔞𝔯𝔶 𝔚𝔲𝔩𝔱𝔦𝔩𝔦𝔫𝔤𝔳𝔞𝔩 𝔓𝔩𝔞𝔫𝔢 𝗌𝗈 𝗒𝗈𝗎 𝖼𝖺𝗇 𝓮𝓷𝓬𝓸𝓭𝓮 𝕗𝕠𝕟𝕥𝕤 𝗂𝗇 𝗒𝗈𝗎𝗋 𝒇𝒐𝒏𝒕𝒔.",
        dtext_artist_commentary_desc: "Yo Unicode l herd U like typefaces so we put some codepoints in your Supplementary Wultilingval Plane so you can encode fonts in your fonts."
      )
    end

    context "A tweet with normalizable full-width hashtags" do
      strategy_should_work(
        "https://twitter.com/corpsmanWelt/status/1037724260075069441",
        artist_commentary_desc: %{新しいおともだち\n＃けものフレンズ https://t.co/sEAuu16yAQ},
        dtext_artist_commentary_desc: %{新しいおともだち\n"#けものフレンズ":[https://twitter.com/hashtag/けものフレンズ]}
      )
    end

    should "Parse Twitter URLs correctly" do
      assert(Source::URL.image_url?("https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg"))
      assert(Source::URL.image_url?("https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:small"))
      assert(Source::URL.image_url?("https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=900x900"))
      assert(Source::URL.image_url?("https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg"))
      assert(Source::URL.image_url?("https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg"))
      assert(Source::URL.image_url?("https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg"))

      assert(Source::URL.page_url?("https://twitter.com/i/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://twitter.com/i/web/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://twitter.com/BOW999/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://twitter.com/BOW999/status/1261877313349640194/photo/1"))
      assert(Source::URL.page_url?("https://twitter.com/BOW999/status/1261877313349640194?s=19"))

      assert(Source::URL.profile_url?("https://www.twitter.com/irt_5433"))
      assert(Source::URL.profile_url?("https://www.twitter.com/irt_5433/likes"))
      assert(Source::URL.profile_url?("https://twitter.com/intent/user?user_id=1485229827984531457"))
      assert(Source::URL.profile_url?("https://twitter.com/intent/user?screen_name=ryuudog_NFT"))
      assert(Source::URL.profile_url?("https://twitter.com/i/user/889592953"))

      assert_not(Source::URL.profile_url?("https://twitter.com/home"))

      assert_nil(Source::URL.parse("https://twitter.com/i/status/1261877313349640194").username)
      assert_nil(Source::URL.parse("https://twitter.com/i/web/status/1261877313349640194").username)
      assert_equal("BOW999", Source::URL.parse("https://twitter.com/BOW999/status/1261877313349640194").username)
    end
  end
end
