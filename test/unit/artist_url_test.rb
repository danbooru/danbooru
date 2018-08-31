require 'test_helper'

class ArtistUrlTest < ActiveSupport::TestCase
  context "An artist url" do
    setup do
      CurrentUser.user = FactoryBot.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "allow urls to be marked as inactive" do
      url = FactoryBot.create(:artist_url, :url => "-http://monet.com")
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
      refute(url.is_active?)
    end

    should "always add a trailing slash when normalized" do
      url = FactoryBot.create(:artist_url, :url => "http://monet.com")
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)

      url = FactoryBot.create(:artist_url, :url => "http://monet.com/")
      assert_equal("http://monet.com/", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
    end

    should "normalise https" do
      url = FactoryBot.create(:artist_url, :url => "https://google.com")
      assert_equal("https://google.com", url.url)
      assert_equal("http://google.com/", url.normalized_url)
    end

    context "normalize twitter profile urls" do
      setup do
        @url = FactoryBot.create(:artist_url, :url => "https://twitter.com/BLAH")
      end

      should "downcase the url" do
        assert_equal("http://twitter.com/blah/", @url.normalized_url)
      end
    end

    context "artstation urls" do
      setup do
        @urls = [
          FactoryBot.create(:artist_url, url: "https://www.artstation.com/koyorin"),
          FactoryBot.create(:artist_url, url: "https://www.artstation.com/artist/koyorin"),
          FactoryBot.create(:artist_url, url: "https://koyorin.artstation.com"),
          FactoryBot.create(:artist_url, url: "https://www.artstation.com/artwork/04XA4")
        ]
      end

      should "normalize" do
        assert_equal("http://www.artstation.com/koyorin/", @urls[0].normalized_url)
        assert_equal("http://www.artstation.com/koyorin/", @urls[1].normalized_url)
        assert_equal("http://www.artstation.com/koyorin/", @urls[2].normalized_url)
        assert_equal("http://www.artstation.com/jeyrain/", @urls[3].normalized_url)
      end
    end

    context "deviantart urls" do
      setup do
        @urls = [
          FactoryBot.create(:artist_url, url: "https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484"),
          FactoryBot.create(:artist_url, url: "http://noizave.deviantart.com/art/test-post-please-ignore-685436408"),
          FactoryBot.create(:artist_url, url: "https://www.deviantart.com/noizave")
        ]
      end

      should "normalize" do
        assert_equal("http://www.deviantart.com/aeror404/", @urls[0].normalized_url)
        assert_equal("http://www.deviantart.com/noizave/", @urls[1].normalized_url)
        assert_equal("http://www.deviantart.com/noizave/", @urls[2].normalized_url)
      end
    end

    context "nicoseiga urls" do
      setup do
        @urls = [
          FactoryBot.create(:artist_url, url: "http://seiga.nicovideo.jp/user/illust/7017777"),
          FactoryBot.create(:artist_url, url: "http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663"),
          FactoryBot.create(:artist_url, url: "http://seiga.nicovideo.jp/seiga/im4937663")
        ]
      end

      should "normalize" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777/", @urls[0].normalized_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777/", @urls[1].normalized_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777/", @urls[2].normalized_url)
      end
    end

    should "normalize fc2 urls" do
      url = FactoryBot.create(:artist_url, :url => "http://blog55.fc2.com/monet")
      assert_equal("http://blog55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)

      url = FactoryBot.create(:artist_url, :url => "http://blog-imgs-55.fc2.com/monet")
      assert_equal("http://blog-imgs-55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)
    end

    should "normalize deviant art artist urls" do
      url = FactoryBot.create(:artist_url, :url => "https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484")
      assert_equal("http://www.deviantart.com/aeror404/", url.normalized_url)      
    end

    should "normalize nico seiga artist urls" do
      url = FactoryBot.create(:artist_url, :url => "http://seiga.nicovideo.jp/user/illust/7017777")
      assert_equal("http://seiga.nicovideo.jp/user/illust/7017777/", url.normalized_url)

      url = FactoryBot.create(:artist_url, :url => "http://seiga.nicovideo.jp/seiga/im4937663")
      assert_equal("http://seiga.nicovideo.jp/user/illust/7017777/", url.normalized_url)
    end

    should "normalize hentai foundry artist urls" do
      url = FactoryBot.create(:artist_url, :url => "http://pictures.hentai-foundry.com//a/AnimeFlux/219123.jpg")
      assert_equal("http://pictures.hentai-foundry.com/a/AnimeFlux/219123.jpg/", url.normalized_url)
    end

    should "normalize pixiv urls" do
      url = FactoryBot.create(:artist_url, :url => "https://i.pximg.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png")
      assert_equal("https://i.pximg.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png", url.url)
      assert_equal("http://www.pixiv.net/member.php?id=339253/", url.normalized_url)
    end

    should "normalize pixiv stacc urls" do
      url = FactoryBot.create(:artist_url, :url => "https://www.pixiv.net/stacc/evazion")
      assert_equal("https://www.pixiv.net/stacc/evazion", url.url)
      assert_equal("http://www.pixiv.net/stacc/evazion/", url.normalized_url)
    end

    should "normalize twitter urls" do
      url = FactoryBot.create(:artist_url, :url => "https://twitter.com/aoimanabu/status/892370963630743552")
      assert_equal("https://twitter.com/aoimanabu/status/892370963630743552", url.url)
      assert_equal("http://twitter.com/aoimanabu/", url.normalized_url)
    end
  end
end
