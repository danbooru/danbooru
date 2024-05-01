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
          artist_name: nil,
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
          artist_name: nil,
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
          artist_name: "Koma-Labo",
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
          artist_name: "ポイズン",
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
          artist_name: "キャビコ",
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

      context "A deleted or nonexistent Note post" do
        strategy_should_work(
          "https://note.com/koma_labo/n/n999999999999",
          image_urls: [],
          page_url: "https://note.com/koma_labo/n/n999999999999",
          profile_url: "https://note.com/koma_labo",
          profile_urls: %w[https://note.com/koma_labo],
          artist_name: nil,
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
