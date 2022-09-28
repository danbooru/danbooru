require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    setup do
      skip "NicoSeiga credentials not configured" unless Source::Extractor::NicoSeiga.enabled?
    end

    context "A nicoseiga post url" do
      tags = [
        ["アニメ", "https://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"],
        ["コジコジ", "https://seiga.nicovideo.jp/tag/%E3%82%B3%E3%82%B8%E3%82%B3%E3%82%B8"],
        ["さくらももこ", "https://seiga.nicovideo.jp/tag/%E3%81%95%E3%81%8F%E3%82%89%E3%82%82%E3%82%82%E3%81%93"],
        ["ドット絵", "https://seiga.nicovideo.jp/tag/%E3%83%89%E3%83%83%E3%83%88%E7%B5%B5"],
        ["ニコニコ大百科", "https://seiga.nicovideo.jp/tag/%E3%83%8B%E3%82%B3%E3%83%8B%E3%82%B3%E5%A4%A7%E7%99%BE%E7%A7%91"],
        ["お絵カキコ", "https://seiga.nicovideo.jp/tag/%E3%81%8A%E7%B5%B5%E3%82%AB%E3%82%AD%E3%82%B3"],
      ]
      strategy_should_work(
        "http://seiga.nicovideo.jp/seiga/im4937663",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/4937663}],
        download_size: 2_032,
        page_url: "https://seiga.nicovideo.jp/seiga/im4937663",
        tags: tags,
        artist_name: "osamari",
        tag_name: "nicoseiga7017777",
        profile_url: "https://seiga.nicovideo.jp/user/illust/7017777",
        artist_commentary_title: "コジコジ",
        artist_commentary_desc: "コジコジのドット絵\nこんなかわいらしい容姿で毒を吐くコジコジが堪らん（切実）"
      )
    end

    context "A nicoseiga image url" do
      tags = [
        ["アニメ", "https://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"],
        ["コジコジ", "https://seiga.nicovideo.jp/tag/%E3%82%B3%E3%82%B8%E3%82%B3%E3%82%B8"],
        ["さくらももこ", "https://seiga.nicovideo.jp/tag/%E3%81%95%E3%81%8F%E3%82%89%E3%82%82%E3%82%82%E3%81%93"],
        ["ドット絵", "https://seiga.nicovideo.jp/tag/%E3%83%89%E3%83%83%E3%83%88%E7%B5%B5"],
        ["ニコニコ大百科", "https://seiga.nicovideo.jp/tag/%E3%83%8B%E3%82%B3%E3%83%8B%E3%82%B3%E5%A4%A7%E7%99%BE%E7%A7%91"],
        ["お絵カキコ", "https://seiga.nicovideo.jp/tag/%E3%81%8A%E7%B5%B5%E3%82%AB%E3%82%AD%E3%82%B3"],
      ]
      strategy_should_work(
        "http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/4937663}],
        download_size: 2_032,
        page_url: "https://seiga.nicovideo.jp/seiga/im4937663",
        tags: tags,
        artist_name: "osamari",
        tag_name: "nicoseiga7017777",
        profile_url: "https://seiga.nicovideo.jp/user/illust/7017777",
        artist_commentary_title: "コジコジ",
        artist_commentary_desc: "コジコジのドット絵\nこんなかわいらしい容姿で毒を吐くコジコジが堪らん（切実）"
      )
    end

    context "A nicoseiga manga url" do
      image_urls = [
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315315},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315318},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315319},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315320},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315321},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315322},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315323},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315324},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10315316},
      ]

      strategy_should_work(
        "https://seiga.nicovideo.jp/watch/mg470189?track=ct_episode",
        image_urls: image_urls,
        page_url: "https://seiga.nicovideo.jp/watch/mg470189",
        artist_name: "風呂",
        profile_url: "https://seiga.nicovideo.jp/user/illust/20797022",
        artist_commentary_title: "ハコ女子 1ハコ目",
        artist_commentary_desc: "同じクラスの箱田さんはいつもハコを被っている。しかしてその素顔は…？　twitter(@hakojoshi1)にてだいたい毎日更新中。こっちだともうちょっと先まで読めるよ。"
      )
    end

    context "A https://lohas.nicoseiga.jp/thumb/${id}i url" do
      strategy_should_work(
        "https://lohas.nicoseiga.jp/thumb/6844226i",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/6844226}],
        page_url: "https://seiga.nicovideo.jp/seiga/im6844226"
      )
    end

    context "An image/source/123 url with referrer" do
      strategy_should_work(
        "https://seiga.nicovideo.jp/image/source/9146749",
        referer: "https://seiga.nicovideo.jp/watch/mg389884",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/9146749}],
        page_url: "https://seiga.nicovideo.jp/watch/mg389884"
      )
    end

    context "A drm.cdn.nicomanga.jp image url" do
      strategy_should_work(
        "https://drm.cdn.nicomanga.jp/image/d4a2faa68ec34f95497db6601a4323fde2ccd451_9537/8017978p?1570012695",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017978}]
      )
    end

    context "A nico.ms illust url" do
      strategy_should_work(
        "https://nico.ms/im10922621",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/10922621}],
        page_url: "https://seiga.nicovideo.jp/seiga/im10922621",
        profile_url: "https://seiga.nicovideo.jp/user/illust/2258804"
      )
    end

    context "A nico.ms manga url from an anonymous user" do
      image_urls = [
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017978},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017979},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017980},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017981},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017982},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017983},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017984},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017985},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017986},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017987},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017988},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017989},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017990},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017991},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017992},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017993},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017994},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017995},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/8017996},
      ]

      strategy_should_work(
        "https://nico.ms/mg310193",
        image_urls: image_urls,
        artist_name: nil,
        profile_url: nil,
        artist_commentary_title: "ライブダンジョン！ 第1話前半"
      )
    end

    context "An anonymous illust" do
      strategy_should_work(
        "https://seiga.nicovideo.jp/seiga/im520647",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/520647}],
        artist_name: nil,
        profile_url: nil
      )
    end

    context "A nicoseiga video" do
      strategy_should_work(
        "https://www.nicovideo.jp/watch/sm36465441"
      )
    end

    context "An age-restricted picture" do
      strategy_should_work(
        "http://seiga.nicovideo.jp/seiga/im9208126",
        image_urls: [%r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/9208126}],
        artist_name: "ちふり",
        profile_url: "https://seiga.nicovideo.jp/user/illust/61431040",
        tags: ["R-15"],
        artist_commentary_title: "ゾーヤさんといっしょ"
      )
    end

    context "An oekaki direct url" do
      strategy_should_work(
        "https://dic.nicovideo.jp/oekaki/52833.png",
        image_urls: ["https://dic.nicovideo.jp/oekaki/52833.png"]
      )
    end

    context "A nicoseiga manga page with a single tag (source of XML misparsing)" do
      image_urls = [
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/7891076},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/7891080},
        %r{https://lohas\.nicoseiga\.jp/priv/\h+/\d+/7891081},
      ]
      strategy_should_work(
        "https://seiga.nicovideo.jp/watch/mg302561",
        image_urls: image_urls,
        page_url: "https://seiga.nicovideo.jp/watch/mg302561",
        tags: [["ロリ", "https://seiga.nicovideo.jp/manga/tag/%E3%83%AD%E3%83%AA"]],
        artist_name: "とろてい",
        tag_name: "nicoseiga1848060"
      )
    end

    context "A commentary with spoiler" do
      should "correctly add spoiler tags" do
        site = Source::Extractor.find("https://seiga.nicovideo.jp/seiga/im8992650")

        commentary = <<~COMM.chomp
          SLVN大好き。ホントニアコガレテル。

          [spoiler]
          「魔理沙とアリスのクッキーKiss」
          企画者HZNの企画した東方合同動画企画
          苦行を称する東方ボイスドラマ
          遥か昔、東方界隈のはずれ
          その偏境に消えぬボイスドラマの火を見出したとき
          若き健常者HZNの心にも
          消えぬ野心が灯ったのだろう
          戦技は「義務教育」
          クッキー☆を終わるまで視聴させる技
          27分にわたる苦行からのエンディングで視聴者はぬわ疲に包まれる
          [/spoiler]
        COMM

        assert_equal(commentary, site.dtext_artist_commentary_desc)
      end
    end

    should "Parse NicoSeiga URLs correctly" do
      assert_equal("https://seiga.nicovideo.jp/seiga/im4937663", Source::URL.page_url("http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663"))

      assert(Source::URL.image_url?("http://lohas.nicoseiga.jp/priv/3521156?e=1382558156&h=f2e089256abd1d453a455ec8f317a6c703e2cedf"))
      assert(Source::URL.image_url?("http://lohas.nicoseiga.jp/priv/b80f86c0d8591b217e7513a9e175e94e00f3c7a1/1384936074/3583893"))
      assert(Source::URL.image_url?("https://lohas.nicoseiga.jp/o/971eb8af9bbcde5c2e51d5ef3a2f62d6d9ff5552/1589933964/3583893"))
      assert(Source::URL.image_url?("http://seiga.nicovideo.jp/image/source?id=3312222"))
      assert(Source::URL.image_url?("https://seiga.nicovideo.jp/image/source/3521156"))
      assert(Source::URL.image_url?("https://seiga.nicovideo.jp/image/redirect?id=3583893"))
      assert(Source::URL.image_url?("https://lohas.nicoseiga.jp/thumb/2163478i"))
      assert(Source::URL.image_url?("https://lohas.nicoseiga.jp/thumb/4744553p"))
      assert(Source::URL.image_url?("https://dcdn.cdn.nimg.jp/priv/62a56a7f67d3d3746ae5712db9cac7d465f4a339/1592186183/10466669"))
      assert(Source::URL.image_url?("https://drm.cdn.nicomanga.jp/image/d4a2faa68ec34f95497db6601a4323fde2ccd451_9537/8017978p?1570012695"))

      assert(Source::URL.page_url?("https://seiga.nicovideo.jp/seiga/im520647"))
      assert(Source::URL.page_url?("https://sp.seiga.nicovideo.jp/seiga/im3521156"))
      assert(Source::URL.page_url?("https://seiga.nicovideo.jp/watch/mg316708"))
      assert(Source::URL.page_url?("https://www.nicovideo.jp/watch/sm36465441"))
      assert(Source::URL.page_url?("https://www.nicovideo.jp/watch/nm36465441"))
      assert(Source::URL.page_url?("https://nico.ms/im10922621"))
      assert(Source::URL.page_url?("https://nico.ms/mg310193"))
      assert(Source::URL.page_url?("https://nico.ms/sm36465441"))
      assert(Source::URL.page_url?("https://nico.ms/nm36465441"))

      assert(Source::URL.profile_url?("https://seiga.nicovideo.jp/user/illust/456831"))
      assert(Source::URL.profile_url?("https://ext.seiga.nicovideo.jp/user/illust/20542122"))
      assert(Source::URL.profile_url?("http://seiga.nicovideo.jp/manga/list?user_id=23839737"))
      assert(Source::URL.profile_url?("https://www.nicovideo.jp/user/4572975"))
      assert(Source::URL.profile_url?("https://commons.nicovideo.jp/user/696839"))
      assert(Source::URL.profile_url?("https://q.nicovideo.jp/users/18700356"))
      assert(Source::URL.profile_url?("https://dic.nicovideo.jp/u/11141663"))
      assert(Source::URL.profile_url?("https://3d.nicovideo.jp/users/109584"))
      assert(Source::URL.profile_url?("https://3d.nicovideo.jp/u/siobi"))
      assert(Source::URL.profile_url?("http://game.nicovideo.jp/atsumaru/users/7757217"))

      assert_not(Source::URL.profile_url?("https://seiga.nicovideo.jp"))
    end
  end
end
