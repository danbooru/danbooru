require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  def assert_artist_found(expected_name, source_url)
    artists = Artist.search({ url_matches: source_url }, current_user: User.anonymous).to_a

    assert_equal(1, artists.size)
    assert_equal(expected_name, artists.first.name, "Testing URL: #{source_url}")
  end

  def assert_artist_not_found(source_url)
    artists = Artist.search({ url_matches: source_url }, current_user: User.anonymous).to_a
    assert_equal(0, artists.size, "Testing URL: #{source_url}")
  end

  context "An artist" do
    setup do
      user = travel_to(1.month.ago) {FactoryBot.create(:user)}
      CurrentUser.user = user
    end

    teardown do
      CurrentUser.user = nil
    end

    should "parse inactive urls" do
      @artist = create(:artist, name: "blah", url_string: "-http://monet.com")
      assert_equal(["-http://monet.com"], @artist.urls.map(&:to_s))
      refute(@artist.urls[0].is_active?)
    end

    should "not allow duplicate active+inactive urls" do
      @artist = create(:artist, name: "blah", url_string: "-http://monet.com\nhttp://monet.com")
      assert_equal(1, @artist.urls.count)
      assert_equal(["-http://monet.com"], @artist.urls.map(&:to_s))
      refute(@artist.urls[0].is_active?)
    end

    should "allow deactivating a url" do
      @artist = create(:artist, name: "blah", url_string: "http://monet.com")
      @artist.update(url_string: "-http://monet.com")
      assert_equal(1, @artist.urls.count)
      refute(@artist.urls[0].is_active?)
    end

    should "allow activating a url" do
      @artist = create(:artist, name: "blah", url_string: "-http://monet.com")
      @artist.update(url_string: "http://monet.com")
      assert_equal(1, @artist.urls.count)
      assert(@artist.urls[0].is_active?)
    end

    context "with an invalid name" do
      subject { FactoryBot.build(:artist) }

      should_not allow_value("-blah").for(:name)
      should_not allow_value("_").for(:name)
      should_not allow_value("").for(:name)
    end

    context "that has been banned" do
      setup do
        @artist = FactoryBot.create(:artist, :name => "aaa")
        @post = FactoryBot.create(:post, :tag_string => "aaa")
        @admin = FactoryBot.create(:admin_user)
        @artist.ban!(@admin)
        perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob)
        @post.reload
      end

      should "allow unbanning" do
        assert_equal(true, @artist.reload.is_banned?)
        assert_equal(true, @post.reload.is_banned?)
        assert_equal(true, @artist.versions.last.is_banned?)
        assert_equal(true, TagImplication.active.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))

        @artist.unban!(@admin)

        assert_equal(false, @artist.reload.is_banned?)
        assert_equal(false, @post.reload.is_banned?)
        assert_equal(false, @artist.versions.last.is_banned?)
        assert_equal("aaa", @post.tag_string)
        assert_equal(false, TagImplication.active.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))
        assert_equal(true, TagImplication.deleted.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))
        assert_equal(true, ModAction.artist_unban.exists?(subject: @artist))
      end

      should "ban the post" do
        assert(@post.is_banned?)
      end

      should "not delete the post" do
        refute(@post.is_deleted?)
      end

      should "create a new tag implication" do
        assert_equal(1, TagImplication.where(:antecedent_name => "aaa", :consequent_name => "banned_artist").count)
        assert_equal("aaa banned_artist", @post.reload.tag_string)
      end

      should "create the banned_artist tag if it doesn't already exist" do
        assert_equal(true, Tag.exists?(name: "banned_artist", category: Tag.categories.artist))
      end

      should "set the approver of the banned_artist implication" do
        ta = TagImplication.where(:antecedent_name => "aaa", :consequent_name => "banned_artist").first
        assert_equal(@admin.id, ta.approver.id)
      end

      should "update the artist history" do
        assert_equal(true, @artist.reload.is_banned?)
        assert_equal(true, @artist.versions.last.is_banned?)
      end

      should "tag the posts" do
        assert_equal(true, @post.reload.is_banned?)
        assert_equal(true, @post.has_tag?("banned_artist"))
      end

      should "create a mod action" do
        assert_equal(true, ModAction.artist_ban.exists?(subject: @artist))
      end
    end

    should "normalize its name" do
      artist = FactoryBot.create(:artist, :name => "  AAA BBB  ")
      assert_equal("aaa_bbb", artist.name)
    end

    should "resolve ambiguous urls" do
      bobross = FactoryBot.create(:artist, :name => "bob_ross", :url_string => "http://artists.com/bobross/image.jpg")
      bob = FactoryBot.create(:artist, :name => "bob", :url_string => "http://artists.com/bob/image.jpg")
      assert_artist_found("bob", "http://artists.com/bob/test.jpg")
    end

    should "parse urls" do
      artist = FactoryBot.create(:artist, :name => "rembrandt", :url_string => "http://rembrandt.com/test.jpg http://aaa.com")
      artist.reload
      assert_equal(["http://aaa.com", "http://rembrandt.com/test.jpg"], artist.urls.map(&:to_s).sort)
    end

    should "not allow invalid urls" do
      artist = FactoryBot.build(:artist, :url_string => "blah")
      assert_equal(false, artist.valid?)
      assert_includes(artist.errors["urls.url"], "'blah' must begin with http:// or https:// ")
      assert_includes(artist.errors["urls.url"], "'blah' has a hostname '' that does not contain a dot")
    end

    should "allow fixing invalid urls" do
      artist = FactoryBot.build(:artist)
      artist.urls << FactoryBot.build(:artist_url, url: "www.example.com")
      artist.save(validate: false)

      artist.update(url_string: "http://www.example.com")
      assert_equal(true, artist.valid?)
      assert_equal("http://www.example.com", artist.urls.map(&:to_s).join)
    end

    should "make sure old urls are deleted" do
      artist = FactoryBot.create(:artist, :name => "rembrandt", :url_string => "http://rembrandt.com/test.jpg")
      artist.url_string = "http://not.rembrandt.com/test.jpg"
      artist.save
      artist.reload
      assert_equal(["http://not.rembrandt.com/test.jpg"], artist.urls.map(&:to_s).sort)
    end

    should "not delete urls that have not changed" do
      artist = FactoryBot.create(:artist, :name => "rembrandt", :url_string => "http://rembrandt.com/test.jpg")
      old_url_ids = ArtistURL.order("id").pluck(&:id)
      artist.url_string = "http://rembrandt.com/test.jpg"
      artist.save
      assert_equal(old_url_ids, ArtistURL.order("id").pluck(&:id))
    end

    should "normalize urls before removing duplicates" do
      @artist = create(:artist, url_string: "https://Twitter.com/o8q https://twitter.com/o8q")

      assert_equal(1, @artist.urls.count)
      assert_equal(["https://twitter.com/o8q"], @artist.urls.map(&:to_s))
    end

    should "ignore pixiv.net/ and pixiv.net/img/ url matches" do
      a1 = FactoryBot.create(:artist, :name => "yomosaka", :url_string => "http://i2.pixiv.net/img18/img/evazion/14901720.png")
      a2 = FactoryBot.create(:artist, :name => "niwatazumi_bf", :url_string => "http://i2.pixiv.net/img18/img/evazion/14901720_big_p0.png")
      assert_artist_not_found("http://i2.pixiv.net/img28/img/kyang692/35563903.jpg")
    end

    should "ignore /en/ pixiv url matches" do
      a1 = FactoryBot.create(:artist, :name => "vvv", :url_string => "https://www.pixiv.net/en/users/32072927/artworks")
      a2 = FactoryBot.create(:artist, :name => "c01a", :url_string => "https://www.pixiv.net/en/users/31744504")
      assert_artist_not_found("https://www.pixiv.net/en/artworks/85241178")
      assert_artist_not_found("https://www.pixiv.net/en/users/85241178")
    end

    should "find matches by url" do
      a1 = FactoryBot.create(:artist, :name => "rembrandt", :url_string => "http://rembrandt.com/x/test.jpg")
      a2 = FactoryBot.create(:artist, :name => "subway", :url_string => "http://subway.com/x/test.jpg")
      a3 = FactoryBot.create(:artist, :name => "minko", :url_string => "https://minko.com/x/test.jpg")

      assert_artist_found("rembrandt", "http://rembrandt.com/x/test.jpg")
      assert_artist_found("rembrandt", "http://rembrandt.com/x/another.jpg")
      assert_artist_not_found("http://nonexistent.com/test.jpg")
      assert_artist_found("minko", "https://minko.com/x/test.jpg")
      assert_artist_found("minko", "http://minko.com/x/test.jpg")
    end

    should "be case-insensitive to domains when finding matches by url" do
      a1 = FactoryBot.create(:artist, name: "bkub", url_string: "http://BKUB.example.com")
      assert_artist_found(a1.name, "http://bkub.example.com")
    end

    should "not find duplicates" do
      FactoryBot.create(:artist, :name => "warhol", :url_string => "http://warhol.com/x/a/image.jpg\nhttp://warhol.com/x/b/image.jpg")
      assert_artist_found("warhol", "http://warhol.com/x/test.jpg")
    end

    should "not return duplicates if too many artists found" do
      create_list(:artist, 5, url_string: "https://www.example.com")
      assert_artist_not_found("https://www.example.com/image.jpg")
    end

    should "not include duplicate urls" do
      artist = FactoryBot.create(:artist, :url_string => "http://foo.com http://foo.com")
      assert_equal(["http://foo.com"], artist.url_array)
    end

    should "hide deleted artists" do
      create(:artist, name: "warhol", url_string: "http://warhol.com/a/image.jpg", is_deleted: true)
      assert_artist_not_found("http://warhol.com/a/image.jpg")
    end

    context "when finding deviantart artists" do
      setup do
        skip "DeviantArt API keys not set" unless Danbooru.config.deviantart_client_id.present?
        FactoryBot.create(:artist, :name => "artgerm", :url_string => "http://artgerm.deviantart.com/")
        FactoryBot.create(:artist, :name => "trixia",  :url_string => "http://trixdraws.deviantart.com/")
      end

      should "find the correct artist for page URLs" do
        assert_artist_found("artgerm", "http://www.deviantart.com/artgerm/art/Peachy-Princess-Ver-2-457220550")
        assert_artist_found("trixia", "http://www.deviantart.com/trixdraws/art/My-Queen-426745289")
      end

      should "find the correct artist for image URLs" do
        assert_artist_found("artgerm", "http://th05.deviantart.net/fs71/200H/f/2014/150/d/c/peachy_princess_by_artgerm-d7k7tmu.jpg")
        assert_artist_found("artgerm", "http://th05.deviantart.net/fs71/PRE/f/2014/150/d/c/peachy_princess_by_artgerm-d7k7tmu.jpg")
        assert_artist_found("artgerm", "http://fc06.deviantart.net/fs71/f/2014/150/d/c/peachy_princess_by_artgerm-d7k7tmu.jpg")

        assert_artist_found("trixia", "http://fc01.deviantart.net/fs71/i/2014/050/d/e/my_queen_by_trixdraws-d722mrt.jpg")
        assert_artist_found("trixia", "http://th01.deviantart.net/fs71/200H/i/2014/050/d/e/my_queen_by_trixdraws-d722mrt.jpg")
        assert_artist_found("trixia", "http://th09.deviantart.net/fs71/PRE/i/2014/050/d/e/my_queen_by_trixdraws-d722mrt.jpg")
      end
    end

    context "when finding pixiv artists" do
      setup do
        FactoryBot.create(:artist, :name => "masao", :url_string => "http://www.pixiv.net/member.php?id=32777")
        FactoryBot.create(:artist, :name => "bkub", :url_string => "http://www.pixiv.net/member.php?id=9948")
        FactoryBot.create(:artist, :name => "ryuura", :url_string => "http://www.pixiv.net/member.php?id=8678371")
      end

      should "find the correct artist by looking up the profile url" do
        assert_artist_found("ryuura", "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=48788677")
      end

      should "find the correct artist for old image URLs" do
        assert_artist_found("masao", "http://i2.pixiv.net/img04/img/syounen_no_uta/46170939.jpg")
        assert_artist_found("bkub",  "http://i1.pixiv.net/img01/img/bkubb/46239857_m.jpg")
      end

      should "find the correct artist for new image URLs" do
        assert_artist_found("masao", "http://i2.pixiv.net/c/1200x1200/img-master/img/2014/09/25/00/57/24/46170939_p0_master1200.jpg")
        assert_artist_found("masao", "http://i2.pixiv.net/img-original/img/2014/09/25/00/57/24/46170939_p0.jpg")

        assert_artist_found("bkub",  "http://i2.pixiv.net/c/1200x1200/img-master/img/2014/09/28/21/59/44/46239857_p0.jpg")
        assert_artist_found("bkub",  "http://i2.pixiv.net/img-original/img/2014/09/28/21/59/44/46239857_p0.jpg")
      end

      should "find the correct artist for page URLs" do
        assert_artist_found("masao", "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939")
        assert_artist_found("masao", "http://www.pixiv.net/member_illust.php?mode=big&illust_id=46170939")
        assert_artist_found("masao", "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=46170939")
        assert_artist_found("masao", "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46170939&page=0")
        assert_artist_found("masao", "http://www.pixiv.net/i/46170939")

        assert_artist_found("bkub",  "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46239857")
        assert_artist_found("bkub",  "http://www.pixiv.net/member_illust.php?mode=big&illust_id=46239857")
        assert_artist_found("bkub",  "http://www.pixiv.net/i/46239857")
      end

      should "find nothing for bad IDs" do
        assert_artist_not_found("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=32049358")
      end
    end

    context "when finding nico seiga artists" do
      setup do
        FactoryBot.create(:artist, :name => "osamari", :url_string => "http://seiga.nicovideo.jp/user/illust/7017777")
        FactoryBot.create(:artist, :name => "hakuro109", :url_string => "http://seiga.nicovideo.jp/user/illust/16265470")
      end

      should "find the artist by the profile" do
        assert_artist_found("osamari", "http://seiga.nicovideo.jp/seiga/im4937663")
        assert_artist_found("hakuro109", "http://lohas.nicoseiga.jp/priv/b9ea863e691f3a648dee5582fd6911c30dc8acab/1510092103/6424205")
      end

      should "return nothing for unknown nico seiga artists" do
        assert_artist_not_found("http://seiga.nicovideo.jp/seiga/im6605221")
        assert_artist_not_found("http://lohas.nicoseiga.jp/priv/fd195b3405b19874c825eb4d81c9196086562c6b/1509089019/6605221")
      end
    end

    context "when finding twitter artists" do
      setup do
        FactoryBot.create(:artist, :name => "hammer_(sunset_beach)", :url_string => "http://twitter.com/hamaororon")
        FactoryBot.create(:artist, :name => "haruyama_kazunori", :url_string => "https://twitter.com/kazuharoom")
      end

      should "find the correct artist for twitter.com sources" do
        assert_artist_found("hammer_(sunset_beach)", "http://twitter.com/hamaororon/status/684338785744637952")
        assert_artist_found("hammer_(sunset_beach)", "https://twitter.com/hamaororon/status/684338785744637952")

        assert_artist_found("haruyama_kazunori", "http://twitter.com/kazuharoom/status/733355069966426113")
        assert_artist_found("haruyama_kazunori", "https://twitter.com/kazuharoom/status/733355069966426113")
      end

      should "find the correct artist for mobile.twitter.com sources" do
        assert_artist_found("hammer_(sunset_beach)", "http://mobile.twitter.com/hamaororon/status/684338785744637952")
        assert_artist_found("hammer_(sunset_beach)", "https://mobile.twitter.com/hamaororon/status/684338785744637952")

        assert_artist_found("haruyama_kazunori", "http://mobile.twitter.com/kazuharoom/status/733355069966426113")
        assert_artist_found("haruyama_kazunori", "https://mobile.twitter.com/kazuharoom/status/733355069966426113")
      end

      should "return nothing for unknown twitter.com sources" do
        assert_artist_not_found("http://twitter.com/bkub_comic/status/782880825700343808")
        assert_artist_not_found("https://twitter.com/bkub_comic/status/782880825700343808")
      end

      should "return nothing for unknown mobile.twitter.com sources" do
        assert_artist_not_found("http://mobile.twitter.com/bkub_comic/status/782880825700343808")
        assert_artist_not_found("https://mobile.twitter.com/bkub_comic/status/782880825700343808")
      end
    end

    context "when finding pawoo artists" do
      setup do
        skip "Pawoo keys not set" unless Danbooru.config.pawoo_access_token
        FactoryBot.create(:artist, :name => "evazion", :url_string => "https://pawoo.net/@evazion")
        FactoryBot.create(:artist, :name => "yasumo01", :url_string => "https://pawoo.net/web/accounts/28816")
      end

      should "find the artist" do
        assert_artist_found("evazion", "https://pawoo.net/@evazion/19451018")
        assert_artist_found("evazion", "https://pawoo.net/web/statuses/19451018")
      end

      should_eventually "find artists by account id" do
        assert_artist_found("yasumo01", "https://pawoo.net/@yasumo01/222337")
        assert_artist_found("yasumo01", "https://pawoo.net/web/statuses/222337")
      end

      should "return nothing for unknown pawoo sources" do
        assert_artist_not_found("https://pawoo.net/@9ed00e924818/1202176")
        assert_artist_not_found("https://pawoo.net/web/statuses/1202176")
      end
    end

    context "when finding nijie artists" do
      setup do
        FactoryBot.create(:artist, :name => "evazion", :url_string => "http://nijie.info/members.php?id=236014")
        FactoryBot.create(:artist, :name => "728995",  :url_string => "http://nijie.info/members.php?id=728995")
      end

      should "find the artist" do
        skip "Nijie credentials not configured" unless Source::Extractor::Nijie.enabled?
        assert_artist_found("evazion", "http://nijie.info/view.php?id=218944")
        assert_artist_found("728995",  "http://nijie.info/view.php?id=213043")
      end

      should "return nothing for unknown nijie artists" do
        assert_artist_not_found("http://nijie.info/view.php?id=157953")
      end
    end

    context "when finding tumblr artists" do
      setup do
        FactoryBot.create(:artist, :name => "ilya_kuvshinov", :url_string => "http://kuvshinov-ilya.tumblr.com")
        FactoryBot.create(:artist, :name => "j.k.", :url_string => "https://jdotkdot5.tumblr.com")
      end

      should "find the artist" do
        assert_artist_found("ilya_kuvshinov", "http://kuvshinov-ilya.tumblr.com/post/168641755845")
        assert_artist_found("j.k.", "https://jdotkdot5.tumblr.com/post/168276640697")
      end

      should "return nothing for unknown tumblr artists" do
        assert_artist_not_found("https://peptosis.tumblr.com/post/168162082005")
      end
    end

    context "when finding fc2.com artists" do
      setup do
        create(:artist, name: "awa", url_string: "http://abk00.blog.fc2.com")
      end

      should "find the artist" do
        assert_artist_found("awa", "http://blog71.fc2.com/a/abk00/file/20080220194219.jpg")
        assert_artist_found("awa", "http://blog-imgs-71.fc2.com/a/b/k/abk00/20080220194219.jpg")
        assert_artist_found("awa", "http://abk00.blog71.fc2.com/file/20080220194219.jpg")
      end

      should "return nothing for an unknown artist" do
        assert_artist_not_found("http://blog71.fc2.com/a/nobody/file/20080220194219.jpg")
      end
    end

    context "when finding Newgrounds artists" do
      should "find the correct artist" do
        create(:artist, name: "lasterk", url_string: "http://lasterk.newgrounds.com")
        create(:artist, name: "merunyaa",  url_string: "https://merunyaa.newgrounds.com")

        assert_artist_found("lasterk", "https://www.newgrounds.com/art/view/lasterk/booette")
        assert_artist_not_found("https://www.newgrounds.com/dump/item/a1f417d20f5eaef31e26ac3c4956b3d4")
      end
    end

    context "the #normalize_other_names method" do
      subject { build(:artist) }

      should normalize_attribute(:other_names).from(["   foo"]).to(["foo"])
      should normalize_attribute(:other_names).from(["foo   "]).to(["foo"])
      should normalize_attribute(:other_names).from(["___foo"]).to(["___foo"])
      should normalize_attribute(:other_names).from(["foo___"]).to(["foo___"])
      should normalize_attribute(:other_names).from(["foo\n"]).to(["foo"])
      should normalize_attribute(:other_names).from(["foo bar"]).to(["foo_bar"])
      should normalize_attribute(:other_names).from(["foo   bar"]).to(["foo_bar"])
      should normalize_attribute(:other_names).from(["foo___bar"]).to(["foo___bar"])
      should normalize_attribute(:other_names).from([" _Foo Bar_ "]).to(["_Foo_Bar_"])
      should normalize_attribute(:other_names).from(["foo 1", "bar 2"]).to(["foo_1", "bar_2"])
      should normalize_attribute(:other_names).from(["foo", nil, "", " ", "bar"]).to(["foo", "bar"])
      should normalize_attribute(:other_names).from([nil, "", " "]).to([])
      should normalize_attribute(:other_names).from(["pokémon".unicode_normalize(:nfd)]).to(["pokémon".unicode_normalize(:nfkc)])
      should normalize_attribute(:other_names).from(["foo", "foo"]).to(["foo"])
      should normalize_attribute(:other_names).from(["🏳️‍🌈"]).to(["🏳️‍🌈"])

      should normalize_attribute(:other_names).from("foo foo").to(["foo"])
      should normalize_attribute(:other_names).from("foo bar").to(["foo", "bar"])
      should normalize_attribute(:other_names).from("_foo_ Bar").to(["_foo_", "Bar"])
    end

    context "group name" do
      should normalize_attribute(:group_name).from("   ").to("")
      should normalize_attribute(:group_name).from("   foo").to("foo")
      should normalize_attribute(:group_name).from("foo   ").to("foo")
      should normalize_attribute(:group_name).from("___foo").to("___foo")
      should normalize_attribute(:group_name).from("foo___").to("foo___")
      should normalize_attribute(:group_name).from("foo\n").to("foo")
      should normalize_attribute(:group_name).from("foo bar").to("foo_bar")
      should normalize_attribute(:group_name).from("foo   bar").to("foo_bar")
      should normalize_attribute(:group_name).from("foo___bar").to("foo___bar")
      should normalize_attribute(:group_name).from(" _Foo Bar_ ").to("_Foo_Bar_")
      should normalize_attribute(:group_name).from("_foo_ Bar").to("_foo__Bar")
      should normalize_attribute(:group_name).from("pokémon".unicode_normalize(:nfd)).to("pokémon".unicode_normalize(:nfkc))
      should normalize_attribute(:group_name).from("🏳️‍🌈").to("🏳️‍🌈")
    end

    should "search on its name should return results" do
      artist1 = create(:artist, name: "artist")
      artist2 = create(:artist, name: "bkub")

      assert_search_equals(artist1, name: "artist")
      assert_search_equals(artist1, name_like: "artist")
      assert_search_equals(artist1, any_name_matches: "artist")
      assert_search_equals(artist1, any_name_matches: "/art/")
    end

    should "search on other names should return matches" do
      artist = create(:artist, name: "artist", other_names_string: "aaa ccc_ddd")

      assert_search_equals([], any_other_name_like: "*artist*")
      assert_search_equals(artist, any_other_name_like: "*aaa*")
      assert_search_equals(artist, any_other_name_like: "*ccc_ddd*")
      assert_search_equals(artist, name: "artist")
      assert_search_equals(artist, any_name_matches: "aaa")
      assert_search_equals(artist, any_name_matches: "/a/")
    end

    should "search on group name and return matches" do
      cat_or_fish = create(:artist, name: "cat_or_fish")
      yuu = create(:artist, name: "yuu", group_name: "cat_or_fish")

      assert_search_equals(yuu, group_name: "cat_or_fish")
      assert_search_equals([yuu, cat_or_fish], any_name_matches: "cat_or_fish")
      assert_search_equals([yuu, cat_or_fish], any_name_matches: "/cat/")
    end

    should "search case-insensitively on any_name_matches" do
      artist = create(:artist, name: "foo", other_names: ["BAR"])

      assert_search_equals(artist, any_name_matches: "FOO")
      assert_search_equals(artist, any_name_matches: "bar")
    end

    should "search on url and return matches" do
      bkub = create(:artist, name: "bkub", url_string: "http://bkub.com")

      assert_search_equals(bkub, url_matches: "bkub")
      assert_search_equals(bkub, url_matches: "*bkub*")
      assert_search_equals(bkub, url_matches: "/rifyu|bkub/")
      assert_search_equals(bkub, url_matches: "http://bkub.com/test.jpg")
      assert_search_equals(bkub, url_matches: "http://bkub.com/test.jpg https://www.pixiv.net/users/9948")
    end

    should "search on has_tag and return matches" do
      bkub = create(:artist, name: "bkub")
      none = create(:artist, name: "none")
      post = create(:post, tag_string: "bkub")

      assert_search_equals(bkub, has_tag: "true")
      assert_search_equals(none, has_tag: "false")
    end

    should "revert to prior versions" do
      user = FactoryBot.create(:user)
      reverter = FactoryBot.create(:user)
      artist = nil
      assert_difference("ArtistVersion.count") do
        artist = FactoryBot.create(:artist, :other_names => "yyy")
      end

      assert_difference("ArtistVersion.count") do
        artist.other_names = "xxx"
        travel(1.day) do
          artist.save
        end
      end

      first_version = ArtistVersion.first
      assert_equal(%w[yyy], first_version.other_names)
      artist.revert_to!(first_version)
      artist.reload
      assert_equal(%w[yyy], artist.other_names)
    end

    context "when creating" do
      should "create a new artist tag if one does not already exist" do
        FactoryBot.create(:artist, name: "bkub")
        assert(Tag.exists?(name: "bkub", category: Tag.categories.artist))
      end

      should "change the tag to an artist tag if it was an empty gentag" do
        tag = FactoryBot.create(:tag, name: "abc", category: Tag.categories.general, post_count: 0)
        artist = FactoryBot.create(:artist, name: "abc")

        assert_equal(Tag.categories.artist, tag.reload.category)
      end

      should "not allow creating artist entries for non-artist tags" do
        tag = FactoryBot.create(:tag, name: "touhou", category: Tag.categories.copyright)
        artist = FactoryBot.build(:artist, name: "touhou")

        assert(artist.invalid?)
        assert_match(/'touhou' is a copyright tag/, artist.errors.full_messages.join)
      end

      should "not allow creating artist entries for aliased tags" do
        tag_alias = create(:tag_alias, antecedent_name: "foo", consequent_name: "bar")
        artist = build(:artist, name: "foo")

        assert_equal(true, artist.invalid?)
        assert_match(/'foo' is aliased to 'bar'/, artist.errors.full_messages.join)
      end

      should "not allow creating artist entries for deprecated tags" do
        create(:tag, name: "orange", is_deprecated: true)
        artist = build(:artist, name: "orange")

        assert_equal(true, artist.invalid?)
        assert_match(/'orange' is an ambiguous tag/, artist.errors.full_messages.join)
      end
    end

    context "when renaming" do
      should "change the new tag to an artist tag if it was a gentag" do
        tag = FactoryBot.create(:tag, name: "def", category: Tag.categories.general, post_count: 0)
        artist = FactoryBot.create(:artist, name: "abc")
        artist.update(name: "def")

        assert_equal(Tag.categories.artist, tag.reload.category)
      end
    end

    context "when saving" do
      setup do
        @artist = FactoryBot.create(:artist, url_string: "http://foo.com")
        @artist.stubs(:merge_version?).returns(false)
      end

      should "create a new version when an url is added" do
        assert_difference("ArtistVersion.count") do
          @artist.update(:url_string => "http://foo.com http://bar.com")
          assert_equal(%w[http://bar.com http://foo.com], @artist.versions.last.urls)
        end
      end

      should "create a new version when an url is removed" do
        assert_difference("ArtistVersion.count") do
          @artist.update(:url_string => "")
          assert_equal(%w[], @artist.versions.last.urls)
        end
      end

      should "create a new version when an url is marked inactive" do
        assert_difference("ArtistVersion.count") do
          @artist.update(:url_string => "-http://foo.com")
          assert_equal(%w[-http://foo.com], @artist.versions.last.urls)
        end
      end

      should "not create a new version when nothing has changed" do
        assert_no_difference("ArtistVersion.count") do
          @artist.save
          assert_equal(%w[http://foo.com], @artist.versions.last.urls)
        end
      end

      should "not save invalid urls" do
        assert_no_difference("ArtistVersion.count") do
          @artist.update(url_string: "http://foo.com :42")

          assert_equal(%w[http://foo.com], @artist.versions.last.urls)
        end
      end
    end

    context "that is deleted" do
      setup do
        @artist = create(:artist, url_string: "https://google.com")
        @artist.update_attribute(:is_deleted, true)
        @artist.reload
      end

      should "preserve the url string" do
        assert_equal(1, @artist.urls.count)
      end
    end

    context "#new_with_defaults" do
      should "fetch the defaults from the given source" do
        source = "https://i.pximg.net/img-original/img/2018/01/28/23/56/50/67014762_p0.jpg"
        artist = Artist.new_with_defaults(source: source)

        assert_equal("niceandcool", artist.name)
        assert_equal("Nice_and_Cool niceandcool", artist.other_names_string)
        assert_includes(artist.urls.map(&:url), "https://www.pixiv.net/users/906442")
        assert_includes(artist.urls.map(&:url), "https://www.pixiv.net/stacc/niceandcool")
      end

      should "fetch the defaults from the given tag" do
        source = "https://i.pximg.net/img-original/img/2018/01/28/23/56/50/67014762_p0.jpg"
        FactoryBot.create(:post, source: source, tag_string: "test_artist")
        artist = Artist.new_with_defaults(name: "test_artist")

        assert_equal("test_artist", artist.name)
        assert_equal("Nice_and_Cool niceandcool", artist.other_names_string)
        assert_includes(artist.urls.map(&:url), "https://www.pixiv.net/users/906442")
        assert_includes(artist.urls.map(&:url), "https://www.pixiv.net/stacc/niceandcool")
      end
    end
  end
end
