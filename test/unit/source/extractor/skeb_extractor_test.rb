require "test_helper"

module Source::Tests::Extractor
  class SkebExtractorTest < ActiveSupport::TestCase
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        dtext_artist_commentary_desc: "",
      )
    end

    context "A watermarked post with a smaller unwatermarked version" do
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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

    context "A watermarked animated post with a smaller static unwatermarked version" do
      strategy_should_work(
        "https://skeb.jp/@63ntm/works/9",
        image_urls: %w[
          https://si.imgix.net/30af0acc/uploads/origins/ff464279-61f1-483a-a3b3-eb541b80dd0c?bg=%23fff&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=153fc19de62af4e31dcbbc96ff111853
          https://si.imgix.net/5189de71/uploads/origins/b7fd6358-aed9-4b35-be4d-2f86b8773836?bg=%23fff&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&auto=format&fm=webp&w=800&s=468fa4953b31b9ba03285d7391106d06
        ],
        media_files: [
          { file_size: 118_871 },
          { file_size: 120_824 },
        ],
        page_url: "https://skeb.jp/@63ntm/works/9",
        profile_urls: %w[https://skeb.jp/@63ntm],
        display_name: "ഒ",
        username: "63ntm",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          はじめまして、ナツメ様！
          ナツメ様のスタイルが本当に大好きで、良ければ、こちらの創作キャラクターを描いていただきたいです！

          ・絆創膏だらけと病みかわな雰囲気
          ・泣き顔／天然／無表情
          ・服装はセーラー服とメイド服（セーラー服+エプロンのデザイン、フリル多めだとうれしいです）
          ・背景と小物は全て自由にお願いします

          キャラデザインの一部を変更しても構いませんのでお好きなように描いていただい、どうぞ宜しくお願い致します♡

          https://drive.google.com/drive/folders/1a7LmxJvHyTfM7xEgATZ2BaFAwBQ9Gxte
        EOS
      )
    end

    context "A post with both the small and large version unwatermarked" do
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
          こんにちは！
          絵柄が可愛く、発想力もあって内容も面白いので毎日楽しみにしています。けもいものが多いのも好きです。

          今回の依頼についてです。
          リグルとヤマメを描いてほしいです。(ごましおさんの描く二人が見たいです)可能であればエタニティラルバも見てみたいです。3キャラは多いのでラルバはいなくても大丈夫です。絵の内容(ストーリーなど)はおまかせします。

          よろしくお願いします！！
        EOS
      )
    end

    context "A post with two watermarked images" do
      strategy_should_work(
        "https://skeb.jp/@LambOic029/works/146",
        image_urls: [
          %r{si.imgix.net/5827955f/uploads/origins/3fc062c5-231d-400f-921f-22d77cde54df?.*&w=800},
          %r{si.imgix.net/51934468/uploads/origins/e888bb27-e1a6-48ec-a317-7615252ff818?.*&w=800},
        ],
        media_files: [
          { file_size: 120_362 },
          { file_size: 109_932 },
        ],
        page_url: "https://skeb.jp/@LambOic029/works/146",
        profile_url: "https://skeb.jp/@LambOic029",
        profile_urls: %w[https://skeb.jp/@LambOic029],
        display_name: "lamb@Skeb OPEN",
        username: "LambOic029",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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

    context "A post with an unwatermarked video" do
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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

    context "A https://skeb.jp/works/:id post with an unwatermarked image" do
      strategy_should_work(
        "https://skeb.jp/@kz12_nb/works/13",
        image_urls: %w[https://si.imgix.net/ea5bad96/uploads/origins/18def21b-d39c-44f7-be5b-b5c2b7e9c467?bg=%23fff&auto=format&fm=webp&w=800&s=941a593992956f23f1812fb148809ad9],
        media_files: [{ file_size: 174_000 }],
        page_url: "https://skeb.jp/@kz12_nb/works/13",
        profile_urls: %w[https://skeb.jp/@kz12_nb],
        display_name: "弱。",
        username: "kz12_nb",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h6. Original Request

          はじめまして、以前描かれていた鈴原るるや、鈴木あんずがとても魅力的です。
          私の推しであるプリンセスコネクトのアオイちゃんを描いてほしいです。
          構図等はおまかせしますが、参考までに前回描かれていた、赤い眼鏡をかけた鈴木あんずの雰囲気に似せていただけると嬉しいです。

          h6. Client Response

          ありがとうございました！！！！！とっっってもキュートです！！！！！！！！！！！
        EOS
      )
    end

    context "A watermarked sample URL" do
      # Test that we don't alter the percent encoding of the URL, otherwise the signature will be wrong
      # page: https://skeb.jp/@LambOic029/works/146
      strategy_should_work(
        "https://si.imgix.net/5827955f/uploads/origins/3fc062c5-231d-400f-921f-22d77cde54df?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=a526036c5ee23d52045f382ea627511f",
        media_files: [{ file_size: 120_362 }],
      )
    end
  end
end
