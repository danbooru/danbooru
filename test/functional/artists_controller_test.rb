require 'test_helper'

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  def assert_artist_found(expected_artist, source_url = nil)
    if source_url
      get_auth artists_path(format: "json", search: { url_matches: source_url }), @user
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal(1, json.size, "Testing URL: #{source_url}")
    assert_equal(expected_artist, json[0]["name"])
  end

  def assert_artist_not_found(source_url)
    get_auth artists_path(format: "json", search: { url_matches: source_url }), @user

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal(0, json.size, "Testing URL: #{source_url}")
  end

  context "An artists controller" do
    setup do
      @admin = create(:admin_user)
      @user = create(:user)
      as(@user) do
        @artist = create(:artist)
        @masao = create(:artist, name: "masao", url_string: "http://www.pixiv.net/member.php?id=32777")
        @artgerm = create(:artist, name: "artgerm", url_string: "http://artgerm.deviantart.com/")
        @wiki = create(:wiki_page, title: "artgerm")
        @post = create(:post, tag_string: "masao")
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

      should "show active wikis" do
        as(@user) { create(:wiki_page, title: @artist.name) }
        get artist_path(@artist.id)

        assert_response :success
        assert_select ".artist-wiki", count: 1
      end

      should "not show deleted wikis" do
        as(@user) { create(:wiki_page, title: @artist.name, is_deleted: true) }
        get artist_path(@artist.id)

        assert_response :success
        assert_select ".artist-wiki", count: 0
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
        as(@admin) { @artist.ban!(banner: @admin) }
        put_auth unban_artist_path(@artist.id), @admin

        assert_redirected_to(@artist)
        assert_equal(false, @artist.reload.is_banned?)
        assert_equal(false, TagImplication.exists?(antecedent_name: @artist.name, consequent_name: "banned_artist"))
      end
    end

    context "index action" do
      should "render" do
        get artists_path
        assert_response :success
      end

      should "get the sitemap" do
        get artists_path(format: :sitemap)
        assert_response :success
        assert_equal(Artist.count, response.parsed_body.css("urlset url loc").size)
      end

      context "when searching the index page" do
        setup do
          @deleted = create(:artist, is_deleted: true)
          @banned = create(:artist, is_banned: true)
        end

        should "find artists by name" do
          get artists_path(name: "masao", format: "json")
          assert_artist_found("masao")
        end

        should respond_to_search({}).with { [@banned, @deleted, @artgerm, @masao, @artist] }
        should respond_to_search(name: "masao").with { @masao }
        should respond_to_search(is_banned: "true").with { @banned }
        should respond_to_search(is_deleted: "true").with { @deleted }
        should respond_to_search(url_matches: "http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_m.jpg").with { @masao }
        should respond_to_search(url_matches: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939").with { @masao }

        context "ignoring whitespace" do
          should respond_to_search(url_matches: " http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939 ").with { @masao }
        end

        context "using includes" do
          should respond_to_search(has_wiki_page: "true").with { @artgerm }
          should respond_to_search(has_wiki_page: "false").with { [@banned, @deleted, @masao, @artist] }
          should respond_to_search(has_tag: "true").with { @masao }
          should respond_to_search(has_tag: "false").with { [@banned, @deleted, @artgerm, @artist] }
          should respond_to_search(has_urls: "true").with { [@artgerm, @masao] }
          should respond_to_search(has_urls: "false").with { [@banned, @deleted, @artist] }
          should respond_to_search(urls: {url: "http://www.pixiv.net/member.php?id=32777"}).with { @masao }
          should respond_to_search(urls: {normalized_url: "http://www.deviantart.com/artgerm/"}).with { @artgerm }
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
        as(@user) do
          @artist.update(name: "xyz")
          @artist.update(name: "abc")
        end
        version = @artist.versions.first
        put_auth revert_artist_path(@artist.id), @user, params: {version_id: version.id}
      end

      should "not allow reverting to a previous version of another artist" do
        @artist2 = as(@user) { create(:artist) }
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
