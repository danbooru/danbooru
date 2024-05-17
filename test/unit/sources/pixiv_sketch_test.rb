require 'test_helper'

module Sources
  class PixivSketchTest < ActiveSupport::TestCase
    context "A Pixiv Sketch post" do
      strategy_should_work(
        "https://sketch.pixiv.net/items/1086346113447960710",
        image_urls: ["https://img-sketch.pixiv.net/uploads/medium/file/10300644/640285025392668842.jpg"],
        page_url: "https://sketch.pixiv.net/items/1086346113447960710",
        profile_urls: ["https://sketch.pixiv.net/@rinnoji522", "https://www.pixiv.net/users/2556276"],
        profile_url: "https://sketch.pixiv.net/@rinnoji522",
        display_name: "りんのじ",
        username: "rinnoji522",
        tags: %w[アプリコット いよわ いよわガールズ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#アプリコット":[https://sketch.pixiv.net/tags/アプリコット] "#いよわ":[https://sketch.pixiv.net/tags/いよわ] "#いよわガールズ":[https://sketch.pixiv.net/tags/いよわガールズ]
        EOS
      )
    end

    context "A Pixiv Sketch image with referer" do
      strategy_should_work(
        "https://img-sketch.pixiv.net/uploads/medium/file/10300644/640285025392668842.jpg",
        referer: "https://sketch.pixiv.net/items/1086346113447960710",
        image_urls: ["https://img-sketch.pixiv.net/uploads/medium/file/10300644/640285025392668842.jpg"],
        page_url: "https://sketch.pixiv.net/items/1086346113447960710",
        profile_urls: ["https://sketch.pixiv.net/@rinnoji522", "https://www.pixiv.net/users/2556276"],
        profile_url: "https://sketch.pixiv.net/@rinnoji522",
        display_name: "りんのじ",
        username: "rinnoji522",
        tags: %w[アプリコット いよわ いよわガールズ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#アプリコット":[https://sketch.pixiv.net/tags/アプリコット] "#いよわ":[https://sketch.pixiv.net/tags/いよわ] "#いよわガールズ":[https://sketch.pixiv.net/tags/いよわガールズ]
        EOS
      )
    end

    context "A Pixiv Sketch image without the referer" do
      # page: https://sketch.pixiv.net/items/8052785510155853613
      strategy_should_work(
        "https://img-sketch.pixiv.net/uploads/medium/file/9988973/7216948861306830496.jpg",
        page_url: nil,
        profile_url: nil,
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_desc: ""
      )
    end

    context "A NSFW post" do
      strategy_should_work(
        "https://sketch.pixiv.net/items/193462611994864256",
        image_urls: ["https://img-sketch.pixiv.net/uploads/medium/file/884876/4909517173982299587.jpg"],
        page_url: "https://sketch.pixiv.net/items/193462611994864256",
        profile_url: "https://sketch.pixiv.net/@lithla",
        display_name: "リリスラウダ",
        username: "lithla",
        dtext_artist_commentary_desc: "チビッコ露出プレイ ピース",
        tags: []
      )
    end

    context "A post with multiple images" do
      strategy_should_work(
        "https://sketch.pixiv.net/items/8052785510155853613",
        image_urls: %w[
          https://img-sketch.pixiv.net/uploads/medium/file/9988964/1564052114639195387.png
          https://img-sketch.pixiv.net/uploads/medium/file/9988965/3187185972065199018.png
          https://img-sketch.pixiv.net/uploads/medium/file/9988966/5281789458380074490.png
          https://img-sketch.pixiv.net/uploads/medium/file/9988967/8187710652175488805.png
          https://img-sketch.pixiv.net/uploads/medium/file/9988968/3497441770651131427.png
          https://img-sketch.pixiv.net/uploads/medium/file/9988969/1770110164450415039.png
          https://img-sketch.pixiv.net/uploads/medium/file/9988970/1340350233137289970.png
          https://img-sketch.pixiv.net/uploads/medium/file/9988971/9105451079763734305.jpg
          https://img-sketch.pixiv.net/uploads/medium/file/9988972/2641925439408057307.jpg
          https://img-sketch.pixiv.net/uploads/medium/file/9988973/7216948861306830496.jpg
        ],
        display_name: "俺P１号",
        username: "op-one",
        page_url: "https://sketch.pixiv.net/items/8052785510155853613",
        profile_url: "https://sketch.pixiv.net/@op-one",
        tags: %w[制作過程 このすば この素晴らしい世界に祝福を セナ バニー 3月3日 巨乳 黒髪巨乳 タイツ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          3月3日は「うさぎの日」らしいので

          ▼制作過程
          ◎制作過程
          ①ﾗﾌｺﾝﾃ(ｱﾀﾘ)
          ②ﾗﾌｺﾝﾃ(ﾗﾌﾒﾓ)
          ③ｺﾝﾃ(ﾍﾞｸﾄﾙﾗﾌ)+色ｱﾀﾘ
          ④1原(ﾗﾌ原)
          ⑤1原(ﾗﾌ原)(線のみ)
          ⑥色ﾗﾌ
          ⑦仕上げ⇒完成
          ⑨完成(ｾﾋﾟｱﾓﾉﾄｰﾝ)
          ⑧完成(ｸﾞﾚｰﾓﾉｸﾛ)

          色までつける時間と心の余裕が無いのでモノクロでらくがき
          それでも5時間ぐらいかかってる(③～④の間で30分ぐらい雑務)

          やっぱﾗﾌから１原は時間かかる…
          ・線画だけから立体が把握できない(頭の中で3D化できない)
          ・描き続けてると立体感がゲシュタルト崩壊する
          ・目のピントが合わない
          ので1～2回休憩して目と頭休ませないといけないのがきつい
          目と頭のスタミナ不足は如何ともしがたい

          線画のみから感覚的に立体把握できる「確かめ算」みたいな手法を練りこむ必要がある…のはわかってるけど
          「断面図」
          「透明な板を設定して奥行きパース確認」
          「地面に正方形を描いて縦パース確認」
          「関節部や胴体中央部に核(丸)を描いて立体確認」
          「線画」を淡く表示し上から簡単な立体モデルを描いてみて「大きさ比率の確認」
          …ぐらいかな思いつくのは

          あと初期に足首の関節素体描いて立体把握してる跡がある
          いまだに関節の軸を足首のドコに設定すれば自然に見えるか迷う
          多分最大に伸ばしたり曲げたりしてるときは関節浮いてたりするんだろうから簡単な軸設定だと違和感が出てくるんだとは思う

          "#制作過程":[https://sketch.pixiv.net/tags/制作過程]
          "#このすば":[https://sketch.pixiv.net/tags/このすば]
          "#この素晴らしい世界に祝福を":[https://sketch.pixiv.net/tags/この素晴らしい世界に祝福を]！
          "#セナ":[https://sketch.pixiv.net/tags/セナ]
          "#バニー":[https://sketch.pixiv.net/tags/バニー]
          "#3月3日":[https://sketch.pixiv.net/tags/3月3日]
          "#巨乳":[https://sketch.pixiv.net/tags/巨乳]
          "#黒髪巨乳":[https://sketch.pixiv.net/tags/黒髪巨乳]
          "#タイツ":[https://sketch.pixiv.net/tags/タイツ]
        EOS
      )
    end

    context "A commentary with ideographic spaces and full-width hashtags" do
      strategy_should_work(
        "https://sketch.pixiv.net/items/855105296504450744",
        artist_commentary_desc: <<~EOS.chomp,
          \x20\x20配信で描いたやつ　        ＃カルナ　＃FGO\x20
        EOS
        dtext_artist_commentary_desc: <<~EOS.chomp
          配信で描いたやつ "＃カルナ":[https://sketch.pixiv.net/tags/カルナ] "＃FGO":[https://sketch.pixiv.net/tags/FGO]
        EOS
      )
    end

    should "Parse Pixiv Sketch URLs correctly" do
      assert(Source::URL.image_url?("https://img-sketch.pixiv.net/uploads/medium/file/4463372/8906921629213362989.jpg "))
      assert(Source::URL.image_url?("https://img-sketch.pximg.net/c!/w=540,f=webp:jpeg/uploads/medium/file/4463372/8906921629213362989.jpg"))
      assert(Source::URL.image_url?("https://img-sketch.pixiv.net/c/f_540/uploads/medium/file/9986983/8431631593768139653.jpg"))
      assert(Source::URL.page_url?("https://sketch.pixiv.net/items/5835314698645024323"))
      assert(Source::URL.profile_url?("https://sketch.pixiv.net/@user_ejkv8372"))
    end
  end
end
