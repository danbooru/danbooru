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
        @artist = create(:artist)
        @masao = create(:artist, name: "masao", url_string: "http://www.pixiv.net/member.php?id=32777")
        @artgerm = create(:artist, name: "artgerm", url_string: "http://artgerm.deviantart.com/")
      end
    end

    context "show action" do
      should "work for html responses" do
        get artist_path(@masao.id)
        assert_response :success
      end

      should "work for xml responses" do
        get artist_path(@masao.id), as: :xml
        assert_response :success
      end

      should "get the show page for a negated tag" do
        @artist.update(name: "-aaa")
        get artist_path(@artist.id)
        assert_response :success
      end
    end

    context "new action" do
      should "render" do
        get_auth new_artist_path, @user
        assert_response :success
      end
    end

    context "show_or_new action" do
      should "get the show_or_new page for an existing artist" do
        get_auth show_or_new_artists_path(name: "masao"), @user
        assert_redirected_to(@masao)
      end

      should "get the show_or_new page for a nonexisting artist" do
        get_auth show_or_new_artists_path(name: "nobody"), @user
        assert_response :success
      end

      should "redirect to the new artist page for a blank artist" do
        get_auth show_or_new_artists_path, @user
        assert_redirected_to new_artist_path
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_artist_path(@artist.id), @user
        assert_response :success
      end
    end

    context "banned action" do
      should "redirect to a banned search" do
        get banned_artists_path
        assert_response :redirect
      end
    end

    context "ban action" do
      should "ban an artist" do
        put_auth ban_artist_path(@artist.id), @admin
        assert_redirected_to(@artist)
        assert_equal(true, @artist.reload.is_banned?)
        assert_equal(true, TagImplication.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))
      end

      should "not allow non-admins to ban artists" do
        put_auth ban_artist_path(@artist.id), @user
        assert_response 403
        assert_equal(false, @artist.reload.is_banned?)
      end
    end

    context "unban action" do
      should "unban an artist" do
        @artist.ban!(banner: @admin)
        put_auth unban_artist_path(@artist.id), @admin

        assert_redirected_to(@artist)
        assert_equal(false, @artist.reload.is_banned?)
        assert_equal(false, TagImplication.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))
      end
    end

    context "index action" do
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
    end

    context "create action" do
      should "create an artist" do
        assert_difference("Artist.count", 1) do
          post_auth artists_path, @user, params: { artist: { name: "test" }}
          assert_response :redirect
          assert_equal("test", Artist.last.name)
        end
      end
    end

    context "with an artist that has a wiki page" do
      setup do
        as(@admin) do
          @artist = create(:artist, name: "aaa", url_string: "http://example.com")
          @wiki_page = create(:wiki_page, title: "aaa", body: "testing")
        end
        @another_user = create(:user)
      end

      should "update the wiki with the artist" do
        old_timestamp = @wiki_page.updated_at
        travel(1.minute) do
          put_auth artist_path(@artist.id), @user, params: {artist: { wiki_page_attributes: { body: "rex" }, url_string: "http://example.com\nhttp://monet.com"}}
        end
        @artist.reload
        @wiki_page = @artist.wiki_page
        assert_equal("rex", @artist.wiki_page.body)
        assert_not_equal(old_timestamp, @wiki_page.updated_at)
        assert_redirected_to(artist_path(@artist.id))
      end

      should "not touch the updated_at fields when nothing is changed" do
        old_timestamp = @wiki_page.updated_at

        travel(1.minute)
        as(@another_user) { @artist.update(wiki_page_attributes: { body: "testing" }) }

        assert_equal(old_timestamp.to_i, @artist.reload.wiki_page.updated_at.to_i)
      end
    end

    context "destroy action" do
      should "delete an artist" do
        delete_auth artist_path(@artist.id), create(:builder_user)
        assert_redirected_to(artist_path(@artist.id))
        assert_equal(true, @artist.reload.is_deleted)
      end
    end

    context "update action" do
      should "undelete an artist" do
        put_auth artist_path(@artist.id), create(:builder_user), params: {artist: {is_deleted: false}}
        assert_redirected_to(artist_path(@artist.id))
        assert_equal(false, @artist.reload.is_deleted)
      end
    end

    context "revert action" do
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
        assert_redirected_to(artist_path(@artist.id))
        assert_not_equal(@artist.reload.name, @artist2.name)
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
