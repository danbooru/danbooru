require 'test_helper'

class WikiPagesControllerTest < ActionDispatch::IntegrationTest
  context "The wiki pages controller" do
    setup do
      @user = create(:user)
      @mod = create(:moderator_user)
    end

    context "index action" do
      setup do
        as(@user) do
          @tagme = create(:wiki_page, title: "tagme")
          @deleted = create(:wiki_page, title: "deleted", is_deleted: true)
          @vocaloid = create(:wiki_page, title: "vocaloid")
          @miku = create(:wiki_page, title: "hatsune_miku", other_names: ["初音ミク"], body: "miku is a [[vocaloid]]")
          @picasso = create(:wiki_page, title: "picasso")
          create(:artist, name: "picasso", is_banned: true)
          create(:character_tag, name: "hatsune_miku")
        end
      end

      should "render" do
        get wiki_pages_path
        assert_response :success
      end

      should "render for a sitemap" do
        get wiki_pages_path(format: :sitemap)
        assert_response :success
        assert_equal(WikiPage.count, response.parsed_body.css("urlset url loc").size)
      end

      should "redirect the legacy title param to the show page" do
        get wiki_pages_path(title: "tagme")
        assert_redirected_to wiki_pages_path(search: { title_normalize: "tagme" }, redirect: true)
      end

      should respond_to_search({}).with { [@picasso, @miku, @vocaloid, @deleted, @tagme] }
      should respond_to_search(title: "tagme").with { @tagme }
      should respond_to_search(title: "tagme", order: "post_count").with { @tagme }
      should respond_to_search(title_normalize: "TAGME  ").with { @tagme }

      should respond_to_search(hide_deleted: "true").with { [@picasso, @miku, @vocaloid, @tagme] }
      should respond_to_search(linked_to: "vocaloid").with { @miku }
      should respond_to_search(not_linked_to: "vocaloid").with { [@picasso, @vocaloid, @deleted, @tagme] }

      should respond_to_search(other_names_match: "初音ミク").with { @miku }
      should respond_to_search(other_names_match: "初*").with { @miku }
      should respond_to_search(other_names_present: "true").with { @miku }
      should respond_to_search(other_names_present: "false").with { [@picasso, @vocaloid, @deleted, @tagme] }

      context "using includes" do
        should respond_to_search(has_tag: "true").with { @miku }
        should respond_to_search(tag: { category: Tag.categories.character }).with { @miku }
        should respond_to_search(has_dtext_links: "true").with { @miku }
        should respond_to_search(has_artist: "true").with { @picasso }
        should respond_to_search(artist: {is_banned: "true"}).with { @picasso }
      end
    end

    context "search action" do
      should "work" do
        get search_wiki_pages_path
        assert_response :success
      end
    end

    context "show action" do
      setup do
        @wiki_page = as(@user) { create(:wiki_page) }
      end

      should "redirect to the title for an id" do
        get wiki_page_path(@wiki_page.id)
        assert_redirected_to wiki_page_path(@wiki_page.title)

        get wiki_page_path(@wiki_page.id), as: :json
        assert_response :success
      end

      should "distinguish between an id and a title" do
        as(@user) { @wiki_page.update(title: "2019") }

        get wiki_page_path("~2019")
        assert_response :success

        get wiki_page_path(@wiki_page.id)
        assert_redirected_to wiki_page_path("~2019")

        get wiki_page_path("2019")
        assert_response 404
      end

      should "render for a title" do
        get wiki_page_path(@wiki_page.title)
        assert_response :success
      end

      should "show the 'does not exist' page for a nonexistent title" do
        get wiki_page_path("what")

        assert_response 404
        assert_select "#wiki-page-body", text: /This wiki page does not exist/
      end

      should "return 404 to api requests for a nonexistent title" do
        get wiki_page_path("what"), as: :json
        assert_response 404
      end

      should "render for a negated tag" do
        as(@user) { @wiki_page.update(title: "-aaa") }

        get wiki_page_path(@wiki_page.id)
        assert_redirected_to wiki_page_path(@wiki_page.title)
      end

      should "work for a title containing dots" do
        as(@user) { create(:wiki_page, title: "...") }

        get wiki_page_path("...")
        assert_response :success

        get wiki_page_path("....json")
        assert_response :success

        get wiki_page_path("....xml")
        assert_response :success
      end
    end

    context "show_or_new action" do
      setup do
        @wiki_page = as(@user) { create(:wiki_page) }
      end

      should "redirect when given a title" do
        get show_or_new_wiki_pages_path, params: { title: @wiki_page.title }
        assert_redirected_to(@wiki_page)
      end

      should "redirect when given a nonexistent title" do
        get show_or_new_wiki_pages_path, params: { title: "what" }
        assert_redirected_to wiki_page_path("what")
      end

      should "redirect when given a blank title" do
        get show_or_new_wiki_pages_path
        assert_redirected_to new_wiki_page_path
      end
    end

    context "new action" do
      should "render" do
        get_auth new_wiki_page_path, @mod, params: { wiki_page: { title: "test" }}
        assert_response :success
      end

      should "render without a title" do
        get_auth new_wiki_page_path, @mod
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        @wiki_page = as(@user) { create(:wiki_page) }
        get_auth edit_wiki_page_path(@wiki_page), @user
        assert_response :success
      end
    end

    context "create action" do
      should "create a wiki_page" do
        assert_difference("WikiPage.count", 1) do
          post_auth wiki_pages_path, @user, params: {:wiki_page => {:title => "abc", :body => "abc"}}
          assert_redirected_to(wiki_page_path(WikiPage.last))
        end
      end
    end

    context "update action" do
      setup do
        as(@user) do
          @tag = create(:tag, name: "foo", post_count: 42)
          @wiki_page = create(:wiki_page, title: "foo")
          @builder = create(:builder_user)
        end
      end

      should "update a wiki_page" do
        put_auth wiki_page_path(@wiki_page), @user, params: {:wiki_page => {:body => "xyz"}}

        assert_redirected_to wiki_page_path(@wiki_page)
        assert_equal("xyz", @wiki_page.reload.body)
      end

      should "not allow members to edit locked wiki pages" do
        as(@user) { @wiki_page.update!(is_locked: true) }
        put_auth wiki_page_path(@wiki_page), @user, params: { wiki_page: { body: "xyz" }}

        assert_response 403
        assert_not_equal("xyz", @wiki_page.reload.body)
      end

      should "allow builders to edit locked wiki pages" do
        as(@builder) { @wiki_page.update!(is_locked: true) }
        put_auth wiki_page_path(@wiki_page), @builder, params: { wiki_page: { body: "xyz" }}

        assert_redirected_to wiki_page_path(@wiki_page)
        assert_equal("xyz", @wiki_page.reload.body)
      end

      should "not allow members to edit the is_locked flag" do
        put_auth wiki_page_path(@wiki_page), @user, params: { wiki_page: { is_locked: true }}

        assert_response 403
        assert_equal(false, @wiki_page.reload.is_locked)
      end

      should "allow builders to edit the is_locked flag" do
        put_auth wiki_page_path(@wiki_page), @builder, params: { wiki_page: { is_locked: true }}

        assert_redirected_to wiki_page_path(@wiki_page)
        assert_equal(true, @wiki_page.reload.is_locked)
      end

      should "warn about renaming a wiki page with a non-empty tag" do
        put_auth wiki_page_path(@wiki_page), @mod, params: { wiki_page: { title: "bar" }}
        assert_match(/still has 42 posts/, flash[:notice])
      end
    end

    context "destroy action" do
      setup do
        @wiki_page = as(@user) { create(:wiki_page) }
        @mod = create(:mod_user)
      end

      should "destroy a wiki_page" do
        delete_auth wiki_page_path(@wiki_page), @mod
        @wiki_page.reload
        assert_equal(true, @wiki_page.is_deleted?)
      end
    end

    context "revert action" do
      setup do
        as(@user) do
          @wiki_page = create(:wiki_page, body: "1")
          travel(1.day)
          @wiki_page.update(body: "1 2")
          travel(2.days)
          @wiki_page.update(body: "1 2 3")
        end
      end

      should "revert to a previous version" do
        version = @wiki_page.versions.first
        assert_equal("1", version.body)
        put_auth revert_wiki_page_path(@wiki_page), @user, params: {:version_id => version.id}
        @wiki_page.reload
        assert_equal("1", @wiki_page.body)
      end

      should "not allow reverting to a previous version of another wiki page" do
        @wiki_page_2 = as(@user) { create(:wiki_page) }

        put_auth revert_wiki_page_path(@wiki_page), @user, params: { :version_id => @wiki_page_2.versions.first.id }
        @wiki_page.reload

        assert_not_equal(@wiki_page.body, @wiki_page_2.body)
        assert_response :missing
      end
    end
  end
end
