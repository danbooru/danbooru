require 'test_helper'

class ArtistURLTest < ActiveSupport::TestCase
  context "An artist url" do
    setup do
      CurrentUser.user = FactoryBot.create(:user)
    end

    teardown do
      CurrentUser.user = nil
    end

    should "allow urls to be marked as inactive" do
      url = create(:artist_url, url: "http://monet.com", is_active: false)
      assert_equal("http://monet.com", url.url)
      assert_equal("-http://monet.com", url.to_s)
    end

    should "disallow invalid urls" do
      urls = [
        build(:artist_url, url: ":www.example.com"),
        build(:artist_url, url: "http://http://www.example.com"),
      ]

      assert_equal(false, urls[0].valid?)
      assert_match(/is malformed/, urls[0].errors.full_messages.join)
      assert_equal(false, urls[1].valid?)
      assert_match(/that does not contain a dot/, urls[1].errors.full_messages.join)
    end

    should "automatically add http:// if missing" do
      url = create(:artist_url, url: "example.com")
      assert_equal("http://example.com", url.url)
    end

    should "normalize trailing slashes" do
      url = create(:artist_url, url: "http://monet.com")
      assert_equal("http://monet.com", url.url)

      url = create(:artist_url, url: "http://monet.com/")
      assert_equal("http://monet.com", url.url)
    end

    should "normalise https" do
      url = create(:artist_url, url: "https://google.com")
      assert_equal("https://google.com", url.url)
    end

    should "normalise domains to lowercase" do
      url = create(:artist_url, url: "https://ArtistName.example.com")
      assert_equal("https://artistname.example.com", url.url)
    end

    should "decode encoded URLs" do
      url = create(:artist_url, url: "https://arca.live/u/@%EC%9C%BE%ED%8C%8C")
      assert_equal("https://arca.live/u/@윾파", url.url)
    end

    should "percent-encode spaces" do
      url = create(:artist_url, url: "http://dic.nicovideo.jp/a/tetla pot")
      assert_equal("http://dic.nicovideo.jp/a/tetla%20pot", url.url)
    end

    should "not fail when decoding percent-encoded Shift JIS URLs" do
      url = create(:artist_url, url: "https://www.digiket.com/abooks/result/_data/staff=%8F%BC%94C%92m%8A%EE")
      assert_equal("https://www.digiket.com/abooks/result/_data/staff=%8F%BC%94C%92m%8A%EE", url.url)
    end

    should "not apply NFKC normalization to URLs" do
      url = create(:artist_url, url: "https://arca.live/u/@ㅇㅇ/43979125")
      assert_equal("https://arca.live/u/@ㅇㅇ/43979125", url.url)
    end

    should "normalize ArtStation urls" do
      url = create(:artist_url, url: "https://artstation.com/koyorin")
      assert_equal("https://www.artstation.com/koyorin", url.url)

      url = create(:artist_url, url: "https://koyorin.artstation.com")
      assert_equal("https://www.artstation.com/koyorin", url.url)

      url = create(:artist_url, url: "https://www.artstation.com/artist/koyorin/albums/all/")
      assert_equal("https://www.artstation.com/koyorin", url.url)
    end

    should "normalize fc2 urls" do
      url = create(:artist_url, url: "http://silencexs.blog106.fc2.com/")

      assert_equal("http://silencexs.blog.fc2.com", url.url)
    end

    should "normalize deviant art artist urls" do
      url = create(:artist_url, url: "https://noizave.deviantart.com")

      assert_equal("https://www.deviantart.com/noizave", url.url)
    end

    should "normalize nico seiga artist urls" do
      url = create(:artist_url, url: "http://seiga.nicovideo.jp/user/illust/7017777")
      assert_equal("https://seiga.nicovideo.jp/user/illust/7017777", url.url)

      url = create(:artist_url, url: "http://seiga.nicovideo.jp/manga/list?user_id=23839737")
      assert_equal("https://seiga.nicovideo.jp/manga/list?user_id=23839737", url.url)

      url = create(:artist_url, url: "https://www.nicovideo.jp/user/20446930/mylist/28674289")
      assert_equal("https://www.nicovideo.jp/user/20446930", url.url)
    end

    should "normalize hentai foundry artist urls" do
      url = create(:artist_url, url: "http://www.hentai-foundry.com/user/kajinman/profile")

      assert_equal("https://www.hentai-foundry.com/user/kajinman", url.url)
    end

    should "normalize pixiv stacc urls" do
      url = create(:artist_url, url: "http://www.pixiv.net/stacc/evazion/")

      assert_equal("https://www.pixiv.net/stacc/evazion", url.url)
    end

    should "normalize pixiv fanbox account urls" do
      url = create(:artist_url, url: "http://www.pixiv.net/fanbox/creator/3113804/post")

      assert_equal("https://www.pixiv.net/fanbox/creator/3113804", url.url)

      url = create(:artist_url, url: "http://omu001.fanbox.cc/posts/39714")
      assert_equal("https://omu001.fanbox.cc", url.url)
    end

    should "normalize pixiv.net/user/123 urls" do
      url = create(:artist_url, url: "http://www.pixiv.net/en/users/123")

      assert_equal("https://www.pixiv.net/users/123", url.url)
    end

    should "normalize twitter urls" do
      url = create(:artist_url, url: "https://twitter.com/aoimanabu/status/892370963630743552")
      assert_equal("https://twitter.com/aoimanabu", url.url)

      url = create(:artist_url, url: "https://twitter.com/BLAH")
      assert_equal("https://twitter.com/BLAH", url.url)
    end

    should "normalize https://twitter.com/intent/user?user_id=* urls" do
      url = create(:artist_url, url: "https://twitter.com/intent/user?user_id=2784590030")

      assert_equal("https://twitter.com/intent/user?user_id=2784590030", url.url)
    end

    should "normalize twitpic urls" do
      url = create(:artist_url, url: "http://twitpic.com/photos/mirakichi")
      assert_equal("http://twitpic.com/photos/mirakichi", url.url)
    end

    should "normalize nijie urls" do
      url = create(:artist_url, url: "https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png")
      assert_equal("https://nijie.info/members.php?id=236014", url.url)

      url = create(:artist_url, url: "http://nijie.info/members.php?id=161703")
      assert_equal("https://nijie.info/members.php?id=161703", url.url)

      url = create(:artist_url, url: "http://www.nijie.info/members_illust.php?id=161703")
      assert_equal("https://nijie.info/members.php?id=161703", url.url)

      url = create(:artist_url, url: "http://nijie.info/invalid.php")
      assert_equal("http://nijie.info/invalid.php", url.url)
    end

    should "normalize pawoo.net urls" do
      url = create(:artist_url, url: "http://www.pawoo.net/@evazion/19451018")
      assert_equal("https://pawoo.net/@evazion", url.url)

      url = create(:artist_url, url: "http://www.pawoo.net/users/evazion/media")
      assert_equal("https://pawoo.net/@evazion", url.url)
    end

    should "normalize baraag.net urls" do
      url = create(:artist_url, url: "http://baraag.net/@curator/102270656480174153")
      assert_equal("https://baraag.net/@curator", url.url)
    end

    should "normalize Instagram urls" do
      url = create(:artist_url, url: "http://instagram.com/itomugi")
      assert_equal("https://www.instagram.com/itomugi/", url.url)
    end

    should "normalize Booth.pm urls" do
      url = create(:artist_url, url: "http://mesh-mesh.booth.pm/items/746971")
      assert_equal("https://mesh-mesh.booth.pm", url.url)
    end

    context "#search method" do
      should "work" do
        @bkub = create(:artist, name: "bkub", is_deleted: false, url_string: "https://bkub.com")
        @masao = create(:artist, name: "masao", is_deleted: true, url_string: "-https://masao.com")
        @bkub_url = @bkub.urls.first
        @masao_url = @masao.urls.first

        assert_search_equals([@bkub_url], is_active: true)
        assert_search_equals([@bkub_url], artist: { name: "bkub" })

        assert_search_equals([@bkub_url], url_matches: "*bkub*")
        assert_search_equals([@bkub_url], url_matches: "/^https?://bkub\.com$/")
        assert_search_equals([@bkub_url], url_matches: "https://bkub.com")
        assert_search_equals([@bkub_url], url_matches: "http://bkub.com")
        assert_search_equals([@bkub_url], url_matches: "http://bkub.com/")
        assert_search_equals([@bkub_url], url_matches: "http://BKUB.com/")
        assert_search_equals([@masao_url, @bkub_url], url_matches: "https://bkub.com https://masao.com")
        assert_search_equals([@masao_url, @bkub_url], url_matches: ["https://bkub.com", "https://masao.com"])

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
