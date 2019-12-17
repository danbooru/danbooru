require 'test_helper'

class WikiPagesControllerTest < ActionDispatch::IntegrationTest
  context "The wiki pages controller" do
    setup do
      @user = create(:user)
      @mod = create(:moderator_user)
    end

    context "index action" do
      setup do
        as_user do
          @wiki_page_abc = create(:wiki_page, :title => "abc")
          @wiki_page_def = create(:wiki_page, :title => "def")
        end
      end

      should "list all wiki_pages" do
        get wiki_pages_path
        assert_response :success
      end

      should "list all wiki_pages (with search)" do
        get wiki_pages_path, params: {:search => {:title => "abc"}}
        assert_response :success
        assert_select "tr td:first-child", text: "abc"
      end

      should "list wiki_pages without tags with order=post_count" do
        get wiki_pages_path, params: {:search => {:title => "abc", :order => "post_count"}}
        assert_response :success
        assert_select "tr td:first-child", text: "abc"
      end
    end

    context "show action" do
      setup do
        as_user do
          @wiki_page = create(:wiki_page)
        end
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
        as_user do
          @wiki_page.update(title: "-aaa")
        end

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
        as_user do
          @wiki_page = create(:wiki_page)
        end
      end

      should "redirect when given a title" do
        get show_or_new_wiki_pages_path, params: { title: @wiki_page.title }
        assert_redirected_to(@wiki_page)
      end

      should "redirect when given a nonexistent title" do
        get show_or_new_wiki_pages_path, params: { title: "what" }
        assert_redirected_to wiki_page_path("what")
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
        as_user do
          @wiki_page = create(:wiki_page)
        end

        get_auth wiki_page_path(@wiki_page), @mod
        assert_response :success
      end
    end

    context "create action" do
      should "create a wiki_page" do
        assert_difference("WikiPage.count", 1) do
          post_auth wiki_pages_path, @user, params: {:wiki_page => {:title => "abc", :body => "abc"}}
        end
      end
    end

    context "update action" do
      setup do
        as_user do
          @tag = create(:tag, name: "foo", post_count: 42)
          @wiki_page = create(:wiki_page, title: "foo")
        end
      end

      should "update a wiki_page" do
        put_auth wiki_page_path(@wiki_page), @user, params: {:wiki_page => {:body => "xyz"}}
        @wiki_page.reload
        assert_equal("xyz", @wiki_page.body)
      end

      should "warn about renaming a wiki page with a non-empty tag" do
        put_auth wiki_page_path(@wiki_page), @mod, params: { wiki_page: { title: "bar" }}
        assert_match(/still has 42 posts/, flash[:notice])
      end
    end

    context "destroy action" do
      setup do
        as_user do
          @wiki_page = create(:wiki_page)
        end
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
        as_user do
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
        as_user do
          @wiki_page_2 = create(:wiki_page)
        end

        put_auth revert_wiki_page_path(@wiki_page), @user, params: { :version_id => @wiki_page_2.versions.first.id }
        @wiki_page.reload

        assert_not_equal(@wiki_page.body, @wiki_page_2.body)
        assert_response :missing
      end
    end
  end
end
