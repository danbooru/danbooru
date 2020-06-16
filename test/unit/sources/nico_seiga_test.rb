require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        @site_1 = Sources::Strategies.find("http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663")
        @site_2 = Sources::Strategies.find("http://seiga.nicovideo.jp/seiga/im4937663")
        @site_3 = Sources::Strategies.find("https://seiga.nicovideo.jp/watch/mg470189?track=ct_episode")
      end

      should "get the profile" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777", @site_1.profile_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777", @site_2.profile_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/20797022", @site_3.profile_url)
      end

      should "get the artist name" do
        assert_equal("osamari", @site_1.artist_name)
        assert_equal("osamari", @site_2.artist_name)
        assert_equal("風呂", @site_3.artist_name)
      end

      should "get the artist commentary" do
        assert_equal("コジコジ", @site_2.artist_commentary_title)
        assert_equal("コジコジのドット絵\nこんなかわいらしい容姿で毒を吐くコジコジが堪らん（切実）", @site_2.artist_commentary_desc)

        assert_equal("ハコ女子 1ハコ目", @site_3.artist_commentary_title)
        assert_equal("同じクラスの箱田さんはいつもハコを被っている。しかしてその素顔は…？　twitter(@hakojoshi1)にてだいたい毎日更新中。こっちだともうちょっと先まで読めるよ。", @site_3.artist_commentary_desc)
      end

      should "get the image url(s)" do
        assert_match(%r{^https?://lohas\.nicoseiga\.jp/priv/}, @site_1.image_url)
        assert_match(%r{^https?://lohas\.nicoseiga\.jp/priv/}, @site_2.image_url)

        expected = %w[
          https://seiga.nicovideo.jp/image/source/10315315
          https://seiga.nicovideo.jp/image/source/10315318
          https://seiga.nicovideo.jp/image/source/10315319
          https://seiga.nicovideo.jp/image/source/10315320
          https://seiga.nicovideo.jp/image/source/10315321
          https://seiga.nicovideo.jp/image/source/10315322
          https://seiga.nicovideo.jp/image/source/10315323
          https://seiga.nicovideo.jp/image/source/10315324
          https://seiga.nicovideo.jp/image/source/10315316
        ]
        assert_equal(expected.sort, @site_3.image_urls.sort)
        assert_match(%r{^https?://lohas\.nicoseiga\.jp/priv/}, @site_3.image_url)
      end

      should "get the canonical url" do
        assert_equal("https://seiga.nicovideo.jp/image/source/4937663", @site_1.canonical_url)
        assert_equal("https://seiga.nicovideo.jp/seiga/im4937663", @site_2.canonical_url)
        assert_equal("https://seiga.nicovideo.jp/watch/mg470189", @site_3.canonical_url)
      end

      should "get the tags" do
        assert_not(@site_1.tags.empty?)
        first_tag = @site_1.tags.first
        assert_equal(["アニメ", "https://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"], first_tag)

        assert_not(@site_2.tags.empty?)
        first_tag = @site_2.tags.first
        assert_equal(["アニメ", "https://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"], first_tag)

        assert_not(@site_3.tags.empty?)
        first_tag = @site_3.tags.first
        assert_equal(["4コマ漫画", "https://seiga.nicovideo.jp/manga/tag/4%E3%82%B3%E3%83%9E%E6%BC%AB%E7%94%BB"], first_tag)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised { @site_1.to_h }
        assert_nothing_raised { @site_2.to_h }
        assert_nothing_raised { @site_3.to_h }
      end

      should "work for a https://lohas.nicoseiga.jp/thumb/${id}i url" do
        site = Sources::Strategies.find("https://lohas.nicoseiga.jp/thumb/6844226i")

        assert_match(%r!https?://lohas.nicoseiga.jp/priv/[a-f0-9]{40}/[0-9]+/6844226!, site.image_url)
        assert_match("https://seiga.nicovideo.jp/seiga/im6844226", site.canonical_url)
      end
    end

    context "A manga upload through bookmarklet" do
      setup do
        @url = "https://seiga.nicovideo.jp/image/source/9146749"
        @ref = "https://seiga.nicovideo.jp/watch/mg389884"
        @site = Sources::Strategies.find(@url, @ref)
      end

      should "get the correct pic" do
        assert_match(%r!https?://lohas.nicoseiga.jp/priv/[a-f0-9]{40}/[0-9]+/9146749!, @site.image_url)
      end

      should "set the correct source" do
        assert_equal(@ref, @site.canonical_url)
      end
    end

    context "A nicoseiga video" do
      should "not raise anything" do
        site = Sources::Strategies.find("https://www.nicovideo.jp/watch/sm36465441")
        assert_nothing_raised { site.to_h }
      end
    end

    context "An anonymous picture" do
      should "still work" do
        site = Sources::Strategies.find("https://seiga.nicovideo.jp/seiga/im520647")

        assert_nothing_raised { site.to_h }
      end
    end

    context "An age-restricted picture" do
      should "still work" do
        site = Sources::Strategies.find("http://seiga.nicovideo.jp/seiga/im9208126")

        assert_match(%r!https?://lohas.nicoseiga.jp/priv/[a-f0-9]{40}/[0-9]+/9208126!, site.image_url)
        assert_nothing_raised { site.to_h }
      end
    end

    context "An oekaki picture" do
      should "still work" do
        site = Sources::Strategies.find("https://dic.nicovideo.jp/oekaki/52833.png")
        assert_nothing_raised { site.to_h }
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "http://lohas.nicoseiga.jp/priv/3521156?e=1382558156&h=f2e089256abd1d453a455ec8f317a6c703e2cedf"
        source2 = "http://lohas.nicoseiga.jp/priv/b80f86c0d8591b217e7513a9e175e94e00f3c7a1/1384936074/3583893"
        source3 = "http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663"
        source4 = "http://seiga.nicovideo.jp/image/source?id=3312222"

        assert_equal("https://seiga.nicovideo.jp/image/source/3521156", Sources::Strategies.normalize_source(source1))
        assert_equal("https://seiga.nicovideo.jp/image/source/3583893", Sources::Strategies.normalize_source(source2))
        assert_equal("https://seiga.nicovideo.jp/image/source/4937663", Sources::Strategies.normalize_source(source3))
        assert_equal("https://seiga.nicovideo.jp/image/source/3312222", Sources::Strategies.normalize_source(source4))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source = "https://seiga.nicovideo.jp"
        assert_equal(bad_source, Sources::Strategies.normalize_source(bad_source))
      end
    end

    context "downloading a 'http://seiga.nicovideo.jp/seiga/:id' url" do
      should "download the original file" do
        @source = "http://seiga.nicovideo.jp/seiga/im4937663"
        @rewrite = %r{https://lohas.nicoseiga.jp/priv/\h{40}/\d+/4937663}
        assert_rewritten(@rewrite, @source)
        assert_downloaded(2_032, @source)
      end
    end

    context "downloading a 'http://lohas.nicoseiga.jp/o/:hash/:id' url" do
      should "download the original file" do
        @source = "http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663"
        @rewrite = %r{https://lohas.nicoseiga.jp/priv/\h{40}/\d+/4937663}
        assert_rewritten(@rewrite, @source)
        assert_downloaded(2_032, @source)
      end
    end

    context "downloading a 'https://lohas.nicoseiga.jp/thumb/:id' url" do
      should "download the original file" do
        @source = "https://lohas.nicoseiga.jp/thumb/4937663i"
        @rewrite = %r{https://lohas.nicoseiga.jp/priv/\h{40}/\d+/4937663}
        assert_rewritten(@rewrite, @source)
        assert_downloaded(2_032, @source)
      end
    end
  end
end
