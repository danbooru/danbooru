require "test_helper"

module Sources
  class SkebTest < ActiveSupport::TestCase
    context "The source for a skeb picture" do
      strategy_should_work(
        "https://skeb.jp/@kokuzou593/works/45",
        image_urls: %w[https://si.imgix.net/1be455b2/uploads/origins/307941e9-dbe0-4e4b-93d4-94accdaff9a0?bg=%23fff&auto=format&fm=webp&w=800&s=ab82c6c148785b1c96d858244ebf68f0],
        media_files: [{ file_size: 89_008 }],
        page_url: "https://skeb.jp/@kokuzou593/works/45",
        profile_url: "https://skeb.jp/@kokuzou593",
        profile_urls: %w[https://skeb.jp/@kokuzou593],
        display_name: "こくぞう",
        username: "kokuzou593",
        tag_name: "kokuzou593",
        other_names: %w[こくぞう kokuzou593],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          こんにちは
          リゼ・ヘルエスタをリクエストします。
          服装はへそ出しのぴっちりしたニット。色はお任せします。
          （以前投稿されていた https://skeb.jp/@kokuzou593/works/32 みたいな）
          下はローライズのレザースキニー。

          こくぞうさんの描かれる腹筋がとても好きなので、
          こちらの作品（https://skeb.jp/@kokuzou593/works/35）くらいの
          腹筋を描写していただきたいです。
          よろしくお願いします。
        EOS
      )
    end

    context "A private or non-existent skeb url" do
      strategy_should_work(
        "https://skeb.jp/@qweoigjqewoirgjqerwiogqewroig/works/2",
        image_urls: [],
        page_url: "https://skeb.jp/@qweoigjqewoirgjqerwiogqewroig/works/2",
        profile_url: "https://skeb.jp/@qweoigjqewoirgjqerwiogqewroig",
        profile_urls: %w[https://skeb.jp/@qweoigjqewoirgjqerwiogqewroig],
        display_name: nil,
        username: "qweoigjqewoirgjqerwiogqewroig",
        tag_name: "qweoigjqewoirgjqerwiogqewroig",
        other_names: ["qweoigjqewoirgjqerwiogqewroig"],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A post with a smaller unwatermarked version" do
      strategy_should_work(
        "https://skeb.jp/@2gi0gi_/works/13",
        image_urls: %w[https://si.imgix.net/a5dd8523/requests/191942_0?bg=%23fff&fm=jpg&q=45&w=696&s=52ad749a9440fe471e3b7ceea2a3c1f1],
        media_files: [{ file_size: 99_950 }],
        page_url: "https://skeb.jp/@2gi0gi_/works/13",
        profile_url: "https://skeb.jp/@2gi0gi_",
        profile_urls: %w[https://skeb.jp/@2gi0gi_],
        display_name: "もわちち🌵",
        username: "2gi0gi_",
        tag_name: "2gi0gi",
        other_names: %w[もわちち🌵 2gi0gi_],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          先生のイラストが本当に大好きです！
          是非1枚お引き受けいただけると嬉しいです。

          ・スマホの壁紙に使えるサイズのイラストをお願いしたいです。
          当方iPhone 12 Proを使用していますので、
          できれば「縦位置の1170×2532px(9:19.5)」で作成をお願いできますと…
          ・キャラクターは、にじさんじの椎名唯華さんでお願いします。
          ・服装は「ゲームの日衣装（パーカー、ヘッドホン、
          ショートパンツのものです）」でお願いします。
          ・背景は可能ならお願いします。白地でも問題ないです。
          ・壁紙として使用した際、時刻表示が出る上3分の1は、空白でお願いします。
          ・椎名さんのポースですが、「上に出ている時刻を見上げている」、
          「上に出ている時刻を両手で指さしている」みたいな感じでお願いします。
          可愛くなりそうなら、指定は無視していただいて構いません。
          ・他の要素はお任せします。
          椎名さんを最高に可愛らしく描いていただけますと幸いです。
        EOS
      )
    end

    context "An animated post with a smaller static unwatermarked version" do
      strategy_should_work(
        "https://skeb.jp/@tontaro_/works/316",
        image_urls: %w[
          https://si.imgix.net/17e73ecf/uploads/origins/5097b1e1-18ce-418e-82f0-e7e2cdab1cea?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=701f0e4a2c63865fe7e295b6c66b543b
          https://si.imgix.net/4aeeffe6/uploads/origins/23123cfd-9b03-40f6-a8ae-7d74f9118c6f?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=1ac2bf12b04e3c12b65038e953fa5009
          https://si.imgix.net/06b2de18/uploads/origins/38a00949-a726-45c8-82b3-9aec4e8255ba?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=1bbe6796bb3a379732f4255c629f1ac0
        ],
        media_files: [
          { file_size: 166_207 },
          { file_size: 169_696 },
          { file_size: 174_119 },
        ],
        page_url: "https://skeb.jp/@tontaro_/works/316",
        profile_url: "https://skeb.jp/@tontaro_",
        profile_urls: %w[https://skeb.jp/@tontaro_],
        display_name: "たろー",
        username: "tontaro_",
        tag_name: "tontaro",
        other_names: %w[たろー tontaro_],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          h6. Original Request

          Hello~! I'd like to request my character cutely and happily swaying from side to side please!
          Character: https://i.imgur.com/ehYg8PE.jpg
          Animation Reference: https://imgur.com/a/y9lcwi1
          I'd appreciate it if you make the background transparent.
          Thank you!

          h6. Client Response

          Thank you very much! Very cute!
        EOS
      )
    end

    context "A post with both the small and large version clean" do
      strategy_should_work(
        "https://skeb.jp/@goma_feet/works/1",
        image_urls: %w[https://si.imgix.net/74d299ef/uploads/origins/78ca23dc-a053-4ebe-894f-d5a06e228af8?bg=%23fff&auto=format&fm=webp&w=800&s=0f091c291e3eeaa8ffe4e35a314b153e],
        media_files: [{ file_size: 102_020 }],
        page_url: "https://skeb.jp/@goma_feet/works/1",
        profile_url: "https://skeb.jp/@goma_feet",
        profile_urls: %w[https://skeb.jp/@goma_feet],
        display_name: "ごましお",
        username: "goma_feet",
        tag_name: "goma_feet",
        other_names: %w[ごましお goma_feet],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          こんにちは！
          絵柄が可愛く、発想力もあって内容も面白いので毎日楽しみにしています。けもいものが多いのも好きです。

          今回の依頼についてです。
          リグルとヤマメを描いてほしいです。(ごましおさんの描く二人が見たいです)可能であればエタニティラルバも見てみたいです。3キャラは多いのでラルバはいなくても大丈夫です。絵の内容(ストーリーなど)はおまかせします。

          よろしくお願いします！！
        EOS
      )
    end

    context "A post with two images" do
      strategy_should_work(
        "https://skeb.jp/@LambOic029/works/146",
        image_urls: %w[
          https://si.imgix.net/5827955f/uploads/origins/3fc062c5-231d-400f-921f-22d77cde54df?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=a526036c5ee23d52045f382ea627511f
          https://si.imgix.net/51934468/uploads/origins/e888bb27-e1a6-48ec-a317-7615252ff818?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=86103e0336f9199170ec4aebdda7a430
        ],
        media_files: [
          { file_size: 120_184 },
          { file_size: 110_008 },
        ],
        page_url: "https://skeb.jp/@LambOic029/works/146",
        profile_url: "https://skeb.jp/@LambOic029",
        profile_urls: %w[https://skeb.jp/@LambOic029],
        display_name: "lamb@Skeb OPEN",
        username: "LambOic029",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          リクエストお願いします：

          うちの子のリッサの水着姿絵お願いします

          カンフー使いの暗殺者キャラです

          胸の方はLambさんいつの様にくらべてもっと大きいにしてください

          服：
          紫色と白いのドクロプリント紐ビキニ、ビキニパンツはTバックにしてくだい。
          黒いスニーカー（靴下なし）
          赤いハーフフレームメガネ
          ブレスレット (資料の海っぽいのお願いします）
          右手でバタフライナイフを持っている

          ポーズをまかせて感じ
          表情はドヤ顔な感じ

          できれば、トップレスの差分お願いします

          参考資料:
          https://imgur.com/a/I6H6vIv

          よろしくお願いします！
        EOS
      )
    end

    context "A post with a video" do
      strategy_should_work(
        "https://skeb.jp/@kaisouafuro/works/112",
        image_urls: [%r{https://fcdn.skeb.jp/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a\?response-content-disposition=inline&Expires=.*&Signature=.*&Key-Pair-.*}],
        media_files: [{ file_size: 546_223 }],
        page_url: "https://skeb.jp/@kaisouafuro/works/112",
        profile_url: "https://skeb.jp/@kaisouafuro",
        profile_urls: %w[https://skeb.jp/@kaisouafuro],
        display_name: "まめすず",
        username: "kaisouafuro",
        tag_name: "kaisouafuro",
        other_names: %w[まめすず kaisouafuro],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          I would like to request an animation screen for my Twitch channel. My character is a catgirl, and has a comfortable and shy personality. Her eyes are blue with pink gradient at the bottom. Her hair is straight at the top and then wavy at the bottom. The theme is "getting ready to live stream". I want you to draw her putting on makeup, like lip gloss. Maybe she can brush her hair, or puts on her cardigan and looking into the mirror, or drink tea.
          Here is some inspiration: https://twitter.com/pokimanelol/status/1417919808922800128
          https://twitter.com/_kinami/status/1312228283002441728

          Here is her bedroom: https://gyazo.com/2296cadac880241ddea299105873e98c
          You can change it to your liking.
          Her big feature is her ears twitch, like in this video: https://www.youtube.com/watch?v=K8yGSfZ3Z7M&t=11s
          Her new hairstyle is like this: https://i.imgur.com/ZhueKCW.jpg

          You have creative freedom to do whatever you want to do, I trust you! Please have fun and no rush. Thanks for your time! ♥

          https://imgur.com/a/fyR7645
        EOS
      )
    end

    context "A https://skeb.jp/works/:id URL" do
      strategy_should_work(
        "https://skeb.jp/works/133404",
        image_urls: %w[https://si.imgix.net/5f2e397a/requests/133404_0?bg=%23fff&auto=format&fm=webp&w=800&s=a45810e69658dcc227f8dc056e7c645d],
        media_files: [{ file_size: 157_342 }],
        page_url: "https://skeb.jp/@kotora_hu/works/1",
        profile_url: "https://skeb.jp/@kotora_hu",
        profile_urls: %w[https://skeb.jp/@kotora_hu],
        display_name: "風ことら kotora Hu",
        username: "kotora_hu",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          h6. Original Request

          私のオリジナルキャラクターを描いてくだされば本当にありがたいです ! ヘアースタイルは解けた髪で 表情はツンデレのように描いてくだされば ありがたいです。衣装とポーズは自由に描いてください！ ありがとうございました！

          https://sta.sh/21hlqv84ub0x

          h6. Client Response

          とてもきれいに描いてくださって本当にありがとうございます ! ! 衣装もポーズもすごく気に入ってます !
        EOS
      )
    end

    context "A watermarked sample URL" do
      # Test that we don't alter the percent encoding of the URL, otherwise the signature will be wrong
      # page: https://skeb.jp/@LambOic029/works/146
      strategy_should_work(
        "https://si.imgix.net/5827955f/uploads/origins/3fc062c5-231d-400f-921f-22d77cde54df?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=a526036c5ee23d52045f382ea627511f",
        media_files: [{ file_size: 120_184 }]
      )
    end

    context "request key should automatically refresh" do
      setup do
        Cache.put("skeb-request-key", "invalid")
      end

      strategy_should_work(
        "https://skeb.jp/@kokuzou593/works/45",
        image_urls: ["https://si.imgix.net/1be455b2/uploads/origins/307941e9-dbe0-4e4b-93d4-94accdaff9a0?bg=%23fff&auto=format&fm=webp&w=800&s=ab82c6c148785b1c96d858244ebf68f0"],
      )
    end

    should "Parse Skeb URLs correctly" do
      assert(Source::URL.image_url?("https://skeb.imgix.net/requests/229088_2?bg=%23fff&auto=format&w=800&s=9cac8b76c0838f2df4f19ebc41c1ae0a"))
      assert(Source::URL.image_url?("https://skeb.imgix.net/uploads/origins/04d62c2f-e396-46f9-903a-3ca8bd69fc7c?bg=%23fff&auto=format&w=800&s=966c5d0389c3b94dc36ac970f812bef4"))
      assert(Source::URL.image_url?("https://skeb-production.s3.ap-northeast-1.amazonaws.com/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a?response-content-disposition=attachment%3B%20filename%3D%22458093-1.output.mp4%22%3B%20filename%2A%3DUTF-8%27%27458093-1.output.mp4&response-content-type=video%2Fmp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIVPUTFQBBL7UDSUA%2F20220221%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220221T200057Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7f028cfd9a56344cf1d42410063fad3ef30a1e47b83cef047247e0c37df01df0"))
      assert(Source::URL.image_url?("https://fcdn.skeb.jp/uploads/outputs/734e0c33-878c-4a83-bbf8-6212be31abbe?response-content-disposition=inline&Expires=1676373664&Signature=MpNqM4OiJIdkdG0o7q~22bmEA39FFhi4XXRQp5jb3RC0JxH5w6uDd6vJ552v08JGafajn-BaHYnMBg3kH86xUM8w5ySzqYB9fqHbdeIu2iiTtttQif6IdQEJnBPYrH56KXsFMftkf1nn18~GX~HSount0wnYPfPZ7bts7AepbeqOmPEspfnFMkJfemVWGCFKK-cIW1jfi2ZiAEOeSSBqxGDBJhD0LP9eJEZMJkk3ZTeFMJcTFHFXfa35wEzaZP7c6pFNKeIC8SVa2zqER46HrGPsAW316kVgfzFCP9vQ~XgZevjGJRC9BBhHLpuOKEZR-QG1ucQvPQg38cVP5DhwcQ__&Key-Pair-Id=K1GS3H53SEO647"))
      assert(Source::URL.image_url?("https://cdn.skeb.jp/uploads/outputs/734e0c33-878c-4a83-bbf8-6212be31abbe?response-content-disposition=inline&Expires=1676373664&Signature=MpNqM4OiJIdkdG0o7q~22bmEA39FFhi4XXRQp5jb3RC0JxH5w6uDd6vJ552v08JGafajn-BaHYnMBg3kH86xUM8w5ySzqYB9fqHbdeIu2iiTtttQif6IdQEJnBPYrH56KXsFMftkf1nn18~GX~HSount0wnYPfPZ7bts7AepbeqOmPEspfnFMkJfemVWGCFKK-cIW1jfi2ZiAEOeSSBqxGDBJhD0LP9eJEZMJkk3ZTeFMJcTFHFXfa35wEzaZP7c6pFNKeIC8SVa2zqER46HrGPsAW316kVgfzFCP9vQ~XgZevjGJRC9BBhHLpuOKEZR-QG1ucQvPQg38cVP5DhwcQ__&Key-Pair-Id=K1GS3H53SEO647"))

      assert(Source::URL.page_url?("https://skeb.jp/@OrvMZ/works/3"))
      assert(Source::URL.page_url?("https://skeb.jp/works/133404"))

      assert(Source::URL.profile_url?("https://skeb.jp/@asanagi"))
      assert(Source::URL.profile_url?("https://www.skeb.jp/@asanagi"))
      assert(Source::URL.profile_url?("https://skeb.jp/asanagi"))
    end
  end
end
