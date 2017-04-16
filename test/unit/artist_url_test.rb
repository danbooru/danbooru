require 'test_helper'

class ArtistUrlTest < ActiveSupport::TestCase
  context "An artist url" do
    setup do
      CurrentUser.user = FactoryGirl.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "always add a trailing slash when normalized" do
      url = FactoryGirl.create(:artist_url, :url => "http://monet.com")
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)

      url = FactoryGirl.create(:artist_url, :url => "http://monet.com/")
      assert_equal("http://monet.com/", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
    end

    should "normalise https" do
      url = FactoryGirl.create(:artist_url, :url => "https://google.com")
      assert_equal("https://google.com", url.url)
      assert_equal("http://google.com/", url.normalized_url)
    end

    should "normalize fc2 urls" do
      url = FactoryGirl.create(:artist_url, :url => "http://blog55.fc2.com/monet")
      assert_equal("http://blog55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)

      url = FactoryGirl.create(:artist_url, :url => "http://blog-imgs-55.fc2.com/monet")
      assert_equal("http://blog-imgs-55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)
    end

    should "normalize nico seiga artist urls" do
      url = FactoryGirl.create(:artist_url, :url => "http://seiga.nicovideo.jp/user/illust/1826959")
      assert_equal("http://seiga.nicovideo.jp/user/illust/1826959", url.normalized_url)

      url = FactoryGirl.create(:artist_url, :url => "http://seiga.nicovideo.jp/seiga/im4937663")
      assert_equal("http://seiga.nicovideo.jp/user/illust/7017777/", url.normalized_url)
    end

    should "normalize hentai foundry artist urls" do
      url = FactoryGirl.create(:artist_url, :url => "http://pictures.hentai-foundry.com//a/AnimeFlux/219123.jpg")
      assert_equal("http://pictures.hentai-foundry.com/a/AnimeFlux/219123.jpg/", url.normalized_url)
    end

    should "normalize pixiv urls" do
      url = FactoryGirl.create(:artist_url, :url => "http://img55.pixiv.net/img/monet")
      assert_equal("http://img55.pixiv.net/img/monet", url.url)
      assert_equal("http://img.pixiv.net/img/monet/", url.normalized_url)
    end

    should "normalize twitter urls" do
      url = FactoryGirl.create(:artist_url, :url => "https://twitter.com/MONET/status/12345")
      assert_equal("https://twitter.com/MONET/status/12345", url.url)
      assert_equal("http://twitter.com/monet/status/12345/", url.normalized_url)
    end
  end
end
