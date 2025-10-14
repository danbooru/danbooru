require "test_helper"

module Source::Tests::Extractor
  class PoipikuExtractorTest < ActiveSupport::TestCase
    context "A https://poipiku.com/:user_id/:post_id.html page url with a single image" do
      strategy_should_work(
        "https://poipiku.com/583/2867587.html",
        page_url: "https://poipiku.com/583/2867587.html",
        image_urls: [
          %r{https://cdn.poipiku.com/000000583/002867587_M1EY9rofF.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        media_files: [{ file_size: 209_902 }],
        profile_url: "https://poipiku.com/583/",
        profile_urls: %w[https://poipiku.com/583/ https://twitter.com/avocado_0w0],
        display_name: "リアクションありがとう～～",
        tag_name: "poipiku_583",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          雨の日てる
        EOS
      )
    end

    context "A https://poipiku.com/:user_id/:post_id.html page url with multiple images" do
      strategy_should_work(
        "https://poipiku.com/6849873/8271386.html",
        page_url: "https://poipiku.com/6849873/8271386.html",
        image_urls: [
          %r{https://cdn.poipiku.com/006849873/008271096_016820933_INusR6FhI.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/006849873/008271386_016865825_S968sAh7Y.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/006849873/008271386_016865826_GBFF3dyRt.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        profile_url: "https://poipiku.com/6849873/",
        profile_urls: %w[https://poipiku.com/6849873/],
        display_name: "omo_chi2",
        tag_name: "omo_chi2",
        tags: [],
        artist_commentary_desc: <<~EOS.chomp,
          オモチ。トップの邪魔するcrちゃん<br>キスしてるだけ
        EOS
        dtext_artist_commentary_desc: <<~EOS.chomp,
          オモチ。トップの邪魔するcrちゃん
          キスしてるだけ
        EOS
      )
    end

    # Expands to the full post URL
    context "A https://img.poipiku.com/:dir/:user_id/:post_id_:image_id_:hash.jpeg full image URL" do
      strategy_should_work(
        "https://img-org.poipiku.com/user_img03/006849873/008271096_016820933_INusR6FhI.jpeg",
        page_url: "https://poipiku.com/6849873/8271386.html",
        image_urls: [
          %r{https://cdn.poipiku.com/006849873/008271096_016820933_INusR6FhI.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/006849873/008271386_016865825_S968sAh7Y.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/006849873/008271386_016865826_GBFF3dyRt.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        media_files: [
          { file_size: 343_562 },
          { file_size: 805_259 },
          { file_size: 703_879 }
        ],
        profile_url: "https://poipiku.com/6849873/",
        profile_urls: %w[https://poipiku.com/6849873/],
        display_name: "omo_chi2",
        tag_name: "omo_chi2",
        tags: [],
        artist_commentary_desc: <<~EOS.chomp,
          オモチ。トップの邪魔するcrちゃん<br>キスしてるだけ
        EOS
        dtext_artist_commentary_desc: <<~EOS.chomp,
          オモチ。トップの邪魔するcrちゃん
          キスしてるだけ
        EOS
      )
    end

    context "A https://img.poipiku.com/:dir/:user_id/:post_id_:image_id_:hash.jpeg_640.jpg sample image URL" do
      strategy_should_work(
        "https://img.poipiku.com/user_img03/006849873/008271096_016820933_INusR6FhI.jpeg_640.jpg",
        page_url: "https://poipiku.com/6849873/8271386.html",
        image_urls: [
          %r{https://cdn.poipiku.com/006849873/008271096_016820933_INusR6FhI.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/006849873/008271386_016865825_S968sAh7Y.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/006849873/008271386_016865826_GBFF3dyRt.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        media_files: [
          { file_size: 343_562 },
          { file_size: 805_259 },
          { file_size: 703_879 }
        ],
        profile_url: "https://poipiku.com/6849873/",
        profile_urls: %w[https://poipiku.com/6849873/],
        display_name: "omo_chi2",
        tag_name: "omo_chi2",
        tags: [],
        artist_commentary_desc: <<~EOS.chomp,
          オモチ。トップの邪魔するcrちゃん<br>キスしてるだけ
        EOS
        dtext_artist_commentary_desc: <<~EOS.chomp,
          オモチ。トップの邪魔するcrちゃん
          キスしてるだけ
        EOS
      )
    end

    context "A page that requires a login" do
      strategy_should_work(
        "https://poipiku.com/8566613/9625938.html",
        page_url: "https://poipiku.com/8566613/11413167.html",
        image_urls: [
          %r{https://cdn.poipiku.com/008566613/009625669_020612310_toCYdeSNu.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/008566613/009625669_020612311_woW7C76Mm.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/008566613/009625669_020612314_f7gKnobZf.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/008566613/009625669_020612315_PruYge0kI.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/008566613/009625669_020612316_BzYCPGlTs.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/008566613/009625669_020612317_MLJKcyPlU.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/008566613/009625938_020619084_HBrdSJ8V3.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        profile_url: "https://poipiku.com/8566613/",
        profile_urls: %w[https://poipiku.com/8566613/],
        display_name: "kino",
        tag_name: "kino",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        image_urls: [
          %r{https://cdn.poipiku.com/006849873/008143439_016477493_W51KQXsLM.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        profile_url: "https://poipiku.com/6849873/",
        profile_urls: %w[https://poipiku.com/6849873/],
        display_name: "omo_chi2",
        tag_name: "omo_chi2",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        image_urls: [
          %r{https://cdn.poipiku.com/000927572/006228370_gIBoTWg2u.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/000927572/006228370_011556210_GU43fGlEx.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        profile_url: "https://poipiku.com/927572/",
        profile_urls: %w[https://poipiku.com/927572/],
        display_name: "KAIFEI",
        tag_name: "kaifei",
        tags: [],
        dtext_artist_commentary_desc: "博士出浴(裸體",
      )
    end

    context "A simple password-protected page url" do
      strategy_should_work(
        "https://poipiku.com/6849873/8141991.html",
        page_url: "https://poipiku.com/6849873/8141991.html",
        image_urls: [%r{https://cdn.poipiku.com/006849873/008140534_016466597_y4Z3HEJH1.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},],
        profile_url: "https://poipiku.com/6849873/",
        display_name: "omo_chi2",
        tag_name: "omo_chi2",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          モブチ(モブ女、モブ男×cr)
          ⚠︎モブ姦、無理矢理

          ファンのモブ女にクスリ盛られてモブ男と性行為させられるcrちゃんです

          18↑？(y/n)
        EOS
      )
    end

    context "Another password-protected page url" do 
      strategy_should_work(
        "https://poipiku.com/11804030/12317737.html",
        image_urls: [
          %r{https://cdn.poipiku.com/011804030/012317737_4a3RvCcyZ.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/011804030/012317737_027849420_6G6hq62J3.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/011804030/012317737_027849421_DexCiPGDj.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/011804030/012317737_027849422_n9dnvyfsF.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        media_files: [
          { file_size: 847_898 },
          { file_size: 1_102_184 },
          { file_size: 908_031 },
          { file_size: 954_805 }
        ],
        page_url: "https://poipiku.com/11804030/12317737.html",
        profile_urls: %w[https://poipiku.com/11804030/],
        display_name: "ナナミ",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          umtkのR18練習まとめ
          password🔑→18歳以上ですか？(yes/no)
        EOS
      )
    end

    context "An unknown password-protected page url" do
      strategy_should_work(
        "https://poipiku.com/8696274/11543760.html",
        image_urls: [],
        page_url: "https://poipiku.com/8696274/11543760.html",
        profile_urls: %w[https://poipiku.com/8696274/],
        display_name: "nono",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          富入さんとかあの人たち
          パスはクリア後なら名前が分かるあの人
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
        profile_urls: %w[https://marshmallow-qa.com/_otsubo_ https://odaibako.net/u/kmbkshbnlss https://poipiku.com/16109/ https://www.pixiv.net/users/46937590],
        display_name: "緊縛師ボンレス（ル×ガの民）",
        tag_name: "poipiku_16109",
        other_names: ["緊縛師ボンレス（ル×ガの民）"],
        tags: [
          ["腐向け", "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=腐向け"],
          ["TOBL", "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=TOBL"],
          ["ルクガイ", "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD=ルクガイ"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
          今日はここまでにしとく
          なんか塗れば塗るほどエロいのかわかんなくなってきたし、そもそもなんでディルックさんがこんなガンガンに種付してくれるのかの理由も別途アウトプットしたくなってきてる(私の中で色々設定がある模様)しで、も〜〜1日の時間と私の集中力がたりませえん！！
        EOS
      )
    end

    # No images
    context "A page url that is list-only" do
      strategy_should_work(
        "https://poipiku.com/2418562/5254068.html",
        image_urls: [],
        page_url: "https://poipiku.com/2418562/5254068.html",
        profile_urls: %w[https://poipiku.com/2418562/],
        display_name: "sauuomateng",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "🇮🇩 x 🇳🇱"
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        dtext_artist_commentary_desc: "",
      )
    end

    context "A signed full image URL" do
      strategy_should_work(
        "https://cdn.poipiku.com/009416896/010718302_023702506_X5LNftu5w.jpeg?Expires=1760463554&Signature=Hcz8PJ458Bb5yYgGmSeQnBxsPN3FFSgbeTI1gkUZvLFGcdSS-EcCSN0Pq8N~84FVI5~cWKNlqgrrMopOd53UI1Xb5NoGxZRiT6WibOvRKwB2RmLvfMbwtPGTqi1u9GoQaVrSW3L7Q1zN3OdLTHjzV0IyGcTOmvtSdPgnauyiXtJ9LJAC9PRCj~-eU6xhrA5AHfHibZ0VA4ziNKOUhJc-gU31HJ81jv9SoUrKBjPQEewDtS6KOQhFOnGvXkF7k3hWVq8y6s7wLVofq4M16jNbFxZolAQEWLF6IsUlP0-xheyasX6N2fVteey8haz4uIHpXSuOUpo9ERhyNmbda7g8bQ__&Key-Pair-Id=KJUZTJCQICGXU",
        image_urls: [
          %r{https://cdn.poipiku.com/009416896/010718302_W0EFku4aW.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702506_X5LNftu5w.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702507_F4A4ZHzF8.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702508_ShgkirOUS.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702509_WhaFUJNqD.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702511_nAdPEqifb.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        media_files: [
          { file_size: 1_454_893 },
          { file_size: 1_504_925 },
          { file_size: 384_799 },
          { file_size: 56_656 },
          { file_size: 828_595 },
          { file_size: 365_291 }
        ],
        page_url: "https://poipiku.com/9416896/10718302.html",
        profile_urls: %w[https://poipiku.com/9416896/],
        display_name: "46_UnknownLor",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "箸にも棒にも掛からない"
      )
    end

    context "A new style sample URL" do
      strategy_should_work(
        "https://cdn.poipiku.com/009416896/010718302_023702506_X5LNftu5w.jpeg_640.jpg",
        image_urls: [
          %r{https://cdn.poipiku.com/009416896/010718302_W0EFku4aW.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702506_X5LNftu5w.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702507_F4A4ZHzF8.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702508_ShgkirOUS.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702509_WhaFUJNqD.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
          %r{https://cdn.poipiku.com/009416896/010718302_023702511_nAdPEqifb.jpeg\?Expires=\d*&Signature=.*&Key-Pair-Id=.*},
        ],
        media_files: [
          { file_size: 1_454_893 },
          { file_size: 1_504_925 },
          { file_size: 384_799 },
          { file_size: 56_656 },
          { file_size: 828_595 },
          { file_size: 365_291 }
        ],
        page_url: "https://poipiku.com/9416896/10718302.html",
        profile_urls: %w[https://poipiku.com/9416896/],
        display_name: "46_UnknownLor",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "箸にも棒にも掛からない"
      )
    end
  end
end
