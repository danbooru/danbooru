require 'test_helper'

class ArtistUrlTest < ActiveSupport::TestCase
  def assert_search_equals(results, conditions)
    assert_equal(results.map(&:id), subject.search(conditions).map(&:id))
  end

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
      url = FactoryBot.create(:artist_url, url: "http://monet.com", is_active: false)
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
      assert_equal("-http://monet.com", url.to_s)
    end

    should "disallow invalid urls" do
      urls = [
        FactoryBot.build(:artist_url, url: "www.example.com"),
        FactoryBot.build(:artist_url, url: ":www.example.com"),
        FactoryBot.build(:artist_url, url: "http://http://www.example.com"),
      ]

      assert_equal(false, urls[0].valid?)
      assert_match(/must begin with http/, urls[0].errors.full_messages.join)
      assert_equal(false, urls[1].valid?)
      assert_match(/is malformed/, urls[1].errors.full_messages.join)
      assert_equal(false, urls[2].valid?)
      assert_match(/that does not contain a dot/, urls[2].errors.full_messages.join)
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

    should "normalise domains to lowercase" do
      url = FactoryBot.create(:artist_url, url: "https://ArtistName.example.com")
      assert_equal("http://artistname.example.com/", url.normalized_url)
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
          FactoryBot.create(:artist_url, url: "https://koyorin.artstation.com"),
          FactoryBot.create(:artist_url, url: "https://www.artstation.com/artwork/04XA4")
        ]
      end

      should "normalize" do
        assert_equal("http://www.artstation.com/koyorin/", @urls[0].normalized_url)
        assert_equal("http://www.artstation.com/koyorin/", @urls[1].normalized_url)
        assert_equal("http://www.artstation.com/jeyrain/", @urls[2].normalized_url)
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
      assert_equal("http://www.hentai-foundry.com/user/AnimeFlux/", url.normalized_url)
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

    should "normalize pixiv fanbox account urls" do
      url = FactoryBot.create(:artist_url, :url => "http://www.pixiv.net/fanbox/creator/3113804")
      assert_equal("http://www.pixiv.net/fanbox/creator/3113804", url.url)
      assert_equal("http://www.pixiv.net/fanbox/creator/3113804/", url.normalized_url)
    end

    should "normalize pixiv.net/user/123 urls" do
      url = create(:artist_url, url: "https://www.pixiv.net/en/users/123")
      assert_equal("https://www.pixiv.net/en/users/123", url.url)
      assert_equal("http://www.pixiv.net/member.php?id=123/", url.normalized_url)
    end

    should "normalize twitter urls" do
      url = FactoryBot.create(:artist_url, :url => "https://twitter.com/aoimanabu/status/892370963630743552")
      assert_equal("https://twitter.com/aoimanabu/status/892370963630743552", url.url)
      assert_equal("http://twitter.com/aoimanabu/", url.normalized_url)
    end

    should "normalize https://twitter.com/intent/user?user_id=* urls" do
      url = FactoryBot.create(:artist_url, :url => "https://twitter.com/intent/user?user_id=2784590030")
      assert_equal("https://twitter.com/intent/user?user_id=2784590030", url.url)
      assert_equal("http://twitter.com/intent/user?user_id=2784590030/", url.normalized_url)
    end

    should "normalize nijie urls" do
      url = FactoryBot.create(:artist_url, url: "https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png")
      assert_equal("http://nijie.info/members.php?id=236014/", url.normalized_url)

      url = FactoryBot.create(:artist_url, url: "https://nijie.info/members.php?id=161703")
      assert_equal("http://nijie.info/members.php?id=161703/", url.normalized_url)

      url = FactoryBot.create(:artist_url, url: "https://www.nijie.info/members_illust.php?id=161703")
      assert_equal("http://nijie.info/members.php?id=161703/", url.normalized_url)

      url = FactoryBot.create(:artist_url, url: "https://nijie.info/invalid.php")
      assert_equal("http://nijie.info/invalid.php/", url.normalized_url)
    end

    context "#search method" do
      subject { ArtistUrl }

      should "work" do
        @bkub = create(:artist, name: "bkub", is_deleted: false, url_string: "https://bkub.com")
        @masao = create(:artist, name: "masao", is_deleted: true, url_string: "-https://masao.com")
        @bkub_url = @bkub.urls.first
        @masao_url = @masao.urls.first

        assert_search_equals([@bkub_url], is_active: true)
        assert_search_equals([@bkub_url], artist: { name: "bkub" })

        assert_search_equals([@bkub_url], url_matches: "*bkub*")
        assert_search_equals([@bkub_url], url_matches: "/^https?://bkub\.com$/")

        assert_search_equals([@bkub_url], normalized_url_matches: "*bkub*")
        assert_search_equals([@bkub_url], normalized_url_matches: "/^https?://bkub\.com/$/")
        assert_search_equals([@bkub_url], normalized_url_matches: "https://bkub.com")

        assert_search_equals([@bkub_url], url: "https://bkub.com")
        assert_search_equals([@bkub_url], url_eq: "https://bkub.com")
        assert_search_equals([@bkub_url], url_not_eq: "https://masao.com")
        assert_search_equals([@bkub_url], url_like: "*bkub*")
        assert_search_equals([@bkub_url], url_ilike: "*BKUB*")
        assert_search_equals([@bkub_url], url_not_like: "*masao*")
        assert_search_equals([@bkub_url], url_not_ilike: "*MASAO*")
        assert_search_equals([@bkub_url], url_regex: "bkub")
        assert_search_equals([@bkub_url], url_not_regex: "masao")
      end
    end
  end
end
