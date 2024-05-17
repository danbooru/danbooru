require 'test_helper'

module Sources
  class TwitterTest < ActiveSupport::TestCase
    context "A Twitter profile picture sample image" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs_400x400.jpeg",
        image_urls: %w[https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs.jpeg],
        media_files: [{ file_size: 203_927, width: 1252, height: 1252 }],
        page_url: nil,
        profile_urls: %w[https://twitter.com/intent/user?user_id=417182061145780225]
      )
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
        media_files: [
          { file_size: 275_713 },
          { file_size: 207_248 },
          { file_size: 188_553 },
        ],
        profile_url: "https://twitter.com/motty08111213",
        display_name: "丸茂_えのぐマネージャー",
        username: "motty08111213",
        tags: ["岩本町芸能社", "女優部"],
        dtext_artist_commentary_desc: <<~EOS.chomp
          岩本町芸能社女優部のタレント3名がHPに公開されました。
          部署が違うので私の担当ではありませんが、みんなとても良い子たちです。
          あんずと環 同様、応援していただけると嬉しいです…！
          詳細はこちらから↓
          <http://rbc-geino.com/profile_2/>
          "#岩本町芸能社":[https://twitter.com/hashtag/岩本町芸能社] "#女優部":[https://twitter.com/hashtag/女優部]
        EOS
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
        profile_url: "https://twitter.com/motty08111213",
        display_name: "丸茂_えのぐマネージャー",
        username: "motty08111213",
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
        profile_url: "https://twitter.com/motty08111213",
        display_name: "丸茂_えのぐマネージャー",
        username: "motty08111213",
        tags: ["岩本町芸能社", "女優部"]
      )
    end

    context "A https://x.com/i/status/:id url" do
      strategy_should_work(
        "https://x.com/i/status/943446161586733056",
        page_url: "https://twitter.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://twitter.com/motty08111213",
        display_name: "丸茂_えのぐマネージャー",
        username: "motty08111213",
        tags: ["岩本町芸能社", "女優部"]
      )
    end

    context "A video tweet" do
      strategy_should_work(
        "https://twitter.com/CincinnatiZoo/status/859073537713328129",
        image_urls: ["https://video.twimg.com/ext_tw_video/859073467769126913/pu/vid/1280x720/cPGgVROXHy3yrK6u.mp4"],
        page_url: "https://twitter.com/CincinnatiZoo/status/859073537713328129",
        media_files: [{ file_size: 8_603_100 }],
        dtext_artist_commentary_desc: <<~EOS.chomp
          Fiona loves playing in the hose water just like her parents! 💦 "#TeamFiona":[https://twitter.com/hashtag/TeamFiona] "#fionafix":[https://twitter.com/hashtag/fionafix]
        EOS
      )
    end

    context "A video thumbnail" do
      # https://twitter.com/Kekeflipnote/status/1241038667898118144
      strategy_should_work(
        "https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:small",
        image_urls: ["https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:orig"],
        media_files: [{ file_size: 18_058 }]
      )
    end

    context "An external video thumbnail" do
      strategy_should_work(
        "https://pbs.twimg.com/ext_tw_video_thumb/1578376127801761793/pu/img/oGcUqPnwRYYhk-gi.jpg:small",
        image_urls: ["https://pbs.twimg.com/ext_tw_video_thumb/1578376127801761793/pu/img/oGcUqPnwRYYhk-gi.jpg:orig"],
        media_files: [{ file_size: 243_227 }]
      )
    end

    context "An amplify video thumbnail" do
      # https://twitter.com/UNITED_CINEMAS/status/1223138847417978881
      strategy_should_work(
        "https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:small",
        image_urls: ["https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:orig"],
        media_files: [{ file_size: 106_942 }]
      )
    end

    context "A /tweet_video/ URL" do
      strategy_should_work(
        "https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4",
        image_urls: ["https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4"],
        media_files: [{ file_size: 542_833 }],
        page_url: nil
      )
    end

    context "A tweet with an animated gif" do
      strategy_should_work(
        "https://twitter.com/i/web/status/1252517866059907073",
        image_urls: ["https://video.twimg.com/tweet_video/EWHWVrmVcAAp4Vw.mp4"],
        media_files: [{ file_size: 542_833 }],
        artist_commentary_desc: "https://t.co/gyTKOSBOQ7",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A mixed-media tweet" do
      strategy_should_work(
        "https://twitter.com/twotenky/status/1577831592227000320",
        image_urls: %w[
          https://pbs.twimg.com/media/FeWVcf2VUAATTey.jpg:orig
          https://video.twimg.com/tweet_video/FeWVcf4VQAAIPTe.mp4
        ],
        page_url: "https://twitter.com/twotenky/status/1577831592227000320",
        display_name: "通天機",
        username: "twotenky",
        profile_url: "https://twitter.com/twotenky",
        artist_commentary_desc: "動画と静止画がセットでお得と聞いて https://t.co/hWvKoHLN7y",
        dtext_artist_commentary_desc: "動画と静止画がセットでお得と聞いて",
      )
    end

    context "A restricted tweet" do
      strategy_should_work(
        "https://mobile.twitter.com/Strangestone/status/556440271961858051",
        image_urls: ["https://pbs.twimg.com/media/B7jfc1JCcAEyeJh.png:orig"],
        media_files: [{ file_size: 280_150 }],
        page_url: "https://twitter.com/Strangestone/status/556440271961858051",
        profile_url: "https://twitter.com/Strangestone",
        profile_urls: ["https://twitter.com/Strangestone", "https://twitter.com/intent/user?user_id=93332575"],
        display_name: "比村奇石",
        username: "Strangestone",
        dtext_artist_commentary_desc: "ブレザーが描きたかったのでJK鈴谷"
      )
    end

    context "A NSFW tweet" do
      strategy_should_work(
        "https://twitter.com/shoka_bg/status/1644344692107268097",
        image_urls: ["https://pbs.twimg.com/media/FtHbwvuaQAAxQ8v.jpg:orig"],
        page_url: "https://twitter.com/shoka_bg/status/1644344692107268097",
        profile_url: "https://twitter.com/shoka_bg",
        profile_urls: ["https://twitter.com/shoka_bg", "https://twitter.com/intent/user?user_id=1109709388049051649"],
        display_name: "shooka @土曜 西 “ね” 41a",
        username: "shoka_bg",
        tags: %w[ブルアカ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          風紀委員の実態
          "#ブルアカ":[https://twitter.com/hashtag/ブルアカ]
        EOS
      )
    end

    context "A long tweet with >280 characters" do
      strategy_should_work(
        "https://twitter.com/loveremi_razoku/status/1637647185969041408",
        image_urls: ["https://pbs.twimg.com/media/FroXbmIaIAEuC1B.jpg:orig"],
        page_url: "https://twitter.com/loveremi_razoku/status/1637647185969041408",
        profile_url: "https://twitter.com/loveremi_razoku",
        profile_urls: ["https://twitter.com/loveremi_razoku", "https://twitter.com/intent/user?user_id=293443351"],
        display_name: "ラブレミ@うぉるやふぁんくらぶ",
        username: "loveremi_razoku",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp
          「ラリアッ党の野望チョコ」
          commission ラリアット さん"@rariatoo":[https://twitter.com/rariatoo]

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
        page_url: "https://twitter.com/emurin/status/912861472916508672",
        profile_url: "https://twitter.com/emurin",
        profile_urls: ["https://twitter.com/emurin", "https://twitter.com/intent/user?user_id=30642502"],
        display_name: "えむりん",
        username: "emurin",
        tags: %w[odaibako],
        dtext_artist_commentary_desc: <<~EOS.chomp
          > ほわほわ系クーデレギロチンおねがいします <https://odaibako.net/detail/request/277bac5ea1b34b1abc7ac21dd1031690> "#odaibako":[https://twitter.com/hashtag/odaibako]

          セカコスにしたらギロクロ感がなくなった…
        EOS
      )
    end

    context "A tweet that from an account that is set to followers-only" do
      strategy_should_work(
        "https://twitter.com/enaiC31/status/1644997451626221568",
        image_urls: ["https://pbs.twimg.com/media/FtQ0ddcaAAAkSvS.jpg:orig"],
        page_url: "https://twitter.com/enaiC31/status/1644997451626221568",
        profile_url: "https://twitter.com/enaiC31",
        profile_urls: ["https://twitter.com/enaiC31", "https://twitter.com/intent/user?user_id=1444938344891240452"],
        display_name: "えない🚀",
        username: "enaiC31",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp
          すろぉもぉしょん💊
        EOS
      )
    end

    context "A 'https://pbs.twimg.com/media/*:large' url" do
      strategy_should_work(
        "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large",
        referer: "https://twitter.com/nounproject/status/540944400767922176",
        image_urls: ["https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"],
        media_files: [{ file_size: 9800 }],
        page_url: "https://twitter.com/nounproject/status/540944400767922176",
        profile_url: "https://twitter.com/nounproject",
        profile_urls: ["https://twitter.com/nounproject", "https://twitter.com/intent/user?user_id=88996186"],
        display_name: "Noun Project",
        username: "nounproject",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp
          More is better. Unlimited is best. NounPro Members now get unlimited icon downloads <http://bit.ly/1yn2KWn>
        EOS
      )
    end

    context "A tweet without any images" do
      strategy_should_work(
        "https://twitter.com/teruyo/status/1058452066060853248",
        profile_url: "https://twitter.com/teruyo",
        image_urls: [],
        dtext_artist_commentary_desc: "all the women washizutan2 draws look like roast chicken",
      )
    end

    context "A direct image url" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EBGp2YdUYAA19Uj?format=jpg&name=small",
        image_urls: ["https://pbs.twimg.com/media/EBGp2YdUYAA19Uj.jpg:orig"],
        media_files: [{ file_size: 229_661 }],
        profile_url: nil
      )
    end

    context "A direct image url with dashes" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg",
        image_urls: ["https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg:orig"],
        media_files: [{ file_size: 842_373 }],
        profile_url: nil
      )
    end

    context "A direct image url with a referer url from a different site" do
      strategy_should_work(
        "https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg",
        referer: "https://www.pixiv.net/en/artworks/60344190",
        image_urls: ["https://pbs.twimg.com/media/EAjc-OWVAAAxAgQ.jpg:orig"],
        media_files: [{ file_size: 842_373 }],
        page_url: nil
      )
    end

    context "A deleted tweet" do
      strategy_should_work(
        "https://twitter.com/masayasuf/status/870734961778630656",
        deleted: true,
        username: "masayasuf",
        profile_url: "https://twitter.com/masayasuf",
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A tweet from a suspended user" do
      strategy_should_work(
        "https://twitter.com/tanso_panz/status/1192429800717029377",
        username: "tanso_panz",
        profile_url: "https://twitter.com/tanso_panz",
        image_urls: [],
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A https://fxtwitter.com/:username/status/:id url" do
      strategy_should_work(
        "https://fxtwitter.com/motty08111213/status/943446161586733056",
        page_url: "https://twitter.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://twitter.com/motty08111213"
      )
    end

    context "A https://vxtwitter.com/:username/status/:id url" do
      strategy_should_work(
        "https://vxtwitter.com/motty08111213/status/943446161586733056",
        page_url: "https://twitter.com/motty08111213/status/943446161586733056",
        image_urls: [
          "https://pbs.twimg.com/media/DRfKHmgV4AAycFB.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHioVoAALRlK.jpg:orig",
          "https://pbs.twimg.com/media/DRfKHgHU8AE7alV.jpg:orig",
        ],
        profile_url: "https://twitter.com/motty08111213"
      )
    end

    context "A profile banner image" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_banners/16298441/1394248006/1500x500",
        image_urls: ["https://pbs.twimg.com/profile_banners/16298441/1394248006/1500x500"],
        media_files: [{ file_size: 108_605 }],
        profile_url: nil
        # profile_url: "https://twitter.com/intent/user?user_id=780804311529906176"
        # XXX we COULD fully support these by setting the page_url to https://twitter.com/Kekeflipnote/header_photo, but it's a lot of work for a niche case
      )
    end

    context "A profile banner image sample" do
      strategy_should_work(
        "https://pbs.twimg.com/profile_banners/16298441/1394248006/600x200",
        image_urls: ["https://pbs.twimg.com/profile_banners/16298441/1394248006/1500x500"],
        media_files: [{ file_size: 108_605 }],
        page_url: nil,
        profile_url: nil
      )
    end

    context "An /ad_img/ image sample" do
      strategy_should_work(
        "https://pbs.twimg.com/ad_img/1415875929608396801/pklSzcPz?format=jpg&name=small",
        image_urls: ["https://pbs.twimg.com/ad_img/1415875929608396801/pklSzcPz?format=jpg&name=orig"],
        media_files: [{ file_size: 159_186 }],
        page_url: nil,
        profile_url: nil
      )
    end

    context "A tweet with hashtags with normalizable prefixes" do
      strategy_should_work(
        "https://twitter.com/kasaishin100/status/1186658635226607616",
        tags: ["西住みほ生誕祭2019"],
        normalized_tags: ["西住みほ"],
        dtext_artist_commentary_desc: <<~EOS.chomp
          みぽりん誕生日おめでとうございます！！🎂
          ボコボコ探検隊🙌✨
          "#西住みほ生誕祭2019":[https://twitter.com/hashtag/西住みほ生誕祭2019]
        EOS
      )
    end

    context "A tweet with mentions that can be converted to dtext" do
      strategy_should_work(
        "https://twitter.com/noizave/status/875768175136317440",
        dtext_artist_commentary_desc: 'test "#foo":[https://twitter.com/hashtag/foo] "#ホワイトデー":[https://twitter.com/hashtag/ホワイトデー] "@noizave":[https://twitter.com/noizave]\'s blah <http://www.example.com> <>& 😀'
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
        dtext_artist_commentary_desc: %{新しいおともだち\n"#けものフレンズ":[https://twitter.com/hashtag/けものフレンズ]}
      )
    end

    context "A tweet with mega.nz links" do
      strategy_should_work(
        "https://twitter.com/VG_Worklog/status/1587457941418160128",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Sound by: "@RealAudiodude":[https://twitter.com/RealAudiodude]\x20
          Download: <https://mega.nz/folder/i80gVL7L#111g2XX7bIJ-2KnAHxMt0w>
          Support: <https://www.patreon.com/vgerotica>
        EOS
      )
    end

    context "A tweet with fullwidth parentheses" do
      strategy_should_work(
        "https://twitter.com/Chanta_in_inari/status/1031042032934871041",
        dtext_artist_commentary_desc: <<~EOS.chomp
          政長さん（<https://twitter.com/naga_masanaga>）の藍様線画を塗ってましたあ。
          うーん、かわいい。
        EOS
      )
    end

    context "A tweet with cashtags" do
      strategy_should_work(
        "https://twitter.com/CFRJacobsson/status/1608788299665276931",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "$GOOG":[https://twitter.com/search?q=$GOOG] is the next "$IBM":[https://twitter.com/search?q=$IBM] 🧵

          1/7
        EOS
      )
    end

    context "A tweet with escaped HTML characters" do
      strategy_should_work(
        "https://twitter.com/takobe_t/status/1777662729890730410",
        dtext_artist_commentary_desc: <<~EOS.chomp
          ロザリンデ&エルトリンデ
          "#ユニコーンオーバーロード":[https://twitter.com/hashtag/ユニコーンオーバーロード]
        EOS
      )
    end

    context "A tweet with 'issue #1'" do
      strategy_should_work(
        "https://twitter.com/Persona_Central/status/1750173292588097879",
        dtext_artist_commentary_desc: <<~EOS.chomp
          The new Shigenori Soejima illustration for Persona 3 Reload in Weekly Famitsu magazine issue &num;1834. "#P3R":[https://twitter.com/hashtag/P3R]
        EOS
      )
    end

    context "A Twitter artist with only an intent URL in the artist profile" do
      should "find the artist" do
        @artist = create(:artist, url_string: "https://twitter.com/intent/user?user_id=940159421677690880")
        assert_equal([@artist], Source::Extractor.find("https://twitter.com/ebihurya332/status/1759409576095711667").artists)
      end
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
      assert(Source::URL.page_url?("https://twitter.com/@BOW999/status/1261877313349640194"))

      assert(Source::URL.page_url?("https://x.com/i/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://x.com/i/web/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://x.com/BOW999/status/1261877313349640194"))

      assert(Source::URL.profile_url?("https://www.twitter.com/irt_5433"))
      assert(Source::URL.profile_url?("https://www.twitter.com/@irt_5433"))
      assert(Source::URL.profile_url?("https://www.twitter.com/irt_5433/likes"))
      assert(Source::URL.profile_url?("https://twitter.com/intent/user?user_id=1485229827984531457"))
      assert(Source::URL.profile_url?("https://twitter.com/intent/user?screen_name=ryuudog_NFT"))
      assert(Source::URL.profile_url?("https://twitter.com/i/user/889592953"))

      assert(Source::URL.profile_url?("https://x.com/irt_5433"))
      assert(Source::URL.profile_url?("https://x.com/intent/user?user_id=1485229827984531457"))
      assert(Source::URL.profile_url?("https://x.com/intent/user?screen_name=ryuudog_NFT"))
      assert(Source::URL.profile_url?("https://x.com/i/user/889592953"))

      assert(Source::URL.page_url?("https://vxtwitter.com/i/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://vxtwitter.com/i/web/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://vxtwitter.com/@BOW999/status/1261877313349640194"))
      assert(Source::URL.profile_url?("https://vxtwitter.com/irt_5433"))
      assert(Source::URL.profile_url?("https://vxtwitter.com/intent/user?user_id=1485229827984531457"))
      assert(Source::URL.profile_url?("https://vxtwitter.com/intent/user?screen_name=ryuudog_NFT"))
      assert(Source::URL.profile_url?("https://vxtwitter.com/i/user/889592953"))

      assert(Source::URL.page_url?("https://fxtwitter.com/i/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://fxtwitter.com/i/web/status/1261877313349640194"))
      assert(Source::URL.page_url?("https://fxtwitter.com/@BOW999/status/1261877313349640194"))
      assert(Source::URL.profile_url?("https://fxtwitter.com/irt_5433"))
      assert(Source::URL.profile_url?("https://fxtwitter.com/intent/user?user_id=1485229827984531457"))
      assert(Source::URL.profile_url?("https://fxtwitter.com/intent/user?screen_name=ryuudog_NFT"))
      assert(Source::URL.profile_url?("https://fxtwitter.com/i/user/889592953"))

      assert_not(Source::URL.profile_url?("https://twitter.com/home"))
      assert_not(Source::URL.profile_url?("https://t.co/Dxn7CuVErW"))
      assert_not(Source::URL.profile_url?("https://pic.twitter.com/Dxn7CuVErW"))

      assert_not(Source::URL.bad_link?("https://pbs.twimg.com/profile_banners/780804311529906176/1475001696"))
      assert_not(Source::URL.bad_source?("https://pbs.twimg.com/profile_banners/780804311529906176/1475001696"))
      assert_not(Source::URL.bad_link?("https://twitter.com/merry_bongbong/header_photo"))
      assert_not(Source::URL.bad_source?("https://twitter.com/merry_bongbong/header_photo"))

      assert_nil(Source::URL.parse("https://twitter.com/i/status/1261877313349640194").username)
      assert_nil(Source::URL.parse("https://twitter.com/i/web/status/1261877313349640194").username)
      assert_nil(Source::URL.parse("https://t.co/Dxn7CuVErW").try(:username))
      assert_nil(Source::URL.parse("https://pic.twitter.com/Dxn7CuVErW").try(:username))
      assert_equal("BOW999", Source::URL.parse("https://twitter.com/BOW999/status/1261877313349640194").username)
      assert_equal("BOW999", Source::URL.parse("https://twitter.com/@BOW999/status/1261877313349640194").username)
      assert_equal("BOW999", Source::URL.parse("https://twitter.com/@BOW999").username)

      assert_equal("https://twitter.com/BOW999/status/1261877313349640194", Source::URL.parse("https://fixvx.com/BOW999/status/1261877313349640194").page_url)
      assert_equal("https://twitter.com/BOW999/status/1261877313349640194", Source::URL.parse("https://fixupx.com/BOW999/status/1261877313349640194").page_url)
      assert_equal("https://twitter.com/BOW999/status/1261877313349640194", Source::URL.parse("https://twittpr.com/BOW999/status/1261877313349640194").page_url)
      assert_equal("https://twitter.com/BOW999/status/1261877313349640194", Source::URL.parse("https://fxtwitter.com/BOW999/status/1261877313349640194.jpg").page_url)
    end
  end
end
