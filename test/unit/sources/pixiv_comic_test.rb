# frozen_string_literal: true

require "test_helper"

module Sources
  class PixivComicTest < ActiveSupport::TestCase
    context "Pixiv Comic:" do
      context "A magazine cover image" do
        strategy_should_work(
          "https://public-img-comic.pximg.net/images/magazine_cover/e772MnFuZZ5oQsadLQ2b/317.jpg?20240120120001",
          image_urls: %w[https://public-img-comic.pximg.net/images/magazine_cover/e772MnFuZZ5oQsadLQ2b/317.jpg],
          media_files: [{ file_size: 150_123 }],
          page_url: "https://comic.pixiv.net/magazines/317",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "pixivガンマぷらす",
          dtext_artist_commentary_desc: <<~EOS.chomp
            竹書房の漫画サイト「WEBコミックガンマぷらす」出張所です。こちらのpixivコミック版では毎週土曜日、ぜひ読んでほしいオススメ作品の数々をお届け!! ホッとしたり、キュンとしたり、ゾクゾクしたり…お楽しみは無限大です!!!!
          EOS
        )
      end

      context "A comic page sample image" do
        strategy_should_work(
          "https://img-comic.pximg.net/c/q90_gridshuffle32:32/images/page/162153/iMnq837lBFlyCIpIstcp/1.jpg?20240112151247",
          image_urls: %w[https://img-comic.pximg.net/images/page/162153/iMnq837lBFlyCIpIstcp/1.jpg],
          media_files: [{ file_size: 733_570 }],
          page_url: "https://comic.pixiv.net/viewer/stories/162153",
          profile_url: nil,
          profile_urls: [],
          artist_name: "谷澤史紀",
          tag_name: nil,
          other_names: ["谷澤史紀"],
          tags: [
            ["動物", "https://comic.pixiv.net/categories/動物"],
            ["日常", "https://comic.pixiv.net/categories/日常"],
            ["平々凡々", "https://comic.pixiv.net/tags/平々凡々"],
            ["飼育", "https://comic.pixiv.net/tags/飼育"],
            ["強面", "https://comic.pixiv.net/tags/強面"],
            ["小学生", "https://comic.pixiv.net/tags/小学生"],
            ["日記", "https://comic.pixiv.net/tags/日記"],
          ],
          dtext_artist_commentary_title: "1日目",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A comic cover sample image" do
        strategy_should_work(
          "https://public-img-comic.pximg.net/c!/f=webp:auto,w=384,q=75/images/work_main/10137.jpg?20240217160416",
          image_urls: %w[https://public-img-comic.pximg.net/images/work_main/10137.jpg],
          media_files: [{ file_size: 507_056 }],
          page_url: "https://comic.pixiv.net/works/10137",
          profile_url: nil,
          profile_urls: [],
          artist_name: "谷澤史紀",
          tag_name: nil,
          other_names: ["谷澤史紀"],
          tags: [
            ["動物", "https://comic.pixiv.net/categories/動物"],
            ["日常", "https://comic.pixiv.net/categories/日常"],
            ["平々凡々", "https://comic.pixiv.net/tags/平々凡々"],
            ["飼育", "https://comic.pixiv.net/tags/飼育"],
            ["強面", "https://comic.pixiv.net/tags/強面"],
            ["小学生", "https://comic.pixiv.net/tags/小学生"],
            ["日記", "https://comic.pixiv.net/tags/日記"],
          ],
          dtext_artist_commentary_title: "今日もとなりへ猫詣で!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            片親の小学生×強面の猫が織りなす、心温まる平々凡々な飼育日記。"にゃんにゃんコミックス、発売中!!":[https://www.amazon.co.jp/dp/B0BJ15P135]
          EOS
        )
      end

      context "A novel work cover sample image" do
        strategy_should_work(
          "https://img-novel.pximg.net/c!/f=webp:auto,w=384,q=75/img-novel/work_main/BJruKIb2nWvhTadwsL68/3877.jpg?20240430174032",
          image_urls: %w[https://img-novel.pximg.net/img-novel/work_main/BJruKIb2nWvhTadwsL68/3877.jpg?20240430174032],
          media_files: [{ file_size: 187_124 }],
          page_url: "https://comic.pixiv.net/novel/works/3877",
          profile_url: nil,
          profile_urls: [],
          artist_name: "植田 亮",
          tag_name: nil,
          other_names: ["植田 亮"],
          tags: [
            ["HJ文庫", "https://comic.pixiv.net/novel/categories/HJ文庫"],
          ],
          dtext_artist_commentary_title: "青春マッチングアプリ 1",
          dtext_artist_commentary_desc: <<~EOS.chomp
            青春をあきらめていた高校生・凪野夕景のスマホに、とあるアプリがインストールされた。アプリの名前は『青春マッチングアプリ』。
            それはマッチング相手と『正しい青春』を送るためのミッションをクリアすると報酬を与えるというもの。マッチングしたのは、なんと同じクラスの美少女・花宮花。
            彼女は自身の夢を叶えるため、ミッションをこなしたいという。青春とは何かを知る
            ため、花の夢を叶えるため、夕景は送られてくる指令をこなしていくが──。
            不思議なアプリからはじまる青春学園ラブコメディ！
          EOS
        )
      end

      context "A novel page image" do
        strategy_should_work(
          "https://img-novel.pximg.net/img-novel/page/11588/GRqnlQ258aa3CFxpRIys/1.jpg?20240426103009",
          image_urls: %w[https://img-novel.pximg.net/img-novel/page/11588/GRqnlQ258aa3CFxpRIys/1.jpg?20240426103009],
          media_files: [{ file_size: 27_815 }],
          page_url: "https://comic.pixiv.net/novel/viewer/stories/11588",
          profile_url: nil,
          profile_urls: [],
          artist_name: "植田 亮",
          tag_name: nil,
          other_names: ["植田 亮"],
          tags: [
            ["HJ文庫", "https://comic.pixiv.net/novel/categories/HJ文庫"],
          ],
          dtext_artist_commentary_title: "試し読み",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A magazine page" do
        strategy_should_work(
          "https://comic.pixiv.net/magazines/88",
          image_urls: %w[https://public-img-comic.pximg.net/images/magazine_cover/Mt7hinuzDt2QuhXrJpKg/88.jpg],
          media_files: [{ file_size: 177_541 }],
          page_url: "https://comic.pixiv.net/magazines/88",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "ジーンピクシブ",
          dtext_artist_commentary_desc: <<~EOS.chomp
            みつける・つながる・ばずる。みんなで見つけてみんなで共有。無料で全部読めるもうひとつのコミックジーン「ジーンピクシブ」。pixivで人気の作品や人気作家の新作、はたまたジーン作品のスピンオフなど、いろんなマンガを大公開!! まんがはたのしい！
          EOS
        )
      end

      context "A comic work page" do
        strategy_should_work(
          "https://comic.pixiv.net/works/10137",
          image_urls: %w[https://public-img-comic.pximg.net/images/work_main/10137.jpg],
          media_files: [{ file_size: 507_056 }],
          page_url: "https://comic.pixiv.net/works/10137",
          profile_url: nil,
          profile_urls: [],
          artist_name: "谷澤史紀",
          tag_name: nil,
          other_names: ["谷澤史紀"],
          tags: [
            ["動物", "https://comic.pixiv.net/categories/動物"],
            ["日常", "https://comic.pixiv.net/categories/日常"],
            ["平々凡々", "https://comic.pixiv.net/tags/平々凡々"],
            ["飼育", "https://comic.pixiv.net/tags/飼育"],
            ["強面", "https://comic.pixiv.net/tags/強面"],
            ["小学生", "https://comic.pixiv.net/tags/小学生"],
            ["日記", "https://comic.pixiv.net/tags/日記"],
          ],
          dtext_artist_commentary_title: "今日もとなりへ猫詣で!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            片親の小学生×強面の猫が織りなす、心温まる平々凡々な飼育日記。"にゃんにゃんコミックス、発売中!!":[https://www.amazon.co.jp/dp/B0BJ15P135]
          EOS
        )
      end

      context "A comic story page" do
        strategy_should_work(
          "https://comic.pixiv.net/viewer/stories/162153",
          image_urls: %w[
            https://img-comic.pximg.net/images/page/162153/iMnq837lBFlyCIpIstcp/1.jpg
            https://img-comic.pximg.net/images/page/162153/de8fSaYq6Xnv3Vv09cYz/2.jpg
            https://img-comic.pximg.net/images/page/162153/NKz6zWqSsX5fzN8Nfrny/3.jpg
            https://img-comic.pximg.net/images/page/162153/TLG73pVPF1KO5O0roX4q/4.jpg
            https://img-comic.pximg.net/images/page/162153/NG8ddJ17ZAMXQ71xoWay/5.jpg
            https://img-comic.pximg.net/images/page/162153/LWamdX95ZTTjuwIscV6x/6.jpg
            https://img-comic.pximg.net/images/page/162153/wLkbHFlCRFfgor5tZEn6/7.jpg
            https://img-comic.pximg.net/images/page/162153/FkToucrnChzOes9rFgLU/8.jpg
            https://img-comic.pximg.net/images/page/162153/xgLSItxytkbltq4dYnRA/9.jpg
            https://img-comic.pximg.net/images/page/162153/m1GiQblQRDN5pskPWF1Z/10.jpg
            https://img-comic.pximg.net/images/page/162153/9ngzU1PsF11lDJe46L4e/11.jpg
            https://img-comic.pximg.net/images/page/162153/KwG5rTcnbOCAvtmPLVLY/12.jpg
            https://img-comic.pximg.net/images/page/162153/fqwCnUwVB0j1k7cguNOE/13.jpg
            https://img-comic.pximg.net/images/page/162153/Z7vD7e0QZgMfO0I9Ifk6/14.jpg
            https://img-comic.pximg.net/images/page/162153/EG3GmqkyEVw0SbaeNYrB/15.jpg
            https://img-comic.pximg.net/images/page/162153/vrBu3rA8TL5jZGdNv34S/16.jpg
            https://img-comic.pximg.net/images/page/162153/aoSLsKVEfkgw89DjZsgC/17.jpg
            https://img-comic.pximg.net/images/page/162153/47BVGHAHHzKdEBy3zgJ7/18.jpg
            https://img-comic.pximg.net/images/page/162153/EQiMMXDUeFmJkjNFUP5h/19.jpg
            https://img-comic.pximg.net/images/page/162153/VqbD6cMtrxtpASZW2A1M/20.jpg
            https://img-comic.pximg.net/images/page/162153/tezlwe5c95u8RjMQ6iMk/21.jpg
            https://img-comic.pximg.net/images/page/162153/MP6pPGQAOE5TyXrwO8XR/22.jpg
            https://img-comic.pximg.net/images/page/162153/t1WXwwPSnWfVc1j89jMu/23.jpg
            https://img-comic.pximg.net/images/page/162153/KfQgbvOdq0GOqInSnYkK/24.jpg
            https://img-comic.pximg.net/images/page/162153/mM92lFOgJ1bOAZpr7zWO/25.jpg
          ],
          media_files: [
            { file_size: 733_570 },
            { file_size: 450_059 },
            { file_size: 452_892 },
            { file_size: 459_931 },
            { file_size: 465_587 },
            { file_size: 450_365 },
            { file_size: 468_727 },
            { file_size: 479_333 },
            { file_size: 453_126 },
            { file_size: 495_013 },
            { file_size: 480_452 },
            { file_size: 456_166 },
            { file_size: 435_159 },
            { file_size: 438_266 },
            { file_size: 443_533 },
            { file_size: 446_228 },
            { file_size: 436_543 },
            { file_size: 404_913 },
            { file_size: 488_485 },
            { file_size: 437_635 },
            { file_size: 444_935 },
            { file_size: 473_174 },
            { file_size: 398_201 },
            { file_size: 476_949 },
            { file_size: 789_876 },
          ],
          page_url: "https://comic.pixiv.net/viewer/stories/162153",
          profile_url: nil,
          profile_urls: [],
          artist_name: "谷澤史紀",
          tag_name: nil,
          other_names: ["谷澤史紀"],
          tags: [
            ["動物", "https://comic.pixiv.net/categories/動物"],
            ["日常", "https://comic.pixiv.net/categories/日常"],
            ["平々凡々", "https://comic.pixiv.net/tags/平々凡々"],
            ["飼育", "https://comic.pixiv.net/tags/飼育"],
            ["強面", "https://comic.pixiv.net/tags/強面"],
            ["小学生", "https://comic.pixiv.net/tags/小学生"],
            ["日記", "https://comic.pixiv.net/tags/日記"],
          ],
          dtext_artist_commentary_title: "1日目",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A novel work page" do
        strategy_should_work(
          "https://comic.pixiv.net/novel/works/3877",
          image_urls: %w[https://img-novel.pximg.net/img-novel/work_main/BJruKIb2nWvhTadwsL68/3877.jpg?20240430174032],
          media_files: [{ file_size: 187_124 }],
          page_url: "https://comic.pixiv.net/novel/works/3877",
          profile_url: nil,
          profile_urls: [],
          artist_name: "植田 亮",
          tag_name: nil,
          other_names: ["植田 亮"],
          tags: [
            ["HJ文庫", "https://comic.pixiv.net/novel/categories/HJ文庫"],
          ],
          dtext_artist_commentary_title: "青春マッチングアプリ 1",
          dtext_artist_commentary_desc: <<~EOS.chomp
            青春をあきらめていた高校生・凪野夕景のスマホに、とあるアプリがインストールされた。アプリの名前は『青春マッチングアプリ』。
            それはマッチング相手と『正しい青春』を送るためのミッションをクリアすると報酬を与えるというもの。マッチングしたのは、なんと同じクラスの美少女・花宮花。
            彼女は自身の夢を叶えるため、ミッションをこなしたいという。青春とは何かを知る
            ため、花の夢を叶えるため、夕景は送られてくる指令をこなしていくが──。
            不思議なアプリからはじまる青春学園ラブコメディ！
          EOS
        )
      end

      context "A novel story page" do
        strategy_should_work(
          "https://comic.pixiv.net/novel/viewer/stories/11560",
          image_urls: %w[
            https://img-novel.pximg.net/img-novel/page/11560/VrjuzkkUeYoBU9bY2YzU/1.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/sc4wMUqRTkAtKWUma8Ws/2.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/oNegz8iI9mObGKdi7kJA/3.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/tOKmlO4RgiPJsK0cWcWY/4.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/qUcy2ebxGBsP7oUl6Une/5.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/F92f2d9WXnZ9PNBYkNwK/6.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/pegCSKKp0XsaFKEvWzIU/7.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/iI9Mx8sN8wjCeQlDN0Rs/8.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/4GJZHw1Znp6vizNUpHjP/9.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/VKvjQhCyjE44z6h0mhCh/10.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/5S666lPA8TWCGwwkfQIm/11.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/Op0XjNvEjzVGjJtppzVa/12.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/i3SlpfvyBNkn33gHA2EE/13.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/fvXmgUROsiOGyuO8LsAW/14.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/ZDwqF3c8kDxhdjMMa8PI/15.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/j4ya6xYua5uFaYQW2KLe/16.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/PJpYh8BEEsM3V4YWGHQp/17.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/jOUsrxAGdScwGLR89DVc/18.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/mqiISgH3QlD5wzh5OJGJ/19.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/7cSfF34RztLuwTdvbDY9/20.jpg?20240417153806
            https://img-novel.pximg.net/img-novel/page/11560/CK35rU63V3d1Ns3Ri3L6/21.jpg?20240417153806
          ],
          media_files: [
            { file_size: 48_654 },
            { file_size: 12_369 },
            { file_size: 20_706 },
            { file_size: 106_704 },
            { file_size: 135_333 },
            { file_size: 110_413 },
            { file_size: 127_592 },
            { file_size: 109_548 },
            { file_size: 120_872 },
            { file_size: 96_959 },
            { file_size: 129_344 },
            { file_size: 111_008 },
            { file_size: 125_435 },
            { file_size: 149_809 },
            { file_size: 107_983 },
            { file_size: 110_313 },
            { file_size: 111_840 },
            { file_size: 100_135 },
            { file_size: 122_166 },
            { file_size: 192_466 },
            { file_size: 227_624 },
          ],
          page_url: "https://comic.pixiv.net/novel/viewer/stories/11560",
          profile_url: nil,
          profile_urls: [],
          artist_name: "フライ",
          tag_name: nil,
          other_names: ["フライ"],
          tags: [
            ["ことのは文庫", "https://comic.pixiv.net/novel/categories/ことのは文庫"],
          ],
          dtext_artist_commentary_title: "試読第１話 第一章 変わり始めたふたりの関係(1)",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent comic work" do
        strategy_should_work(
          "https://comic.pixiv.net/works/9999999",
          image_urls: [],
          page_url: "https://comic.pixiv.net/works/9999999",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent comic story" do
        strategy_should_work(
          "https://comic.pixiv.net/viewer/stories/999999",
          image_urls: [],
          page_url: "https://comic.pixiv.net/viewer/stories/999999",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent novel work" do
        strategy_should_work(
          "https://comic.pixiv.net/novel/works/999999",
          image_urls: [],
          page_url: "https://comic.pixiv.net/novel/works/999999",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent novel story" do
        strategy_should_work(
          "https://comic.pixiv.net/novel/viewer/stories/999999",
          image_urls: [],
          page_url: "https://comic.pixiv.net/novel/viewer/stories/999999",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent magazine" do
        strategy_should_work(
          "https://comic.pixiv.net/magazines/999999",
          image_urls: [],
          media_files: [],
          page_url: "https://comic.pixiv.net/magazines/999999",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A comic story that has been made unavailable" do
        strategy_should_work(
          "https://comic.pixiv.net/viewer/stories/11588",
          image_urls: [],
          media_files: [],
          page_url: "https://comic.pixiv.net/viewer/stories/11588",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse URLs correctly" do
        assert_equal("https://comic.pixiv.net/magazines/317", Source::URL.page_url("https://public-img-comic.pximg.net/images/magazine_cover/e772MnFuZZ5oQsadLQ2b/317.jpg?20240120120001"))
        assert_equal("https://comic.pixiv.net/magazines/317", Source::URL.page_url("https://public-img-comic.pximg.net/images/magazine_logo/e772MnFuZZ5oQsadLQ2b/317.png?20240120120001"))
        assert_equal("https://comic.pixiv.net/viewer/stories/162153", Source::URL.page_url("https://img-comic.pximg.net/c/q90_gridshuffle32:32/images/page/162153/iMnq837lBFlyCIpIstcp/1.jpg?20240112151247"))
        assert_equal("https://comic.pixiv.net/viewer/stories/9869", Source::URL.page_url("https://img-comic.pximg.net/images/page/9869/V52hshKjl05juBvdbHJ5/2.jpg?20151030104009"))
        assert_equal("https://comic.pixiv.net/viewer/stories/167869", Source::URL.page_url("https://public-img-comic.pximg.net/c!/f=webp:auto,w=96,q=75/images/story_thumbnail/92O1JVc8DrrTTTfKdl2R/167869.jpg?20240426131638"))
        assert_equal("https://comic.pixiv.net/works/10137", Source::URL.page_url("https://public-img-comic.pximg.net/c!/q=90,f=webp%3Ajpeg/images/work_thumbnail/10137.jpg?20240217160416"))
        assert_equal("https://comic.pixiv.net/works/10137", Source::URL.page_url("https://public-img-comic.pximg.net/c!/w=200,f=webp%3Ajpeg/images/work_main/10137.jpg?20240217160416"))
        assert_equal("https://comic.pixiv.net/works/10137", Source::URL.page_url("https://public-img-comic.pximg.net/images/work_main/10137.jpg?20240217160416"))
        assert_equal("https://comic.pixiv.net/works/10137", Source::URL.page_url("https://img-comic.pximg.net/images/work_main/10137.jpg?20240217160416"))
        assert_equal("https://comic.pixiv.net/novel/works/3877", Source::URL.page_url("https://img-novel.pximg.net/c!/f=webp:auto,w=384,q=75/img-novel/work_main/BJruKIb2nWvhTadwsL68/3877.jpg?20240430174032"))
        assert_equal("https://comic.pixiv.net/novel/viewer/stories/11588", Source::URL.page_url("https://img-novel.pximg.net/img-novel/page/11588/GRqnlQ258aa3CFxpRIys/1.jpg?20240426103009"))

        assert(Source::URL.page_url?("https://comic.pixiv.net/magazines/317"))
        assert(Source::URL.page_url?("https://comic.pixiv.net/works/10137"))
        assert(Source::URL.page_url?("https://comic.pixiv.net/viewer/stories/162153"))
        assert(Source::URL.page_url?("https://comic.pixiv.net/novel/works/3877"))
        assert(Source::URL.page_url?("https://comic.pixiv.net/novel/viewer/stories/11588"))
      end
    end
  end
end
