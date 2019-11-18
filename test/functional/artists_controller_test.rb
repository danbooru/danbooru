require 'test_helper'

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  def assert_artist_found(expected_artist, source_url = nil)
    if source_url
      get_auth artists_path(format: "json", search: { url_matches: source_url }), @user
      if response.body =~ /Net::OpenTimeout/
        skip "Remote connection to #{source_url} failed"
        return
      end
    end
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal(1, json.size, "Testing URL: #{source_url}")
    assert_equal(expected_artist, json[0]["name"])
  end

  def assert_artist_not_found(source_url)
    get_auth artists_path(format: "json", search: { url_matches: source_url }), @user
    if response.body =~ /Net::OpenTimeout/
      skip "Remote connection to #{source_url} failed"
      return
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal(0, json.size, "Testing URL: #{source_url}")
  end

  context "An artists controller" do
    setup do
      @admin = create(:admin_user)
      @user = create(:user)
      as_user do
        @artist = create(:artist, notes: "message")
        @masao = create(:artist, name: "masao", url_string: "http://www.pixiv.net/member.php?id=32777")
        @artgerm = create(:artist, name: "artgerm", url_string: "http://artgerm.deviantart.com/")
      end
    end

    context "show action" do
      should "work for xml responses" do
        get artist_path(@masao.id), as: :xml
        assert_response :success
      end
    end

    should "get the new page" do
      get_auth new_artist_path, @user
      assert_response :success
    end

    should "get the show_or_new page for an existing artist" do
      get_auth show_or_new_artists_path(name: "masao"), @user
      assert_redirected_to(@masao)
    end

    should "get the show_or_new page for a nonexisting artist" do
      get_auth show_or_new_artists_path(name: "nobody"), @user
      assert_response :success
    end

    should "get the edit page" do
      get_auth edit_artist_path(@artist.id), @user
      assert_response :success
    end

    should "get the show page" do
      get artist_path(@artist.id)
      assert_response :success
    end

    should "get the show page for a negated tag" do
      @artist.update(name: "-aaa")
      get artist_path(@artist.id)
      assert_response :success
    end

    should "get the banned page" do
      get banned_artists_path
      assert_redirected_to artists_path(search: { is_banned: true, order: "updated_at" })
    end

    should "ban an artist" do
      put_auth ban_artist_path(@artist.id), @admin
      assert_redirected_to(@artist)
      @artist.reload
      assert_equal(true, @artist.is_banned?)
      assert_equal(true, TagImplication.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))
    end

    should "unban an artist" do
      as_admin do
        @artist.ban!
      end

      put_auth unban_artist_path(@artist.id), @admin
      assert_redirected_to(@artist)
      @artist.reload
      assert_equal(false, @artist.is_banned?)
      assert_equal(false, TagImplication.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))
    end

    should "get the index page" do
      get artists_path
      assert_response :success
    end

    context "when searching the index page" do
      should "find artists by name" do
        get artists_path(name: "masao", format: "json")
        assert_artist_found("masao")
      end

      should "find artists by image URL" do
        get artists_path(search: { url_matches: "http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_m.jpg" }, format: "json")
        assert_artist_found("masao")
      end

      should "find artists by page URL" do
        url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939"
        get artists_path(search: { url_matches: url }, format: "json")
        assert_artist_found("masao")
      end
    end

    should "create an artist" do
      attributes = FactoryBot.attributes_for(:artist)
      assert_difference("Artist.count", 1) do
        attributes.delete(:is_active)
        post_auth artists_path, @user, params: {artist: attributes}
      end
      artist = Artist.find_by_name(attributes[:name])
      assert_not_nil(artist)
      assert_redirected_to(artist_path(artist.id))
    end

    context "with an artist that has notes" do
      setup do
        as(@admin) do
          @artist = create(:artist, name: "aaa", notes: "testing", url_string: "http://example.com")
        end
        @wiki_page = @artist.wiki_page
        @another_user = create(:user)
      end

      should "update an artist" do
        old_timestamp = @wiki_page.updated_at
        travel(1.minute) do
          put_auth artist_path(@artist.id), @user, params: {artist: {notes: "rex", url_string: "http://example.com\nhttp://monet.com"}}
        end
        @artist.reload
        @wiki_page = @artist.wiki_page
        assert_equal("rex", @artist.notes)
        assert_not_equal(old_timestamp, @wiki_page.updated_at)
        assert_redirected_to(artist_path(@artist.id))
      end

      should "not touch the updated_at fields when nothing is changed" do
        old_timestamp = @wiki_page.updated_at

        travel(1.minute)
        as(@another_user) { @artist.update(notes: "testing") }

        assert_equal(old_timestamp.to_i, @artist.reload.wiki_page.updated_at.to_i)
      end

      context "when renaming an artist" do
        should "automatically rename the artist's wiki page" do
          assert_difference("WikiPage.count", 0) do
            put_auth artist_path(@artist.id), @user, params: {artist: {name: "bbb", notes: "more testing"}}
          end
          @wiki_page.reload
          assert_equal("bbb", @wiki_page.title)
          assert_equal("more testing", @wiki_page.body)
        end

        should "merge the new notes with the existing wiki page's contents if a wiki page for the new name already exists" do
          as_user do
            @existing_wiki_page = create(:wiki_page, title: "bbb", body: "xxx")
          end
          put_auth artist_path(@artist.id), @user, params: {artist: {name: "bbb", notes: "yyy"}}
          @existing_wiki_page.reload
          assert_equal("bbb", @existing_wiki_page.title)
          assert_equal("xxx\n\nyyy", @existing_wiki_page.body)
        end
      end
    end

    should "delete an artist" do
      @builder = create(:builder_user)
      delete_auth artist_path(@artist.id), @builder
      assert_redirected_to(artist_path(@artist.id))
      @artist.reload
      assert_equal(false, @artist.is_active)
    end

    should "undelete an artist" do
      @builder = create(:builder_user)
      put_auth artist_path(@artist.id), @builder, params: {artist: {is_active: true}}
      assert_redirected_to(artist_path(@artist.id))
      assert_equal(true, @artist.reload.is_active)
    end

    context "reverting an artist" do
      should "work" do
        as_user do
          @artist.update(name: "xyz")
          @artist.update(name: "abc")
        end
        version = @artist.versions.first
        put_auth revert_artist_path(@artist.id), @user, params: {version_id: version.id}
      end

      should "not allow reverting to a previous version of another artist" do
        as_user do
          @artist2 = create(:artist)
        end
        put_auth artist_path(@artist.id), @user, params: {version_id: @artist2.versions.first.id}
        @artist.reload
        assert_not_equal(@artist.name, @artist2.name)
        assert_redirected_to(artist_path(@artist.id))
      end
    end

    context "when finding an artist" do
      should "find nothing for unknown URLs" do
        assert_artist_not_found("http://www.example.com")
      end

      should "find deviantart artists" do
        assert_artist_found("artgerm", "http://artgerm.deviantart.com/art/Peachy-Princess-Ver-2-457220550")
      end

      should_eventually "find deviantart artists for image URLs" do
        assert_artist_found("artgerm", "http://fc06.deviantart.net/fs71/f/2014/150/d/c/peachy_princess_by_artgerm-d7k7tmu.jpg")
      end

      should "find pixiv artists for img##" do
        assert_artist_found("masao", "http://i2.pixiv.net/img04/img/syounen_no_uta/46170939.jpg")
      end

      should "find pixiv artists for img-original" do
        assert_artist_found("masao", "http://i2.pixiv.net/img-original/img/2014/09/25/00/57/24/46170939_p0.jpg")
      end

      should "find pixiv artists for member_illust.php" do
        assert_artist_found("masao", "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939")
      end

      should "fail for nonexisting illust ids" do
        assert_artist_not_found("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=herpderp")
      end

      should "fail for malformed urls" do
        assert_artist_not_found("http://www.pixiv.net/wharrgarbl")
      end

      should "not fail for Pixiv bad IDs" do
        assert_artist_not_found("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=0")
      end
    end
  end
end
