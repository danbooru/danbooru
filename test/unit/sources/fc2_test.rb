require 'test_helper'

module Sources
  class Fc2Test < ActiveSupport::TestCase
    context "FC2:" do
      context "A blog sample image URL" do
        strategy_should_work(
          "https://blog-imgs-119.fc2.com/n/i/y/niyamalog/bokuomapops.jpg",
          image_urls: %w[https://blog-imgs-119.fc2.com/n/i/y/niyamalog/bokuomapop.jpg],
          media_files: [{ file_size: 556_347 }],
          page_url: "http://niyamalog.blog.fc2.com/img/bokuomapop.jpg/",
          profile_urls: %w[http://niyamalog.blog.fc2.com],
          username: "niyamalog",
          other_names: ["niyamalog"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A blog full image URL" do
        strategy_should_work(
          "http://blog-imgs-99-origin.fc2.com/h/7/2/h723/idkdldss.jpg",
          image_urls: %w[http://blog-imgs-99-origin.fc2.com/h/7/2/h723/idkdldss.jpg],
          media_files: [{ file_size: 848_735 }],
          page_url: "http://h723.blog.fc2.com/img/idkdldss.jpg/",
          profile_url: "http://h723.blog.fc2.com",
          profile_urls: %w[http://h723.blog.fc2.com],
          username: "h723",
          other_names: ["h723"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted image URL" do
        strategy_should_work(
          "http://blog-imgs-32-origin.fc2.com/c/o/n/connyac/20100314032806e94.jpg",
          image_urls: %w[http://blog-imgs-32-origin.fc2.com/c/o/n/connyac/20100314032806e94.jpg],
          page_url: nil,
          profile_url: "http://connyac.blog.fc2.com",
          profile_urls: %w[http://connyac.blog.fc2.com],
          username: "connyac",
          other_names: ["connyac"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A blog post with a mobile version" do
        strategy_should_work(
          "https://niyamalog.blog.fc2.com/blog-entry-3.html",
          image_urls: %w[
            https://blog-imgs-119.fc2.com/n/i/y/niyamalog/bokuomapop.jpg
            https://blog-imgs-119.fc2.com/n/i/y/niyamalog/20180824171514638.jpg
            https://blog-imgs-119.fc2.com/n/i/y/niyamalog/20180824171512954.jpg
            https://blog-imgs-119.fc2.com/n/i/y/niyamalog/20180824171513acd.jpg
            https://blog-imgs-119.fc2.com/n/i/y/niyamalog/201808241715095fb.jpg
            https://blog-imgs-119.fc2.com/n/i/y/niyamalog/20180824171510941.jpg
            https://blog-imgs-119.fc2.com/n/i/y/niyamalog/20180824171507829.jpg
          ],
          media_files: [
            { file_size: 556_347 },
            { file_size: 369_435 },
            { file_size: 770_209 },
            { file_size: 305_289 },
            { file_size: 886_461 },
            { file_size: 351_217 },
            { file_size: 245_744 },
          ],
          page_url: "http://niyamalog.blog.fc2.com/blog-entry-3.html",
          profile_url: "http://niyamalog.blog.fc2.com",
          profile_urls: %w[http://niyamalog.blog.fc2.com],
          username: "niyamalog",
          other_names: ["niyamalog", "おやま"],
          tags: [],
          dtext_artist_commentary_title: "僕のおまわりさん販促用ペーパーなど",
          dtext_artist_commentary_desc: <<~EOS.chomp
            僕のおまわりさんの発売日から1年経過しましたので前回同様
            電子版のおまけ以外の特典を公開いたします～。

            紙ペーパーはなくなり次第配布終了なのですが電子ですと配信が続く限り
            特典はずっとつきますので、申し訳ありませんがその辺はご理解いただければと思います。
            割引キャンペーンの時とかに気が向いたら電子版もよろしくお願いいたします・・・！

            "[image]":[http://niyamalog.blog.fc2.com/img/bokuomapop.jpg/]
            書店用ＰＯＰ

            "[image]":[http://niyamalog.blog.fc2.com/img/20180824171514638.jpg/]
            ▲特約店さま用ペーパー

            "[image]":[http://niyamalog.blog.fc2.com/img/20180824171512954.jpg/]
            "[image]":[http://niyamalog.blog.fc2.com/img/20180824171513acd.jpg/]
            ▲コミコミさま両面カード

            "[image]":[http://niyamalog.blog.fc2.com/img/201808241715095fb.jpg/]

            "[image]":[http://niyamalog.blog.fc2.com/img/20180824171510941.jpg/]
            ▲とらのあなさま両面カード

            "[image]":[http://niyamalog.blog.fc2.com/img/20180824171507829.jpg/]
            ▲アニメイトさま用イラストカード

            ※個人的にプリントアウトしてお手元にお持ち頂くのは全くかまいませんが
            プリントアウトしたものをネットオークションやフリマアプリなどに出品するのは
            やめてくださいね～～

            現在momentで連載中の僕のおまわりさん続編もあと2話ほどで最終回をむかえますが（全5話です）
            誠治と晋とチコたんを最後まで見守ってくださるとうれしいです

            発売中のドラマCDも宜しくお願いたします！！
          EOS
        )
      end

      context "A blog post without a mobile version" do
        strategy_should_work(
          "https://killfuckdie.blog.fc2.com/blog-entry-207.html",
          image_urls: [],
          page_url: "http://killfuckdie.blog.fc2.com/blog-entry-207.html",
          profile_url: "http://killfuckdie.blog.fc2.com",
          profile_urls: %w[http://killfuckdie.blog.fc2.com],
          username: "killfuckdie",
          other_names: ["killfuckdie"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A blog post with a nonstandard mobile version" do
        strategy_should_work(
          "http://oekakigakusyuu.blog97.fc2.com/blog-entry-320.html",
          image_urls: [],
          page_url: "http://oekakigakusyuu.blog.fc2.com/blog-entry-320.html",
          profile_url: "http://oekakigakusyuu.blog.fc2.com",
          profile_urls: %w[http://oekakigakusyuu.blog.fc2.com],
          username: "oekakigakusyuu",
          other_names: ["oekakigakusyuu"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A fc2blog.us blog post" do
        strategy_should_work(
          "http://swordsouls.blog131.fc2blog.us/blog-entry-376.html",
          image_urls: %w[http://blog-imgs-57.fc2blog.us/s/w/o/swordsouls/20141009132121fb7.jpg],
          media_files: [{ file_size: 233_495 }],
          page_url: "http://swordsouls.blog.fc2blog.us/blog-entry-376.html",
          profile_url: "http://swordsouls.blog.fc2blog.us",
          profile_urls: %w[http://swordsouls.blog.fc2blog.us],
          username: "swordsouls",
          other_names: ["swordsouls", "深藍侵襲"],
          tags: [],
          dtext_artist_commentary_title: "看板姫♡",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[http://s20.postimg.org/8szg5q37f/image.png]

            【七つの大罪】

            收看纪念~动画相当不错~好久不见的超级王道展开让我也好好的燃了一把！~自己一直都很喜欢这样的王道热血动画，比如【妖精的尾巴】【海贼王】等等这些包括漫画在内我都是一直在追的~

            很久以前在看【妖尾】的时候就有过一起2个作者一起联合画了一个短篇，自己是在那个时候知道这个作品的，不过并没有看漫画，不过这次看完动画之后完全燃起来了~目前在忍住没去看漫画~

            主角的设定以及世界的设定也是自己很喜欢的类型的~这种中欧世界观的魔幻世界一直也是自己理想的异次元世界之一~然后最最最重要的是女主角非常非常可爱~从设定上就是直击我的爱好了~

            那坚强而纯真的性格，那完美的身材，完全是理想的女性角色了呢~虽然有点爱哭，不过在自己的信念上非常鉴定，而且同时也拥有不想牵扯无辜的他人的善良的心灵~自己目前对公主酱的好感非常高~超级期待之后的表现~

            然后就是霍克酱www好久没看到这么萌的宠物角色了~吐槽也很犀利~存在感也超强~就算旁边站着一个几乎完美无瑕的公主酱也无法掩盖它的存在感wwww

            目前虽然才一集，不过就音乐，设定，战斗，画面等等所有因素综合起来这个作品也是目前新番已出所有作品里面首屈一指的~强烈推荐没看过的朋友去好好的燃一下~

            PS：这个季度的作品目前给自己的感觉很不错~有好几部的第一集都非常有好感~强烈期待后续发展中(｀・ω・´)！
          EOS
        )
      end

      context "A blog post with a ?no=:id param" do
        strategy_should_work(
          "http://abk00.blog71.fc2.com/?no=3052",
          image_urls: %w[https://blog-imgs-83-origin.fc2.com/a/b/k/abk00/20150930193800.jpg],
          media_files: [{ file_size: 141_637 }],
          page_url: "http://abk00.blog.fc2.com/blog-entry-3052.html",
          profile_url: "http://abk00.blog.fc2.com",
          profile_urls: %w[http://abk00.blog.fc2.com],
          username: "abk00",
          other_names: ["abk00", "名無しの落書き所"],
          tags: [],
          dtext_artist_commentary_title: "GOD EATER EXTRA[アリサ・イリーニチナ・アミエーラ]",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://blog-imgs-83-origin.fc2.com/a/b/k/abk00/20150930193800.jpg]
            [b]2015/09/30(水) ゴッドイーター エクストラ[アリサ・イリーニチナ・アミエーラ][/b]

            [b]いやぁ…イイ下乳でしたね……(遠い目[/b]

            今期は二人もイイ下乳キャラがいたのに
            どうしてこうなったｘ２になって残念というか無念というか。
            [b]なぜ下乳に一切触れぬ･･･触れぬのか･･･ッ！？[/b]
            いやまあ必要不必要以前に毎回3回以上触れてる健全な性少年育成漫画のアニメ化主人公さんもいたりするわけですが

            [b]やはり時代はエロによって作られる。[/b](今週の格言)  関連記事

            * " ルパン三世[レベッカ・ロッセリーニ] (2015/10/04) ":[http://abk00.blog.fc2.com/blog-entry-3055.html?sp]
            * " ランスアンドマスクス[鬼堂院真緒] (2015/10/02) ":[http://abk00.blog.fc2.com/blog-entry-3054.html?sp]
            * GOD EATER EXTRA[アリサ・イリーニチナ・アミエーラ] (2015/09/30)
            * " GOD EATER EXTRA[雨宮ツバキ] (2015/09/29) ":[http://abk00.blog.fc2.com/blog-entry-3051.html?sp]
            * " わかば＊ガール[真柴直/小橋若葉] (2015/09/28) ":[http://abk00.blog.fc2.com/blog-entry-3050.html?sp]
          EOS
        )
      end

      context "A deleted or nonexistent blog post" do
        strategy_should_work(
          "http://oekakigakusyuu.blog97.fc2.com/blog-entry-999999.html",
          image_urls: [],
          page_url: "http://oekakigakusyuu.blog.fc2.com/blog-entry-999999.html",
          profile_url: "http://oekakigakusyuu.blog.fc2.com",
          profile_urls: %w[http://oekakigakusyuu.blog.fc2.com],
          username: "oekakigakusyuu",
          other_names: ["oekakigakusyuu"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A fc2web.com image" do
        strategy_should_work(
          "http://xkilikox.fc2web.com/image/haguruma00.jpg",
          image_urls: %w[http://xkilikox.fc2web.com/image/haguruma00.jpg],
          media_files: [{ file_size: 34_232 }],
          page_url: nil,
          profile_url: "http://xkilikox.fc2web.com",
          profile_urls: %w[http://xkilikox.fc2web.com],
          username: "xkilikox",
          other_names: ["xkilikox"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse FC2 URLs correctly" do
        assert(Source::URL.image_url?("http://onidocoro.blog14.fc2.com/file/20071003061150.png"))
        assert(Source::URL.image_url?("http://blog23.fc2.com/m/mosha2/file/uru.jpg"))
        assert(Source::URL.image_url?("http://blog.fc2.com/g/genshi/file/20070612a.jpg"))
        assert(Source::URL.image_url?("http://blog-imgs-63-origin.fc2.com/y/u/u/yuukyuukikansya/140817hijiri02.jpg"))
        assert(Source::URL.image_url?("http://blog-imgs-61.fc2.com/o/m/o/omochi6262/20130402080220583.jpg"))
        assert(Source::URL.image_url?("http://blog.fc2.com/g/b/o/gbot/20071023195141.jpg"))
        assert(Source::URL.image_url?("http://diary.fc2.com/user/yuuri/img/2005_12/26.jpg"))

        assert(Source::URL.page_url?("http://hosystem.blog36.fc2.com/blog-entry-37.html"))
        assert(Source::URL.page_url?("http://swordsouls.blog131.fc2blog.us/blog-entry-376.html"))
        assert(Source::URL.page_url?("http://oekakigakusyuu.blog97.fc2.com/?m&no=320"))
        assert(Source::URL.page_url?("http://abk00.blog71.fc2.com/?no=3052"))

        assert(Source::URL.page_url?("http://niyamalog.blog.fc2.com/img/20170330Xray6z7P/"))
        assert(Source::URL.page_url?("http://niyamalog.blog.fc2.com/img/bokuomapop.jpg/"))
        assert(Source::URL.page_url?("http://swordsouls.blog131.fc2blog.us/img/20141009132121fb7.jpg/"))
        assert(Source::URL.page_url?("http://alternatif.blog26.fc2.com/?mode=image&filename=rakugaki10.jpg"))
        assert(Source::URL.page_url?("http://swordsouls.blog131.fc2blog.us/?mode=image&filename=20141009132121fb7.jpg"))

        assert(Source::URL.profile_url?("http://silencexs.blog.fc2.com"))
        assert(Source::URL.profile_url?("http://794ancientkyoto.web.fc2.com"))
        assert(Source::URL.profile_url?("http://yorokobi.x.fc2.com"))
        assert(Source::URL.profile_url?("https://lilish28.bbs.fc2.com"))
        assert(Source::URL.profile_url?("http://jpmaid.h.fc2.com"))
        assert(Source::URL.profile_url?("http://swordsouls.blog131.fc2blog.net"))
        assert(Source::URL.profile_url?("http://swordsouls.blog131.fc2blog.us"))
        assert(Source::URL.profile_url?("http://xkilikox.fc2web.com/image/haguruma.html"))

        assert_equal("http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom?Y=2020&M=1&D=29", Source::URL.page_url("http://diary.fc2.com/user/kazuharoom/img/2020_1/29.jpg"))

        assert_equal("http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom", Source::URL.profile_url("http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom/?Y=2012&M=10&D=22"))
        assert_equal("http://toritokaizoku.web.fc2.com/tori.html", Source::URL.profile_url("http://toritokaizoku.web.fc2.com/tori.html"))
        assert_equal("http://xkilikox.fc2web.com/image/haguruma.html", Source::URL.profile_url("http://xkilikox.fc2web.com/image/haguruma.html"))
        assert_equal("http://xkilikox.fc2web.com", Source::URL.profile_url("http://xkilikox.fc2web.com/image/haguruma00.jpg"))
      end
    end
  end
end
