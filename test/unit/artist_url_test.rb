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

    context "when normalizing URLs" do
      should normalize_attribute(:url).from("example.com").to("http://example.com")
      should normalize_attribute(:url).from("http://example.com").to("http://example.com")
      should normalize_attribute(:url).from("https://example.com").to("https://example.com")
      should normalize_attribute(:url).from("http://example.com/").to("http://example.com")
      should normalize_attribute(:url).from("https://ArtistName.example.com").to("https://artistname.example.com")
      should normalize_attribute(:url).from("https://arca.live/u/@%EC%9C%BE%ED%8C%8C").to("https://arca.live/u/@윾파")
      should normalize_attribute(:url).from("http://dic.nicovideo.jp/a/tetla pot").to("http://dic.nicovideo.jp/a/tetla%20pot")
      should normalize_attribute(:url).from("https://www.digiket.com/abooks/result/_data/staff=%8F%BC%94C%92m%8A%EE").to("https://www.digiket.com/abooks/result/_data/staff=%8F%BC%94C%92m%8A%EE")
      should normalize_attribute(:url).from("https://arca.live/u/@ㅇㅇ/43979125").to("https://arca.live/u/@ㅇㅇ/43979125")
      should normalize_attribute(:url).from("https://artstation.com/koyorin").to("https://www.artstation.com/koyorin")
      should normalize_attribute(:url).from("https://koyorin.artstation.com").to("https://www.artstation.com/koyorin")
      should normalize_attribute(:url).from("https://www.artstation.com/artist/koyorin/albums/all/").to("https://www.artstation.com/koyorin")
      should normalize_attribute(:url).from("http://silencexs.blog106.fc2.com/").to("http://silencexs.blog.fc2.com")
      should normalize_attribute(:url).from("https://noizave.deviantart.com").to("https://www.deviantart.com/noizave")
      should normalize_attribute(:url).from("http://seiga.nicovideo.jp/user/illust/7017777").to("https://seiga.nicovideo.jp/user/illust/7017777")
      should normalize_attribute(:url).from("http://seiga.nicovideo.jp/manga/list?user_id=23839737").to("https://seiga.nicovideo.jp/manga/list?user_id=23839737")
      should normalize_attribute(:url).from("https://www.nicovideo.jp/user/20446930/mylist/28674289").to("https://www.nicovideo.jp/user/20446930")
      should normalize_attribute(:url).from("http://www.hentai-foundry.com/user/kajinman/profile").to("https://www.hentai-foundry.com/user/kajinman")
      should normalize_attribute(:url).from("http://www.pixiv.net/stacc/evazion/").to("https://www.pixiv.net/stacc/evazion")
      should normalize_attribute(:url).from("http://www.pixiv.net/fanbox/creator/3113804/post").to("https://www.pixiv.net/fanbox/creator/3113804")
      should normalize_attribute(:url).from("http://omu001.fanbox.cc/posts/39714").to("https://omu001.fanbox.cc")
      should normalize_attribute(:url).from("http://www.pixiv.net/en/users/123").to("https://www.pixiv.net/users/123")
      should normalize_attribute(:url).from("https://twitter.com/aoimanabu/status/892370963630743552").to("https://twitter.com/aoimanabu")
      should normalize_attribute(:url).from("https://twitter.com/BLAH").to("https://twitter.com/BLAH")
      should normalize_attribute(:url).from("https://twitter.com/intent/user?user_id=2784590030").to("https://twitter.com/intent/user?user_id=2784590030")
      should normalize_attribute(:url).from("http://twitpic.com/photos/mirakichi").to("http://twitpic.com/photos/mirakichi")
      should normalize_attribute(:url).from("https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png").to("https://nijie.info/members.php?id=236014")
      should normalize_attribute(:url).from("http://nijie.info/members.php?id=161703").to("https://nijie.info/members.php?id=161703")
      should normalize_attribute(:url).from("http://www.nijie.info/members_illust.php?id=161703").to("https://nijie.info/members.php?id=161703")
      should normalize_attribute(:url).from("http://nijie.info/invalid.php").to("http://nijie.info/invalid.php")
      should normalize_attribute(:url).from("http://www.pawoo.net/@evazion/19451018").to("https://pawoo.net/@evazion")
      should normalize_attribute(:url).from("http://www.pawoo.net/users/evazion/media").to("https://pawoo.net/@evazion")
      should normalize_attribute(:url).from("http://baraag.net/@curator/102270656480174153").to("https://baraag.net/@curator")
      should normalize_attribute(:url).from("http://instagram.com/itomugi").to("https://www.instagram.com/itomugi/")
      should normalize_attribute(:url).from("http://mesh-mesh.booth.pm/items/746971").to("https://mesh-mesh.booth.pm")
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

      should "work when searching for URLs containing backslashes" do
        @url = create(:artist_url, url: "https://twitter.com/foo\\\\bar")

        assert_search_equals([@url], url_matches: "foo\\\\bar")
      end
    end
  end
end
