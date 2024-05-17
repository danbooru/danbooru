# frozen_string_literal: true

require "test_helper"

module Sources
  class NoteTest < ActiveSupport::TestCase
    context "Note:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png?width=800&dpr=2",
          image_urls: %w[https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png],
          media_files: [{ file_size: 4_570_943 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A full image URL" do
        strategy_should_work(
          "https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png",
          image_urls: %w[https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png],
          media_files: [{ file_size: 4_570_943 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Note image post with a single image with a caption" do
        strategy_should_work(
          "https://note.com/koma_labo/n/n32fb90fac512",
          image_urls: %w[https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png],
          media_files: [{ file_size: 4_570_943 }],
          page_url: "https://note.com/koma_labo/n/n32fb90fac512",
          profile_url: "https://note.com/koma_labo",
          profile_urls: %w[https://note.com/koma_labo],
          display_name: "Koma-Labo",
          username: "koma_labo",
          tag_name: "koma_labo",
          other_names: ["Koma-Labo", "koma_labo"],
          tags: [
            ["イラスト", "https://note.com/hashtag/イラスト"],
            ["バイク", "https://note.com/hashtag/バイク"],
            ["NSR250R", "https://note.com/hashtag/NSR250R"],
          ],
          dtext_artist_commentary_title: "NSR250R MC21",
          dtext_artist_commentary_desc: <<~EOS.chomp
            ＜ご依頼品＞オーナー様 Twitter：@potatohedron 様
          EOS
        )
      end

      context "A Note image post with multiple images, none with captions" do
        strategy_should_work(
          "https://note.com/poisongiant/n/n12fc4ec79d24",
          image_urls: %w[
            https://d2l930y2yx77uc.cloudfront.net/img/1644650226241-bzIA1lJqZ5.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1644650226235-KvbOotyDxw.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1644650226282-CHFfsrvUqu.jpg
          ],
          media_files: [
            { file_size: 417_531 },
            { file_size: 345_743 },
            { file_size: 534_977 },
          ],
          page_url: "https://note.com/poisongiant/n/n12fc4ec79d24",
          profile_url: "https://note.com/poisongiant",
          profile_urls: %w[https://note.com/poisongiant],
          display_name: "ポイズン",
          username: "poisongiant",
          tag_name: "poisongiant",
          other_names: ["ポイズン", "poisongiant"],
          tags: [
            ["イラスト", "https://note.com/hashtag/イラスト"],
            ["Skeb", "https://note.com/hashtag/Skeb"],
          ],
          dtext_artist_commentary_title: "ドゥーちゃん設定画",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Note text post" do
        strategy_should_work(
          "https://note.com/cavico/n/n4cab95a96599",
          image_urls: %w[
            https://d2l930y2yx77uc.cloudfront.net/img/1672450615522-C1tkj2EAhv.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1672469225530-6fF1k33zSW.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1672451817934-qHZavzSrRk.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1672456423416-dEv2o3m4CP.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1672456689309-j5azQr06es.png
            https://d2l930y2yx77uc.cloudfront.net/img/1672469430254-y6efkY1ucK.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1672457635400-hOCx3h2uNX.png
            https://d2l930y2yx77uc.cloudfront.net/img/1672458675344-uJIH5ybFGq.png
            https://d2l930y2yx77uc.cloudfront.net/img/1672458234327-hxh3McIFGk.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1672458619944-5S2pybSiK0.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1672459865021-VFP6dCO08P.jpg
          ],
          media_files: [
            { file_size: 86_455 },
            { file_size: 944_163 },
            { file_size: 79_475 },
            { file_size: 161_103 },
            { file_size: 537_262 },
            { file_size: 413_931 },
            { file_size: 549_070 },
            { file_size: 521_116 },
            { file_size: 824_368 },
            { file_size: 1_102_310 },
            { file_size: 960_615 },
          ],
          page_url: "https://note.com/cavico/n/n4cab95a96599",
          profile_url: "https://note.com/cavico",
          profile_urls: %w[https://note.com/cavico],
          display_name: "キャビコ",
          username: "cavico",
          tag_name: "cavico",
          other_names: ["キャビコ", "cavico"],
          tags: [
            ["キャビコ", "https://note.com/hashtag/キャビコ"],
            ["メカトロウィーゴ", "https://note.com/hashtag/メカトロウィーゴ"],
            ["メカトロポリス", "https://note.com/hashtag/メカトロポリス"],
          ],
          dtext_artist_commentary_title: "メカデザイナー大河原邦男×モデリズム 小林和史＝【メカトロポリス】",
          dtext_artist_commentary_desc: <<~EOS.chomp
            みなさん新年あけましておめでとうございます。2023年もキャビコをどうぞよろしくお願いいたします。

            新年最初にご紹介するのは、キャビコの新しいプラキット化アイテム[b]「メカトロポリス」[/b]です。これをデザインされたのはあのレジェンド"メカデザイナー[b]大河原邦男[/b]":[https://ja.wikipedia.org/wiki/%E5%A4%A7%E6%B2%B3%E5%8E%9F%E9%82%A6%E7%94%B7]氏です。"モデリズム":[http://moderhythm.blog26.fc2.com/]の"小林和史":[https://twitter.com/kobax27]氏が生み出した「"[b]メカトロウィーゴ[/b]":[https://chubu01.wixsite.com/moderhythm/untitled-c119c][b]」[/b]を大河原氏が大胆にアレンジすることで生み出されたのが、今回ご紹介する「メカトロポリス」なるオリジナルロボットです。

            "[image]":[https://assets.st-note.com/img/1672450615522-C1tkj2EAhv.jpg]

            メカデザイナー大河原邦男氏によって描かれたメカトロポリスのデザイン画

            この「メカトロポリス」が誕生したきっかけは、小林氏がある取材の折に「メカトロウィーゴで何かやってみたい事はありますか？」 と聞かれたことでした。

            "[image]":[https://assets.st-note.com/img/1672469225530-6fF1k33zSW.jpg]

            小林氏が生み出した「メカトロウィーゴ」

            その質問に対し小林氏は『夢のある話』として[b]「大河原邦男先生にウィーゴを描いてもらえたら最高です」[/b] と答えたそうです。そんな『夢』が実現したのがこの[b]「メカトロポリス」[/b]なのです。

            "[image]":[https://assets.st-note.com/img/1672451817934-qHZavzSrRk.jpg]

            メカトロウィーゴを大幅に強化したかのようなリアビュー

            小林氏は大河原氏との打ち合わせの際に、「あまり元デザインとの整合性などは考えず、自由に描いて頂けたら嬉しい」と話されたそうです。その結果として誕生したのが『これぞまさしく大河原メカ』といった一枚のイラストでした。

            "[image]":[https://assets.st-note.com/img/1672456423416-dEv2o3m4CP.jpg]

            大河原氏によるメカトロポリスのコンセプトイラスト

            実は小林氏、大河原先生からデザインを頂いた直後から３Dモデリングを始めていたそうです。そして 「いつかどこかのメーカーで製品化してもらえたらいいな」と考えながら検証を進めていたとのこと。

            "[image]":[https://assets.st-note.com/img/1672456689309-j5azQr06es.png]

            小林氏による3Dデータ(未完成状態)

            そんな折、静岡ホビーショーでキャビコブースを訪れた小林氏からメカトロポリスの存在を知らされた我々は、すぐさま(その場で)キャビコでのプラキット化をオファーしました。キャビコとしても、メカトロウィーゴを生み出した小林氏とはいつか一緒にお仕事をしたいと思っていました。しかもキャビコ最初のプラキット"[b]「イグザイン」[/b]":[https://twitter.com/iXine_feat_MIM]をデザインされた大河原先生が手掛けたロボであればこれ以上の組み合わせはありません。

            "[image]":[https://assets.st-note.com/img/1672469430254-y6efkY1ucK.jpg]

            メカデザイナー大河原邦男氏がデザインしたキャビコ初のプラキット「イグザイン」

            ウィーゴファンにも、大河原メカファンにも楽しんで頂ける最高のプラキットが創れると確信を持っています。

            プラキット化にあたって、当初は側面図を元に制作していた3Dモデルを全面的に見直し、より大河原氏の決めポーズ画稿に合わせたリモデリングを小林氏自らが行ってくださいました。

            "[image]":[https://assets.st-note.com/img/1672457635400-hOCx3h2uNX.png]

            小林氏によって修正された3Dデータ

            "[image]":[https://assets.st-note.com/img/1672458675344-uJIH5ybFGq.png]

            チカラ強いリアビュー

            その結果として3D出力したのがこのモックアップです。

            "[image]":[https://assets.st-note.com/img/1672458234327-hxh3McIFGk.jpg]

            フロントビュー

            "[image]":[https://assets.st-note.com/img/1672458619944-5S2pybSiK0.jpg]

            リアビュー

            このモックアップは現在、小林氏自らの手によって彩色作業を行ってもらっています。2月26日のキャビコ5周年イベント[b]「おかげさまです。キャビコです。」[/b]では彩色済みのモックアップを展示するとともに、小林氏にも[b]「モデリズム ブース」[/b]を出展していただけることになりました。

            <http://moderhythm.blog26.fc2.com/>

            イベント当日はここでしか買えないアイテムも発売されるかもしれませんので、ぜひ楽しみにしていてください。

            それではみなさん本年もキャビコをどうぞよろしくお願いいたします。担当Nでした。

            ©MODERHYTHM/Kazushi Kobayashi

            "[image]":[https://assets.st-note.com/img/1672459865021-VFP6dCO08P.jpg]
          EOS
        )
      end

      context "A Note post with a custom domain" do
        strategy_should_work(
          "https://sanriotimes.sanrio.co.jp/n/nf3fa7f0c4c9d",
          image_urls: %w[
            https://d2l930y2yx77uc.cloudfront.net/img/1698394901128-tFVwwyPjTW.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1698395457170-LJgalVpfih.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1698395550982-oFNkerP4z5.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1698395728775-CVKFAYl9wI.png
            https://d2l930y2yx77uc.cloudfront.net/img/1698642540697-UYubbp0F9o.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1698395781646-Z97dTKFvPB.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1698394845446-Nfu0Qlok3X.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1698718972564-W0rscG1gBo.png
            https://d2l930y2yx77uc.cloudfront.net/img/1698652768645-Q3BmWTCUUd.png
            https://d2l930y2yx77uc.cloudfront.net/img/1698396135123-BH4g8iFcxA.png
            https://d2l930y2yx77uc.cloudfront.net/img/1698394966797-MlP1TpeZhl.jpg
            https://d2l930y2yx77uc.cloudfront.net/img/1698395019868-totpG7DPq2.jpg
          ],
          media_files: [
            { file_size: 779_469 },
            { file_size: 989_270 },
            { file_size: 1_995_758 },
            { file_size: 252_064 },
            { file_size: 74_583 },
            { file_size: 400_594 },
            { file_size: 856_723 },
            { file_size: 3_236_975 },
            { file_size: 47_391 },
            { file_size: 1_122_468 },
            { file_size: 940_300 },
            { file_size: 1_176_143 },
          ],
          page_url: "https://sanriotimes.sanrio.co.jp/n/nf3fa7f0c4c9d",
          profile_url: "https://sanriotimes.sanrio.co.jp",
          profile_urls: %w[https://sanriotimes.sanrio.co.jp],
          display_name: "SanrioTimes",
          username: "sanrio_times",
          tag_name: "sanrio_times",
          other_names: ["SanrioTimes", "sanrio_times"],
          tags: [
            ["キャラクター", "https://note.com/hashtag/キャラクター"],
            ["企業のnote", "https://note.com/hashtag/企業のnote"],
            ["ハローキティ", "https://note.com/hashtag/ハローキティ"],
            ["サンリオ時間", "https://note.com/hashtag/サンリオ時間"],
            ["サンリオタイムズ", "https://note.com/hashtag/サンリオタイムズ"],
            ["hellokitty", "https://note.com/hashtag/hellokitty"],
            ["サンリオnote", "https://note.com/hashtag/サンリオnote"],
            ["ハローキティ50周年", "https://note.com/hashtag/ハローキティ50周年"],
            ["アニバーサリーイヤー", "https://note.com/hashtag/アニバーサリーイヤー"],
          ],
          dtext_artist_commentary_title: "５０周年のアニバーサリーイヤーを迎えて。  ハローキティに特別インタビュー！",
          dtext_artist_commentary_desc: <<~EOS.chomp
            みなさん、こんにちは。Sanrio Times編集担当です。2024年、「ハローキティ」は50周年を迎えます。
            サンリオでは、2023年11月1日から2024年12月31日を「ハローキティ」の50周年アニバーサリーイヤーとして、いろいろな企画をお届けしていく予定です。テーマは、「Friend the Future．未来と友達になろう。」

            今回はアニバーサリーイヤーを迎えるにあたり、“キティ”に特別インタビューをしました。懐かしい「ハローキティ」のビジュアルも織り混ぜながら、“キティ”の「いまの想い」をお届けします。

            h2. アニバーサリーイヤーを迎えた今の気持ち

            ―[b]キティちゃん、今日はよろしくお願いします。アニバーサリーイヤーが始まる今の気持ちを教えてください。[/b]

            "[image]":[https://assets.st-note.com/img/1698394901128-tFVwwyPjTW.jpg]

            これまでにキティと出会ってなかよくしてくれた世界中のお友だちのお顔が浮かんできて、とってもとってもうれしい気持ちです。

            [b]―これまで世界中でたくさんのことに挑戦して、キティちゃんは大活躍してますよね。どうしていつも、いろいろなことに挑戦し続けているの？[/b]

            それはね、世界中のみんなとなかよくなりたいから！
            みんなはどんなものに興味があるのかな、キティにもできるかな、一緒にやってみたいなって思いながら、たくさんのことにチャレンジしてきました。

            h2. たくさんのことに挑戦してきたハローキティ

            [b]―アメリカの大リーグで野球にも挑戦したって聞いたんだけど、本当？[/b]

            "[image]":[https://assets.st-note.com/img/1698395457170-LJgalVpfih.jpg]

            2023年8月3日にドジャーススタジオで開催された「Hello Kitty Night」

            うん、本当！ とっても楽しかったー！
            アメリカのLA（ロサンゼルス）には野球が大好きなお友だちがたくさんいて、キティもやってみたいなって思ったの。
            ゲームが始まる前には、スタジアムの外で記念撮影をしたり、ゲートの前で来てくれたお友だちにプレゼントを渡したりしたよ。

            スタジアムの始球式でマウンドに立った時は、すごくドキドキしたけど、みんなが応援してくれて、とってもうれしかったな。

            "[image]":[https://assets.st-note.com/img/1698395550982-oFNkerP4z5.jpg]

            [b]ーキティちゃんというと、コラボレーションなどで大胆に変身する姿が印象的ですが・・・[/b]

            楽しかったのは、ハチさん。
            お友だちから「キティならハチさんが似合うんじゃない？」ってオススメしてもらって、思い切ってイメチェンしてみたの。

            "[image]":[https://assets.st-note.com/img/1698395728775-CVKFAYl9wI.png]

            それとね、ハイビスカスの飾りをつけて、お姉さんっぽく“コギャルスタイル”をしてみたときは、お友だちとおそろいなのがうれしくてスキップしちゃった！

            "[image]":[https://assets.st-note.com/img/1698642540697-UYubbp0F9o.jpg]

            h2. DJやYouTuberにも挑戦！？

            [b]―音楽や映像にも、活躍の場を広げていると聞いています。[/b]

            "[image]":[https://assets.st-note.com/img/1698395781646-Z97dTKFvPB.jpg]

            そう！DJにチャレンジしたこともあるの。
            音楽が好きなみんなと楽しい時間を過ごしたいなーと思ったのがきっかけ♪
            イベントに呼んでもらったり、テレビに出たこともあるよ。
            最近はYouTuberになってみたりもしたよ！

            [b]―このたび、キティちゃんは話題のアプリ「TikTok」も始めるそうですね。[/b]

            そうなんです！
            TikTokでみんなの楽しい投稿を見ていたら、キティもやってみたいなあと思ったの。
            楽しい動画をたくさん投稿するつもりだから、ぜひフォローしてみてね。

            "[image]":[https://assets.st-note.com/img/1698394845446-Nfu0Qlok3X.jpg]

            h2. 「ARフィルター」で世界中のお友だちにHello！

            [b]―世界中の都市で、キティちゃんと一緒の写真や動画が撮れる「HELLO KITTY AR」という企画が始まると聞きました。どんなことをするのかな。[/b]

            アニバーサリーイヤーを迎えて、世界中のたくさんのお友だちに改めて「Hello！」したいなと思っているの。

            １１月１日に東京・渋谷のSHIBYA109渋谷店方面からスタートして、ロンドンのビッグベン、パリのエッフェル塔、ほかにも台湾やニューヨークなど、キティがいろんな国に遊びに行きます！

            "[image]":[https://assets.st-note.com/img/1698718972564-W0rscG1gBo.png]

            アプリをダウンロードして、ランドマークにカメラを向けると、キティが登場してダンスをするよ♪

            [b]―自分そっくりのアバターが作れるアプリ「ZEPETO（ゼペット）」にキティちゃん初のワールドができると聞きました！[/b]

            "[image]":[https://assets.st-note.com/img/1698652768645-Q3BmWTCUUd.png]

            １１月中にZEPETOでキティのワールドが新しく始まるよ。キティのアバターも登場します！
            キティのワールドには、ファッションデザイナーをめざす「ハローキティブティック」やキティと一緒に運動会ができる「アスレチックゾーン」など、楽しいアクティビティが盛りだくさんだから、ぜひ遊びにきてね♪

            h2. Robloxでは「MY HELLO KITTY CAFE」にアニバーサリーエリアも！

            [b]―そして、世界中のお友だちとゲームで交流できる「Roblox（ロブロックス）」にも、キティちゃんが登場する予定だと聞きました。[/b]

            "[image]":[https://assets.st-note.com/img/1698396135123-BH4g8iFcxA.png]

            そうなの、「MY HELLO KITTY CAFE」では、キティのアニバーサリーにちなんだ、アップデート企画がスタートします！
            キティのリボンとハイビスカスをつけた、女子高生風のお洋服を楽しむこともできるの♪
            キティデザインのフレームで写真を撮れるフォトブースも新しくできるから、ぜひキティとの写真を撮りにきてね。

            12月にはゲーム「ミステリーミュージアム」が登場する予定なの！
            キティのミュージアムの中でドキドキの鬼ごっこができるよ！ 楽しみにしていてね♪

            [b]ーいろんな新しいことに挑戦するんだね！最後に、このnoteを読んでくれた方へ、メッセージをお願いします。[/b]

            "[image]":[https://assets.st-note.com/img/1698394966797-MlP1TpeZhl.jpg]

            キティのインタビューを最後まで読んでくれてありがとう♡
            いよいよアニバーサリーイヤー が始まって、みんなと過ごす特別な１年になると思うと、今からとってもワクワクしています♪

            いつもキティのことを応援してくれて、なかよくしてくれるあなたとも、これから新しく出会えるみんなとも、もっともーっとなかよくなれる、そんな1年にできたら、キティもとってもうれしいです ！

            これからはじまるアニバーサリーイヤー、楽しみにしていてね♪

            h3. おわりに

            この半世紀、「ハローキティ」は世界中に「かわいい」と「なかよく」を届けてくれました。ふと気づくと、何気ない幸せを感じる日常のなかに寄り添ってくれる“キティ”。
            アニバーサリーイヤーは、“キティ”がこれから目指していく世界をさまざまな形で発信していくというから、とってもワクワクする一年になりそうですね。

            [b]ハローキティ[/b] [b]＊プロフィール＊[/b]

            "[image]":[https://assets.st-note.com/img/1698395019868-totpG7DPq2.jpg]

            50周年アニバーサリー衣装を着たハローキティ

            お誕生日：11月1日
            出身地：ロンドン郊外
            身長：りんご5個分
            体重：りんご3個分
            血液型：A型
            趣味：クッキーを作ったり、ピアノをひくこと
            好きな食べ物：ママが作ったアップルパイ

            ■"ハローキティ公式50周年アカウント":[https://www.tiktok.com/@hellokitty_50th]
            @hellokitty_50th

            ■"ハローキティ動画アカウント This is hello kitty.":[https://www.tiktok.com/@this_is_hellokitty_]
            @this_is_hellokitty_

            ■"グローバルハローキティ公式アカウント":[https://www.tiktok.com/@hellokitty]
            @hellokitty

            （おわり）

            ©︎2023 SANRIO CO.,LTD. 著作：（株）サンリオ
          EOS
        )
      end

      context "A deleted or nonexistent Note post" do
        strategy_should_work(
          "https://note.com/koma_labo/n/n999999999999",
          image_urls: [],
          page_url: "https://note.com/koma_labo/n/n999999999999",
          profile_url: "https://note.com/koma_labo",
          profile_urls: %w[https://note.com/koma_labo],
          display_name: nil,
          username: "koma_labo",
          tag_name: "koma_labo",
          other_names: ["koma_labo"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse URLs correctly" do
        assert(Source::URL.image_url?("https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png?width=2000&height=2000&fit=bounds&format=jpg&quality=85"))
        assert(Source::URL.image_url?("https://assets.st-note.com/production/uploads/images/14533920/profile_812af2baf1a6eb05c62182d43b0cbdbe.png?width=60"))

        assert(Source::URL.page_url?("https://note.com/koma_labo/n/n32fb90fac512"))
        assert(Source::URL.page_url?("https://note.mu/koma_labo/n/n32fb90fac512"))

        assert(Source::URL.profile_url?("https://note.com/koma_labo"))
        assert(Source::URL.profile_url?("https://note.mu/koma_labo"))

        assert_equal("https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png", Source::URL.parse("https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png?width=2000&height=2000&fit=bounds&format=jpg&quality=85").full_image_url)
        assert_equal("https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png", Source::URL.parse("https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png").full_image_url)
        assert_equal("https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png", Source::URL.parse("https://note-cakes-web-dev.s3.amazonaws.com/img/1623726537463-B8LOZ1JZUS.png").full_image_url)
        assert_equal("https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg", Source::URL.parse("https://assets.st-note.com/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg").full_image_url)
        assert_equal("https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg", Source::URL.parse("https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg").full_image_url)
        assert_equal("https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg", Source::URL.parse("https://note-cakes-web-dev.s3.amazonaws.com/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg").full_image_url)
      end
    end
  end
end
