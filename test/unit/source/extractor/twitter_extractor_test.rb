require "test_helper"

module Source::Tests::Extractor
  class TwitterExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Twitter profile picture sample image" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs_400x400.jpeg",
        image_urls: %w[https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs.jpeg],
        media_files: [{ file_size: 203_927, width: 1252, height: 1252 }],
        page_url: nil,
        profile_urls: [],
        published_at: Time.parse("2013-12-29T06:35:28.902000Z"),
        updated_at: nil,
      )
    end

    context "A https://twitter.com/:username/status/:id url" do
      strategy_should_work(
        "https://twitter.com/motty08111213/status/943446161586733056",
        page_url: "https://x.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        media_files: [
          { file_size: 275_713 },
          { file_size: 207_248 },
          { file_size: 188_553 },
        ],
        profile_url: "https://x.com/motty08111213",
        profile_urls: %w[https://x.com/motty08111213 https://x.com/i/user/895634201898176513],
        display_name: "丸茂",
        username: "motty08111213",
        published_at: Time.parse("2017-12-20T11:41:07.000000Z"),
        updated_at: nil,
        tags: ["岩本町芸能社", "女優部"],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          岩本町芸能社女優部のタレント3名がHPに公開されました。
          部署が違うので私の担当ではありませんが、みんなとても良い子たちです。
          あんずと環 同様、応援していただけると嬉しいです…！
          詳細はこちらから↓
          <http://rbc-geino.com/profile_2/>
          "#岩本町芸能社":[https://x.com/hashtag/岩本町芸能社] "#女優部":[https://x.com/hashtag/女優部]
        EOS
      )
    end

    context "A https://twitter.com/i/web/status/:id url" do
      strategy_should_work(
        "https://twitter.com/i/web/status/943446161586733056",
        page_url: "https://x.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://x.com/motty08111213",
        display_name: "丸茂",
        username: "motty08111213",
        published_at: Time.parse("2017-12-20T11:41:07.000000Z"),
        updated_at: nil,
        tags: ["岩本町芸能社", "女優部"],
      )
    end

    context "A https://twitter.com/i/status/:id url" do
      strategy_should_work(
        "https://twitter.com/i/status/943446161586733056",
        page_url: "https://x.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://x.com/motty08111213",
        display_name: "丸茂",
        username: "motty08111213",
        published_at: Time.parse("2017-12-20T11:41:07.000000Z"),
        updated_at: nil,
        tags: ["岩本町芸能社", "女優部"],
      )
    end

    context "A https://x.com/i/status/:id url" do
      strategy_should_work(
        "https://x.com/i/status/943446161586733056",
        page_url: "https://x.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://x.com/motty08111213",
        display_name: "丸茂",
        username: "motty08111213",
        published_at: Time.parse("2017-12-20T11:41:07.000000Z"),
        updated_at: nil,
        tags: ["岩本町芸能社", "女優部"],
      )
    end

    context "A https://x.com/intent/favorite?tweet_id=:id url" do
      strategy_should_work(
        "https://x.com/intent/favorite?tweet_id=2020838133525520807",
        image_urls: %w[https://pbs.twimg.com/media/HAt1kgFbcAAD8xF.jpg:orig],
        media_files: [{ file_size: 334_077 }],
        page_url: "https://x.com/rousei13/status/2020838133525520807",
        profile_url: "https://x.com/rousei13",
        profile_urls: %w[https://x.com/rousei13 https://x.com/i/user/928581189442482178],
        display_name: "ろうせい",
        username: "rousei13",
        published_at: Time.parse("2026-02-09T12:32:11.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "誰もお前を愛さないパロ",
      )
    end

    context "A https://x.com/intent/retweet?tweet_id=:id url" do
      strategy_should_work(
        "https://x.com/intent/retweet?tweet_id=2020838133525520807",
        image_urls: %w[https://pbs.twimg.com/media/HAt1kgFbcAAD8xF.jpg:orig],
        media_files: [{ file_size: 334_077 }],
        page_url: "https://x.com/rousei13/status/2020838133525520807",
        profile_url: "https://x.com/rousei13",
        profile_urls: %w[https://x.com/rousei13 https://x.com/i/user/928581189442482178],
        display_name: "ろうせい",
        username: "rousei13",
        published_at: Time.parse("2026-02-09T12:32:11.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "誰もお前を愛さないパロ",
      )
    end

    context "A video tweet" do
      strategy_should_work(
        "https://twitter.com/CincinnatiZoo/status/859073537713328129",
        image_urls: ["https://video.twimg.com/ext_tw_video/859073467769126913/pu/vid/1280x720/cPGgVROXHy3yrK6u.mp4"],
        page_url: "https://x.com/CincinnatiZoo/status/859073537713328129",
        media_files: [{ file_size: 8_603_100 }],
        published_at: Time.parse("2017-05-01T15:54:26.000000Z"),
        updated_at: nil,
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Fiona loves playing in the hose water just like her parents! 💦 "#TeamFiona":[https://x.com/hashtag/TeamFiona] "#fionafix":[https://x.com/hashtag/fionafix]
        EOS
      )
    end

    context "A video thumbnail" do
      # https://twitter.com/Kekeflipnote/status/1241038667898118144
      strategy_should_work(
        "https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:small",
        image_urls: ["https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:orig"],
        media_files: [{ file_size: 18_058 }],
        published_at: Time.parse("2020-03-20T16:23:32.504000Z"),
        updated_at: nil,
      )
    end

    context "An external video thumbnail" do
      strategy_should_work(
        "https://pbs.twimg.com/ext_tw_video_thumb/1578376127801761793/pu/img/oGcUqPnwRYYhk-gi.jpg:small",
        image_urls: ["https://pbs.twimg.com/ext_tw_video_thumb/1578376127801761793/pu/img/oGcUqPnwRYYhk-gi.jpg:orig"],
        media_files: [{ file_size: 243_227 }],
        published_at: Time.parse("2022-10-07T13:26:08.335000Z"),
        updated_at: nil,
      )
    end

    context "An amplify video thumbnail" do
      # https://twitter.com/UNITED_CINEMAS/status/1223138847417978881
      strategy_should_work(
        "https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:small",
        image_urls: ["https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:orig"],
        media_files: [{ file_size: 106_942 }],
        published_at: Time.parse("2020-01-10T11:06:40.088000Z"),
        updated_at: nil,
      )
    end

    context "An amplify video" do
      # https://twitter.com/UNITED_CINEMAS/status/1223138847417978881
      strategy_should_work(
        "https://video.twimg.com/amplify_video/1215590775364259840/vid/1280x720/wE6Ngd7-JPw5vCZP.mp4?tag=13",
        image_urls: %w[https://video.twimg.com/amplify_video/1215590775364259840/vid/1280x720/wE6Ngd7-JPw5vCZP.mp4?tag=13],
        media_files: [{ file_size: 6_189_795 }],
        published_at: Time.parse("2020-01-10T11:06:40.088000Z"),
        updated_at: nil,
      )
    end

    context "A /tweet_video/ URL" do
      strategy_should_work(
        "https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4",
        image_urls: ["https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4"],
        media_files: [{ file_size: 542_833 }],
        page_url: nil,
        published_at: Time.parse("2020-04-21T08:41:38.215000Z"),
        updated_at: nil,
      )
    end

    context "A tweet with an animated gif" do
      strategy_should_work(
        "https://twitter.com/i/web/status/1252517866059907073",
        image_urls: ["https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4"],
        media_files: [{ file_size: 542_833 }],
        published_at: Time.parse("2020-04-21T08:41:44.000000Z"),
        updated_at: nil,
        artist_commentary_desc: "https://t.co/gyTKOSBOQ7",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A mixed-media tweet" do
      strategy_should_work(
        "https://twitter.com/twotenky/status/1577831592227000320",
        image_urls: %w[
          https://pbs.twimg.com/media/FeWVcf2VUAATTey.jpg:orig
          https://video.twimg.com/tweet_video/FeWVcf4VQAAIPTe.mp4
        ],
        page_url: "https://x.com/twotenky/status/1577831592227000320",
        display_name: "通天機",
        username: "twotenky",
        profile_url: "https://x.com/twotenky",
        published_at: Time.parse("2022-10-06T01:22:20.000000Z"),
        updated_at: nil,
        artist_commentary_desc: "動画と静止画がセットでお得と聞いて https://t.co/hWvKoHLN7y",
        dtext_artist_commentary_desc: "動画と静止画がセットでお得と聞いて",
      )
    end

    context "A restricted tweet" do
      strategy_should_work(
        "https://mobile.twitter.com/Strangestone/status/556440271961858051",
        image_urls: ["https://pbs.twimg.com/media/B7jfc1JCcAEyeJh.png:orig"],
        media_files: [{ file_size: 280_150 }],
        page_url: "https://x.com/Strangestone/status/556440271961858051",
        profile_url: "https://x.com/Strangestone",
        profile_urls: ["https://x.com/Strangestone", "https://x.com/i/user/93332575"],
        display_name: "比村奇石",
        username: "Strangestone",
        published_at: Time.parse("2015-01-17T13:17:53.000000Z"),
        updated_at: nil,
        dtext_artist_commentary_desc: "ブレザーが描きたかったのでJK鈴谷",
      )
    end

    context "A NSFW tweet" do
      strategy_should_work(
        "https://twitter.com/shoka_bg/status/1644344692107268097",
        image_urls: ["https://pbs.twimg.com/media/FtHbwvuaQAAxQ8v.jpg:orig"],
        page_url: "https://x.com/shoka_bg/status/1644344692107268097",
        profile_url: "https://x.com/shoka_bg",
        profile_urls: ["https://x.com/shoka_bg", "https://x.com/i/user/1109709388049051649"],
        display_name: "ショカ",
        username: "shoka_bg",
        published_at: Time.parse("2023-04-07T14:21:39.000000Z"),
        updated_at: nil,
        tags: %w[ブルアカ],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          風紀委員の実態
          "#ブルアカ":[https://x.com/hashtag/ブルアカ]
        EOS
      )
    end

    context "A long tweet with >280 characters" do
      strategy_should_work(
        "https://twitter.com/loveremi_razoku/status/1637647185969041408",
        image_urls: ["https://pbs.twimg.com/media/FroXbmIaIAEuC1B.jpg:orig"],
        page_url: "https://x.com/loveremi_razoku/status/1637647185969041408",
        profile_url: "https://x.com/loveremi_razoku",
        profile_urls: ["https://x.com/loveremi_razoku", "https://x.com/i/user/293443351"],
        display_name: "ラブレミ@うぉるやふぁんくらぶ",
        username: "loveremi_razoku",
        published_at: Time.parse("2023-03-20T02:48:09.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          「ラリアッ党の野望チョコ」
          commission ラリアット さん"@rariatoo":[https://x.com/rariatoo]

          シゲ「カッパ、お前何やった?」

          カッパ「オイラ、ルディちゃんでヤンス!エロいでヤンス!」

          シゲ「コイツ、ほんまエロガッパやな…ワイはノス＆ザクロや!これでコンプやで!」

          シゲ「ミツ、お前は?」

          ミツはうつむいて何も言わない
          シゲはミツのシールを覗き込んだ

          シゲ「【ウチはムーンライト!姐さん方にたてつくヤツはいてこましたるでェ!】か…今月の一般公募枠やん!粋なファンサやな…」

          カッパ「ゲヘヘ!この子もエロいでヤンス〜!」

          シゲ「そういやお前もハガキ、書いてたよな…ん?泣いとるんか?ラムネ飲みすぎて腹でも壊したか?」

          カッパはシゲの肩に手を置き、いつになくきれいな目で首を横に振っていた
          その瞬間、シゲもすべてを察した

          シゲ「ミツ…ラムネおごったるさかい、今日はこの子の事存分に語り合おうや…」
        EOS
      )
    end

    context "A tweet that is in reply to another tweet" do
      strategy_should_work(
        "https://twitter.com/emurin/status/912861472916508672",
        image_urls: ["https://pbs.twimg.com/media/DKsikYaU8AEEMKU.jpg:orig"],
        page_url: "https://x.com/emurin/status/912861472916508672",
        profile_url: "https://x.com/emurin",
        profile_urls: ["https://x.com/emurin", "https://x.com/i/user/30642502"],
        display_name: "えむりん",
        username: "emurin",
        published_at: Time.parse("2017-09-27T02:08:29.000000Z"),
        updated_at: nil,
        tags: %w[odaibako],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          > ほわほわ系クーデレギロチンおねがいします <https://odaibako.net/detail/request/277bac5ea1b34b1abc7ac21dd1031690> "#odaibako":[https://x.com/hashtag/odaibako]

          セカコスにしたらギロクロ感がなくなった…
        EOS
      )
    end

    context "A tweet that from an account that is set to followers-only" do
      strategy_should_work(
        "https://twitter.com/star_ukmgr/status/1917596971143160173",
        image_urls: [],
        page_url: "https://x.com/star_ukmgr/status/1917596971143160173",
        profile_urls: %w[https://x.com/star_ukmgr],
        display_name: nil,
        username: "star_ukmgr",
        published_at: Time.parse("2025-04-30T15:08:39.806000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A 'https://pbs.twimg.com/media/*:large' url" do
      strategy_should_work(
        "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large",
        referer: "https://twitter.com/nounproject/status/540944400767922176",
        image_urls: ["https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"],
        media_files: [{ file_size: 9800 }],
        page_url: "https://x.com/nounproject/status/540944400767922176",
        profile_url: "https://x.com/nounproject",
        profile_urls: ["https://x.com/nounproject", "https://x.com/i/user/88996186"],
        display_name: "Noun Project",
        username: "nounproject",
        published_at: Time.parse("2014-12-05T19:02:50.042000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          More is better. Unlimited is best. NounPro Members now get unlimited icon downloads <http://bit.ly/1yn2KWn>
        EOS
      )
    end

    context "A tweet without any images" do
      strategy_should_work(
        "https://twitter.com/teruyo/status/1058452066060853248",
        profile_url: "https://x.com/teruyo",
        image_urls: [],
        published_at: Time.parse("2018-11-02T20:13:32.000000Z"),
        updated_at: nil,
        dtext_artist_commentary_desc: "all the women washizutan2 draws look like roast chicken",
      )
    end

    context "A direct image url" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EBGp2YdUYAA19Uj?format=jpg&name=small",
        image_urls: ["https://pbs.twimg.com/media/EBGp2YdUYAA19Uj.jpg:orig"],
        media_files: [{ file_size: 229_661 }],
        profile_url: nil,
        published_at: nil,
        updated_at: nil,
      )
    end

    context "A direct image url with dashes" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg",
        image_urls: ["https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg:orig"],
        media_files: [{ file_size: 842_373 }],
        profile_url: nil,
        published_at: Time.parse("2019-07-28T09:51:22.966000Z"),
        updated_at: nil,
      )
    end

    context "A direct image url with a referer url from a different site" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg",
        referer: "https://www.pixiv.net/en/artworks/60344190",
        image_urls: ["https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg:orig"],
        media_files: [{ file_size: 842_373 }],
        page_url: nil,
        published_at: Time.parse("2019-07-28T09:51:22.966000Z"),
        updated_at: nil,
      )
    end

    context "A deleted tweet" do
      strategy_should_work(
        "https://twitter.com/masayasuf/status/870734961778630656",
        deleted: true,
        username: "masayasuf",
        profile_url: "https://x.com/masayasuf",
        published_at: Time.parse("2017-06-02T20:12:47.018000Z"),
        updated_at: nil,
        dtext_artist_commentary_desc: "",
      )
    end

    context "A tweet from a suspended user" do
      strategy_should_work(
        "https://twitter.com/tanso_panz/status/1192429800717029377",
        username: "tanso_panz",
        profile_url: "https://x.com/tanso_panz",
        image_urls: [],
        published_at: Time.parse("2019-11-07T13:13:13.422000Z"),
        updated_at: nil,
        dtext_artist_commentary_desc: "",
      )
    end

    context "A https://fxtwitter.com/:username/status/:id url" do
      strategy_should_work(
        "https://fxtwitter.com/motty08111213/status/943446161586733056",
        page_url: "https://x.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://x.com/motty08111213",
        published_at: Time.parse("2017-12-20T11:41:07.000000Z"),
        updated_at: nil,
      )
    end

    context "A https://vxtwitter.com/:username/status/:id url" do
      strategy_should_work(
        "https://vxtwitter.com/motty08111213/status/943446161586733056",
        page_url: "https://x.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://x.com/motty08111213",
        published_at: Time.parse("2017-12-20T11:41:07.000000Z"),
        updated_at: nil,
      )
    end

    context "A profile banner image" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_banners/16298441/1394248006/1500x500",
        image_urls: ["https://pbs.twimg.com/profile_banners/16298441/1394248006/1500x500"],
        media_files: [{ file_size: 108_605 }],
        profile_url: nil,
        # profile_url: "https://x.com/i/user/780804311529906176"
        # XXX we COULD fully support these by setting the page_url to https://x.com/Kekeflipnote/header_photo, but it's a lot of work for a niche case
        published_at: Time.parse("2014-03-08T03:06:46.000000Z"),
        updated_at: nil,
      )
    end

    context "A profile banner image sample" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_banners/16298441/1394248006/600x200",
        image_urls: ["https://pbs.twimg.com/profile_banners/16298441/1394248006/1500x500"],
        media_files: [{ file_size: 108_605 }],
        page_url: nil,
        profile_url: nil,
        published_at: Time.parse("2014-03-08T03:06:46.000000Z"),
        updated_at: nil,
      )
    end

    context "An /ad_img/ image sample" do
      strategy_should_work(
        "https://pbs.twimg.com/ad_img/1415875929608396801/pklSzcPz?format=jpg&name=small",
        image_urls: ["https://pbs.twimg.com/ad_img/1415875929608396801/pklSzcPz?format=jpg&name=orig"],
        media_files: [{ file_size: 159_186 }],
        page_url: nil,
        profile_url: nil,
        published_at: Time.parse("2021-07-16T03:28:21.978000Z"),
        updated_at: nil,
      )
    end

    context "A tweet with hashtags with normalizable prefixes" do
      strategy_should_work(
        "https://twitter.com/kasaishin100/status/1186658635226607616",
        tags: ["西住みほ生誕祭2019"],
        normalized_tags: ["生誕祭", "西住みほ", "西住みほ生誕祭2019"],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          みぽりん誕生日おめでとうございます！！🎂
          ボコボコ探検隊🙌✨
          "#西住みほ生誕祭2019":[https://x.com/hashtag/西住みほ生誕祭2019]
        EOS
      )
    end

    context "A tweet with mentions that can be converted to dtext" do
      strategy_should_work(
        "https://twitter.com/noizave/status/875768175136317440",
        dtext_artist_commentary_desc: 'test "#foo":[https://x.com/hashtag/foo] "#ホワイトデー":[https://x.com/hashtag/ホワイトデー] "@noizave":[https://x.com/noizave]\'s blah <http://www.example.com> <>& 😀',
      )
    end

    context "A tweet with unicode text" do
      strategy_should_work(
        "https://twitter.com/aprilarcus/status/367557195186970624",
        artist_commentary_desc: "𝖸𝗈 𝐔𝐧𝐢𝐜𝐨𝐝𝐞 𝗅 𝗁𝖾𝗋𝖽 𝕌 𝗅𝗂𝗄𝖾 𝑡𝑦𝑝𝑒𝑓𝑎𝑐𝑒𝑠 𝗌𝗈 𝗐𝖾 𝗉𝗎𝗍 𝗌𝗈𝗆𝖾 𝚌𝚘𝚍𝚎𝚙𝚘𝚒𝚗𝚝𝚜 𝗂𝗇 𝗒𝗈𝗎𝗋 𝔖𝔲𝔭𝔭𝔩𝔢𝔪𝔢𝔫𝔱𝔞𝔯𝔶 𝔚𝔲𝔩𝔱𝔦𝔩𝔦𝔫𝔤𝔳𝔞𝔩 𝔓𝔩𝔞𝔫𝔢 𝗌𝗈 𝗒𝗈𝗎 𝖼𝖺𝗇 𝓮𝓷𝓬𝓸𝓭𝓮 𝕗𝕠𝕟𝕥𝕤 𝗂𝗇 𝗒𝗈𝗎𝗋 𝒇𝒐𝒏𝒕𝒔.",
        dtext_artist_commentary_desc: "𝖸𝗈 𝐔𝐧𝐢𝐜𝐨𝐝𝐞 𝗅 𝗁𝖾𝗋𝖽 𝕌 𝗅𝗂𝗄𝖾 𝑡𝑦𝑝𝑒𝑓𝑎𝑐𝑒𝑠 𝗌𝗈 𝗐𝖾 𝗉𝗎𝗍 𝗌𝗈𝗆𝖾 𝚌𝚘𝚍𝚎𝚙𝚘𝚒𝚗𝚝𝚜 𝗂𝗇 𝗒𝗈𝗎𝗋 𝔖𝔲𝔭𝔭𝔩𝔢𝔪𝔢𝔫𝔱𝔞𝔯𝔶 𝔚𝔲𝔩𝔱𝔦𝔩𝔦𝔫𝔤𝔳𝔞𝔩 𝔓𝔩𝔞𝔫𝔢 𝗌𝗈 𝗒𝗈𝗎 𝖼𝖺𝗇 𝓮𝓷𝓬𝓸𝓭𝓮 𝕗𝕠𝕟𝕥𝕤 𝗂𝗇 𝗒𝗈𝗎𝗋 𝒇𝒐𝒏𝒕𝒔.",
      )
    end

    context "A tweet with normalizable full-width hashtags" do
      strategy_should_work(
        "https://twitter.com/corpsmanWelt/status/1037724260075069441",
        artist_commentary_desc: %{新しいおともだち\n＃けものフレンズ https://t.co/sEAuu16yAQ},
        dtext_artist_commentary_desc: %{新しいおともだち\n"#けものフレンズ":[https://x.com/hashtag/けものフレンズ]},
      )
    end

    context "A tweet with mega.nz links" do
      strategy_should_work(
        "https://twitter.com/VG_Worklog/status/1587457941418160128",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Sound by: "@RealAudiodude":[https://x.com/RealAudiodude]
          Download: <https://mega.nz/folder/i80gVL7L#111g2XX7bIJ-2KnAHxMt0w>
          Support: <https://www.patreon.com/vgerotica>
        EOS
      )
    end

    context "A tweet with fullwidth parentheses" do
      strategy_should_work(
        "https://twitter.com/Chanta_in_inari/status/1031042032934871041",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          政長さん（<https://x.com/naga_masanaga>）の藍様線画を塗ってましたあ。
          うーん、かわいい。
        EOS
      )
    end

    context "A tweet with cashtags" do
      strategy_should_work(
        "https://twitter.com/CFRJacobsson/status/1608788299665276931",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "$GOOG":[https://x.com/search?q=$GOOG] is the next "$IBM":[https://x.com/search?q=$IBM] 🧵

          1/7
        EOS
      )
    end

    context "A tweet with escaped HTML characters" do
      strategy_should_work(
        "https://twitter.com/takobe_t/status/1777662729890730410",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          ロザリンデ&エルトリンデ
          "#ユニコーンオーバーロード":[https://x.com/hashtag/ユニコーンオーバーロード]
        EOS
      )
    end

    context "A tweet with 'issue #1'" do
      strategy_should_work(
        "https://twitter.com/Persona_Central/status/1750173292588097879",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          The new Shigenori Soejima illustration for Persona 3 Reload in Weekly Famitsu magazine issue &num;1834. "#P3R":[https://x.com/hashtag/P3R]
        EOS
      )
    end

    context "A tweet with alt text" do
      strategy_should_work(
        "https://x.com/maruyo_/status/1521844593804906496",
        image_urls: %w[
          https://pbs.twimg.com/media/FRu0eYvVgAA83Et.jpg:orig
          https://pbs.twimg.com/media/FRu0eYwVEAAso2d.jpg:orig
          https://pbs.twimg.com/media/FRu0eY2UUAE54PD.jpg:orig
          https://pbs.twimg.com/media/FRu0eY9VcAEZluY.jpg:orig
        ],
        media_files: [
          { file_size: 215_152 },
          { file_size: 131_131 },
          { file_size: 151_909 },
          { file_size: 128_702 },
        ],
        page_url: "https://x.com/maruyo_/status/1521844593804906496",
        profile_urls: %w[https://x.com/maruyo_ https://x.com/i/user/115694863],
        display_name: "まるよ",
        username: "maruyo_",
        tags: [
          ["スーパーカブ", "https://x.com/hashtag/スーパーカブ"],
        ],
        published_at: Time.parse("2022-05-04T13:30:00.000000Z"),
        updated_at: nil,
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          GWなので再放送です☺
          "#スーパーカブ":[https://x.com/hashtag/スーパーカブ]

          [quote]
          h6. Image Description

          江ノ電カブネキからすっかりネタに走ってますがたまにまじめに描いてはいるのです。トークショーからもうそろそろ１か月でスタンプラリーももうすぐ終わりですね。5/8までなのでまだ間に合いますYO
          [/quote]

          [quote]
          h6. Image Description

          これはメタルギアがネタですねｗ
          [/quote]

          [quote]
          h6. Image Description

          トークショー脳内作画。礼子さんがおしとやかで小熊はそのまんまという感じですｗ バイク歴は真逆なのでライディング講座をするとか面白かったです。現地にいた人は優勝。なんと外からでも見ることができるようにしてくれるという神対応だったので最後まで居残った人は全員見られたはず（と思う）
          [/quote]

          [quote]
          h6. Image Description

          情報量の多い画像です。配役はすぐこれだ！と思ったわけですｗ
          [/quote]
        EOS
      )
    end

    context "A tweet with alt text containing multiple paragraphs" do
      strategy_should_work(
        "https://x.com/yamada999_anime/status/1642195121319071748",
        image_urls: %w[https://pbs.twimg.com/media/FsjUfK9aYAYjmvP.jpg:orig],
        media_files: [{ file_size: 1_656_293 }],
        page_url: "https://x.com/yamada999_anime/status/1642195121319071748",
        profile_urls: %w[https://x.com/yamada999_anime https://x.com/i/user/1559447246646935552],
        display_name: "TVアニメ「山田くんとLv999の恋をする」公式",
        username: "yamada999_anime",
        tags: [
          ["山田999", "https://x.com/hashtag/山田999"],
        ],
        published_at: Time.parse("2023-04-01T16:00:02.000000Z"),
        updated_at: nil,
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          💕••┈┈┈┈┈┈┈┈•• 💕
          𝗕𝗹𝘂-𝗿𝗮𝘆&𝗗𝗩𝗗 𝗩𝗼𝗹.𝟭
          𝟲.𝟮𝟴 𝗢𝗡 𝗦𝗔𝗟𝗘
          🎮••┈┈┈┈┈┈┈┈•• 🎮

          『山田くんとLv999の恋をする』
          Blu-ray&DVD発売決定🎮

          Vol.1は6/28発売💜

          描き下ろしジャケットイラスト解禁💫

          ▼CMはこちら
          <https://youtu.be/ZNbTEIawZN4>

          "#山田999":[https://x.com/hashtag/山田999]

          [quote]
          h6. Image Description

          『山田くんとLv999の恋をする 1』
          2023.6.28(wed) Release

          完全生産限定版 Blu-ray 6,800円+税
          完全生産限定版 DVD 5,800円+税
          収録話数：Lv.01/Lv.02

          🎮完全生産限定版特典🎮
          ●原作：ましろ描き下ろし全巻収納BOX
          ●キャラクターデザイン：濱田邦彦描き下ろし三方背ケース仕様
          ●ランダムトレカ（※各巻に全3種中ランダム1枚を封入予定）
          ●特製ブックレット（8P）
          ●特典CD
          水瀬いのり・内山昂輝のラジオLv999～気のせいかな。リスナーとのこの距離の名前、知ってるよ～ vol.1
          ●特典映像
          ①PV・CM集
          ②ノンクレジットOPED
          [/quote]
        EOS
      )
    end

    context "A Twitter artist with only an intent URL in the artist profile" do
      should "find the artist" do
        @artist = create(:artist, url_string: "https://x.com/i/user/940159421677690880")
        assert_equal([@artist], Source::Extractor.find("https://x.com/ebihurya332/status/1759409576095711667").artists)
      end
    end

    context "A tweet scheduled in advance" do
      strategy_should_work(
        "https://x.com/youjosenki/status/2019697579219681539",
        image_urls: %w[https://video.twimg.com/amplify_video/2009493594315571200/vid/avc1/720x1280/rJhLuwIJ15-8HEoH.mp4?tag=14],
        image_sources: [{ published_at: Time.parse("2026-01-09T05:13:02.127000Z") }],
        media_files: [{ file_size: 5_514_218 }],
        page_url: "https://x.com/youjosenki/status/2019697579219681539",
        profile_url: "https://x.com/youjosenki",
        profile_urls: %w[https://x.com/youjosenki https://x.com/i/user/769619180949602304],
        display_name: "「幼女戦記」アニメ公式【TVシリーズ第2期 2026年放送決定！】",
        username: "youjosenki",
        published_at: Time.parse("2026-02-06T09:00:01.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          第1期 第5話より
          TVアニメ「幼女戦記Ⅱ」2026年放送決定！
        EOS
      )
    end

    context "A tweet with cashtags" do
      strategy_should_work(
        "https://x.com/FilthyAlanAnima/status/1885757085742440642",
        image_urls: %w[https://pbs.twimg.com/media/GiuNuRVbMAA6czB.jpg:orig],
        media_files: [{ file_size: 126_509 }],
        page_url: "https://x.com/FilthyAlanAnima/status/1885757085742440642",
        profile_url: "https://x.com/FilthyAlanAnima",
        profile_urls: %w[https://x.com/FilthyAlanAnima https://x.com/i/user/1509759385966325760],
        display_name: "Filthy_Alan_Animate⏳",
        username: "FilthyAlanAnima",
        published_at: Time.parse("2025-02-01T18:28:19.000000Z"),
        updated_at: nil,
        tags: [
          ["kronillust", "https://x.com/hashtag/kronillust"],
          ["クロニーラ", "https://x.com/hashtag/クロニーラ"],
          ["KRONII", "https://x.com/search?q=$KRONII"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "$KRONII":[https://x.com/search?q=$KRONII] market crash has hit her
          "#kronillust":[https://x.com/hashtag/kronillust] "#クロニーラ":[https://x.com/hashtag/クロニーラ]
        EOS
      )
    end
  end
end
