require 'test_helper'

module Sources
  class PixivSketchTest < ActiveSupport::TestCase
    context "A Pixiv Sketch source" do
      should "work for a post with a single image" do
        source = Sources::Strategies.find("https://sketch.pixiv.net/items/5835314698645024323")

        assert_equal("Pixiv Sketch", source.site_name)
        assert_equal(["https://img-sketch.pixiv.net/uploads/medium/file/9986983/8431631593768139653.jpg"], source.image_urls)
        assert_equal("https://sketch.pixiv.net/items/5835314698645024323", source.page_url)
        assert_equal("https://sketch.pixiv.net/@user_ejkv8372", source.profile_url)
        assert_equal(["https://sketch.pixiv.net/@user_ejkv8372", "https://www.pixiv.net/users/44772126"], source.profile_urls)
        assert_equal("user_ejkv8372", source.artist_name)
        assert_equal(["user_ejkv8372", "サコ"], source.other_names)
        assert_equal("🍻シャンクスとミホーク誕生日おめでとう🍻（過去絵） ", source.artist_commentary_desc)
        assert_equal([], source.tags.map(&:first))
        assert_nothing_raised { source.to_h }
      end

      should "work for an image url without a referer" do
        # page: https://sketch.pixiv.net/items/8052785510155853613
        source = Sources::Strategies.find("https://img-sketch.pixiv.net/uploads/medium/file/9988973/7216948861306830496.jpg")

        assert_equal(["https://img-sketch.pixiv.net/uploads/medium/file/9988973/7216948861306830496.jpg"], source.image_urls)
        assert_nil(source.page_url)
        assert_nil(source.profile_url)
        assert_equal([], source.profile_urls)
        assert_nil(source.artist_name)
        assert_equal([], source.other_names)
        assert_nil(source.artist_commentary_desc)
        assert_equal([], source.tags.map(&:first))
        assert_nothing_raised { source.to_h }
      end

      should "work for an image url with a referer" do
        source = Sources::Strategies.find("https://img-sketch.pixiv.net/uploads/medium/file/9988973/7216948861306830496.jpg", "https://sketch.pixiv.net/items/8052785510155853613")

        assert_equal("https://sketch.pixiv.net/items/8052785510155853613", source.page_url)
        assert_equal("https://sketch.pixiv.net/@op-one", source.profile_url)
        assert_equal(["https://sketch.pixiv.net/@op-one", "https://www.pixiv.net/users/5903369"], source.profile_urls)
        assert_equal("op-one", source.artist_name)
        assert_equal(["op-one", "俺P１号"], source.other_names)
        assert_match(/\A3月3日は「うさぎの日」らしいので/, source.artist_commentary_desc)
        assert_equal(%w[制作過程 このすば この素晴らしい世界に祝福を セナ バニー 3月3日 巨乳 黒髪巨乳 タイツ], source.tags.map(&:first))
        assert_nothing_raised { source.to_h }
      end

      should "work for a NSFW post" do
        source = Sources::Strategies.find("https://sketch.pixiv.net/items/193462611994864256")

        assert_equal(["https://img-sketch.pixiv.net/uploads/medium/file/884876/4909517173982299587.jpg"], source.image_urls)
        assert_equal("https://sketch.pixiv.net/items/193462611994864256", source.page_url)
        assert_equal("https://sketch.pixiv.net/@lithla", source.profile_url)
        assert_equal(["https://sketch.pixiv.net/@lithla", "https://www.pixiv.net/users/4957"], source.profile_urls)
        assert_equal("lithla", source.artist_name)
        assert_equal(["lithla", "リリスラウダ"], source.other_names)
        assert_equal("チビッコ露出プレイ ピース", source.artist_commentary_desc)
        assert_equal([], source.tags.map(&:first))
        assert_nothing_raised { source.to_h }
      end

      should "work for a post with a multiple images" do
        source = Sources::Strategies.find("https://sketch.pixiv.net/items/8052785510155853613")

        assert_equal(%w[
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
        ], source.image_urls)
        assert_equal("https://sketch.pixiv.net/items/8052785510155853613", source.page_url)
        assert_equal("https://sketch.pixiv.net/@op-one", source.profile_url)
        assert_equal("op-one", source.artist_name)
        assert_equal(<<~EOS.normalize_whitespace, source.artist_commentary_desc)
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

          #制作過程
          #このすば
          #この素晴らしい世界に祝福を！
          #セナ
          #バニー
          #3月3日
          #巨乳
          #黒髪巨乳
          #タイツ
        EOS

        assert_equal(%w[制作過程 このすば この素晴らしい世界に祝福を セナ バニー 3月3日 巨乳 黒髪巨乳 タイツ], source.tags.map(&:first))
        assert_nothing_raised { source.to_h }
      end
    end
  end
end
