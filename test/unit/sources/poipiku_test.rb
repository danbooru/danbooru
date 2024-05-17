require 'test_helper'

module Sources
  class PoipikuTest < ActiveSupport::TestCase
    context "Poipiku:" do
      context "A https://poipiku.com/:user_id/:post_id.html page url with a single image" do
        strategy_should_work(
          "https://poipiku.com/583/2867587.html",
          page_url: "https://poipiku.com/583/2867587.html",
          image_urls: %w[
            https://img-org.poipiku.com/user_img03/000000583/002867587_M1EY9rofF.jpeg
          ],
          media_files: [{ file_size: 209_902 }],
          profile_url: "https://poipiku.com/583/",
          profile_urls: %w[https://poipiku.com/583/ https://twitter.com/avocado_0w0],
          display_name: "リアクションありがとう～～",
          tag_name: "poipiku_583",
          tags: [],
          dtext_artist_commentary_desc: <<~EOS.chomp
            雨の日てる
          EOS
        )
      end

      context "A https://poipiku.com/:user_id/:post_id.html page url with multiple images" do
        strategy_should_work(
          "https://poipiku.com/6849873/8271386.html",
          page_url: "https://poipiku.com/6849873/8271386.html",
          image_urls: %w[
            https://img-org.poipiku.com/user_img03/006849873/008271096_016820933_INusR6FhI.jpeg
            https://img-org.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg
            https://img-org.poipiku.com/user_img03/006849873/008271386_016865826_GBFF3dyRt.jpeg
          ],
          profile_url: "https://poipiku.com/6849873/",
          profile_urls: %w[https://poipiku.com/6849873/],
          display_name: "omo_chi2",
          tag_name: "omo_chi2",
          tags: [],
          artist_commentary_desc: <<~EOS.chomp,
            オモチ。トップの邪魔するcrちゃん<br>キスしてるだけ
          EOS
          dtext_artist_commentary_desc: <<~EOS.chomp
            オモチ。トップの邪魔するcrちゃん
            キスしてるだけ
          EOS
        )
      end

      context "A https://img.poipiku.com/:dir/:user_id/:post_id_:image_id_:hash.jpeg full image URL" do
        strategy_should_work(
          "https://img-org.poipiku.com/user_img03/006849873/008271096_016820933_INusR6FhI.jpeg",
          # XXX redirects to the correct URL of https://poipiku.com/6849873/8271386.html
          page_url: "https://poipiku.com/6849873/8271096.html",
          image_urls: %w[
            https://img-org.poipiku.com/user_img03/006849873/008271096_016820933_INusR6FhI.jpeg
          ],
          media_files: [{ file_size: 343_562 }],
          profile_url: "https://poipiku.com/6849873/",
          profile_urls: %w[https://poipiku.com/6849873/],
          display_name: "omo_chi2",
          tag_name: "omo_chi2",
          tags: [],
          artist_commentary_desc: <<~EOS.chomp,
            オモチ。トップの邪魔するcrちゃん<br>キスしてるだけ
          EOS
          dtext_artist_commentary_desc: <<~EOS.chomp
            オモチ。トップの邪魔するcrちゃん
            キスしてるだけ
          EOS
        )
      end

      context "A https://img.poipiku.com/:dir/:user_id/:post_id_:image_id_:hash.jpeg_640.jpg sample image URL" do
        strategy_should_work(
          "https://img.poipiku.com/user_img03/006849873/008271096_016820933_INusR6FhI.jpeg_640.jpg",
          # XXX redirects to the correct URL of https://poipiku.com/6849873/8271386.html
          page_url: "https://poipiku.com/6849873/8271096.html",
          image_urls: %w[
            https://img-org.poipiku.com/user_img03/006849873/008271096_016820933_INusR6FhI.jpeg
          ],
          media_files: [{ file_size: 343_562 }],
          profile_url: "https://poipiku.com/6849873/",
          profile_urls: %w[https://poipiku.com/6849873/],
          display_name: "omo_chi2",
          tag_name: "omo_chi2",
          tags: [],
          artist_commentary_desc: <<~EOS.chomp,
            オモチ。トップの邪魔するcrちゃん<br>キスしてるだけ
          EOS
          dtext_artist_commentary_desc: <<~EOS.chomp
            オモチ。トップの邪魔するcrちゃん
            キスしてるだけ
          EOS
        )
      end

      context "A page that requires a login" do
        strategy_should_work(
          "https://poipiku.com/8566613/9625938.html",
          page_url: "https://poipiku.com/8566613/9625938.html",
          image_urls: %w[
            https://img-org.poipiku.com/user_img03/008566613/009625669_020612310_toCYdeSNu.jpeg
            https://img-org.poipiku.com/user_img02/008566613/009625669_020612311_woW7C76Mm.jpeg
            https://img-org.poipiku.com/user_img02/008566613/009625669_020612314_f7gKnobZf.jpeg
            https://img-org.poipiku.com/user_img03/008566613/009625669_020612315_PruYge0kI.jpeg
            https://img-org.poipiku.com/user_img03/008566613/009625669_020612316_BzYCPGlTs.jpeg
            https://img-org.poipiku.com/user_img02/008566613/009625669_020612317_MLJKcyPlU.jpeg
            https://img-org.poipiku.com/user_img03/008566613/009625938_020619084_HBrdSJ8V3.jpeg
          ],
          profile_url: "https://poipiku.com/8566613/",
          profile_urls: %w[https://poipiku.com/8566613/],
          display_name: "kino",
          tag_name: "kino",
          tags: [],
          dtext_artist_commentary_desc: <<~EOS.chomp
            丹穹 R-18 (※攻めローションガーゼ)
            普段水を操っている丹が自分から出る水分を制御できないのえっちだよね！のらくがきです

            ⚠︎なんでも大丈夫な方向け
            少しでも不安を覚えた方はブラウザバック推奨です
          EOS
        )
      end

      # Ignores the warning image
      context "A page url with a warning image" do
        strategy_should_work(
          "https://poipiku.com/6849873/8143439.html",
          page_url: "https://poipiku.com/6849873/8143439.html",
          image_urls: %w[
            https://img-org.poipiku.com/user_img03/006849873/008143439_016477493_W51KQXsLM.jpeg
          ],
          profile_url: "https://poipiku.com/6849873/",
          profile_urls: %w[https://poipiku.com/6849873/],
          display_name: "omo_chi2",
          tag_name: "omo_chi2",
          tags: [],
          dtext_artist_commentary_desc: <<~EOS.chomp
            オモチの体型こうだったらいいな絵
            ⚠︎全裸
          EOS
        )
      end

      # Ignores the R-18 warning image
      context "A page url with a R-18 warning image" do
        strategy_should_work(
          "https://poipiku.com/927572/6228370.html",
          page_url: "https://poipiku.com/927572/6228370.html",
          image_urls: %w[
            https://img-org.poipiku.com/user_img02/000927572/006228370_gIBoTWg2u.jpeg
            https://img-org.poipiku.com/user_img02/000927572/006228370_011556210_GU43fGlEx.jpeg
          ],
          profile_url: "https://poipiku.com/927572/",
          profile_urls: %w[https://poipiku.com/927572/],
          display_name: "KAIFEI",
          tag_name: "kaifei",
          tags: [],
          dtext_artist_commentary_desc: "博士出浴(裸體"
        )
      end

      # Doesn't get the images
      context "A password-protected page url" do
        strategy_should_work(
          "https://poipiku.com/6849873/8141991.html",
          page_url: "https://poipiku.com/6849873/8141991.html",
          image_urls: [],
          profile_url: "https://poipiku.com/6849873/",
          display_name: "omo_chi2",
          tag_name: "omo_chi2",
          tags: [],
          dtext_artist_commentary_desc: <<~EOS.chomp
            モブチ(モブ女、モブ男×cr)
            ⚠︎モブ姦、無理矢理

            ファンのモブ女にクスリ盛られてモブ男と性行為させられるcrちゃんです

            18↑？(y/n)
          EOS
        )
      end

      # Only gets the blurred first image
      context "A page url that is followers only" do
        strategy_should_work(
          "https://poipiku.com/16109/8284794.html",
          image_urls: [],
          page_url: "https://poipiku.com/16109/8284794.html",
          profile_url: "https://poipiku.com/16109/",
          profile_urls: %w[https://poipiku.com/16109/ https://www.pixiv.net/users/46937590],
          display_name: "緊縛師ボンレス（ル×ガの民）",
          tag_name: "poipiku_16109",
          other_names: ["緊縛師ボンレス（ル×ガの民）"],
          tags: [
            ["腐向け", "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=腐向け"],
            ["TOBL", "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=TOBL"],
            ["ルクガイ", "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=ルクガイ"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            乳揉まれて気持ち良くなってそうなところ描きたいなと思って描きました。先日描いたやつはまだ「お坊ちゃん可愛い」が勝っている状態。これは「もうそろそろイくかな？」と思われてそうな状態。乳に垂れてる汁は何ですかね。汗？オイル？唾液？うちのルク坊やは唾液でお口ニュルニュルするの気持ちいいボーイなので、きっとお口で遊んだ後（いま決めた）。
          EOS
        )
      end

      # Doesn't get the images
      context "A page url that is Twitter followers only" do
        strategy_should_work(
          "https://poipiku.com/2210523/4916104.html",
          page_url: "https://poipiku.com/2210523/4916104.html",
          image_urls: %w[],
          profile_url: "https://poipiku.com/2210523/",
          display_name: "るーとzakkubarannnn",
          tag_name: "zakkubarannnn",
          tags: [],
          dtext_artist_commentary_desc: <<~EOS.chomp
            今日はここまでにしとく
            なんか塗れば塗るほどエロいのかわかんなくなってきたし、そもそもなんでディルックさんがこんなガンガンに種付してくれるのかの理由も別途アウトプットしたくなってきてる(私の中で色々設定がある模様)しで、も〜〜1日の時間と私の集中力がたりませえん！！
          EOS
        )
      end

      context "A page url without images" do
        strategy_should_work(
          "https://poipiku.com/302292/6598662.html",
          page_url: "https://poipiku.com/302292/6598662.html",
          image_urls: [],
          profile_url: "https://poipiku.com/302292/",
          display_name: "(　˙👅˙　)",
          tag_name: "poipiku_302292",
          tags: [
            ["突発", "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=突発"],
          ],
          dtext_artist_commentary_desc: <<~EOS.chomp
            運転中うっかり助手席の人の大事な所に触れちゃってあわあわするディミレスが見たかったのにどうしてこうなった(*´･д･)??

            なおべレスの半身は
            （廿_廿)＜万が一のときに慰められるように女教師ものの動画は用意しておいた。うまくいったみたいだからお祝いにあげようと思う。
            などと供述している模様。
          EOS
        )
      end

      context "A deleted page url" do
        strategy_should_work(
          "https://poipiku.com/1727580/6661073.html",
          page_url: "https://poipiku.com/1727580/6661073.html",
          image_urls: [],
          profile_url: "https://poipiku.com/1727580/",
          display_name: nil,
          tag_name: "poipiku_1727580",
          tags: [],
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse Poipiku URLs correctly" do
        assert(Source::URL.image_url?("https://img.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg_640.jpg"))
        assert(Source::URL.image_url?("https://img.poipiku.com/user_img03/000020566/007185704_nb1cTuA1I.jpeg_640.jpg "))
        assert(Source::URL.image_url?("https://img.poipiku.com/user_img02/000003310/000007036.jpeg_640.jpg "))
        assert(Source::URL.image_url?("https://img-org.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg"))
        assert(Source::URL.image_url?("https://img-org.poipiku.com/user_img03/000020566/007185704_nb1cTuA1I.jpeg "))
        assert(Source::URL.image_url?("https://img-org.poipiku.com/user_img02/000003310/000007036.jpeg "))

        assert(Source::URL.page_url?("https://poipiku.com/6849873/8271386.html"))

        assert(Source::URL.profile_url?("https://poipiku.com/IllustListPcV.jsp?ID=9056"))
        assert(Source::URL.profile_url?("https://poipiku.com/IllustListGridPcV.jsp?ID=9056"))
        assert(Source::URL.profile_url?("https://poipiku.com/6849873"))
      end
    end
  end
end
