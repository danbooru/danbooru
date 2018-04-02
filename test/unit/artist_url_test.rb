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

    should "normalize fc2 urls" do
      url = FactoryBot.create(:artist_url, :url => "http://blog55.fc2.com/monet")
      assert_equal("http://blog55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)

      url = FactoryBot.create(:artist_url, :url => "http://blog-imgs-55.fc2.com/monet")
      assert_equal("http://blog-imgs-55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)
    end

    should "normalize nico seiga artist urls" do
      url = FactoryBot.create(:artist_url, :url => "http://seiga.nicovideo.jp/user/illust/1826959")
      assert_equal("http://seiga.nicovideo.jp/user/illust/1826959/", url.normalized_url)

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

    should "normalize twitter urls" do
      url = FactoryBot.create(:artist_url, :url => "https://twitter.com/MONET/status/12345")
      assert_equal("https://twitter.com/MONET/status/12345", url.url)
      assert_equal("http://twitter.com/monet/status/12345/", url.normalized_url)
    end
  end
end
