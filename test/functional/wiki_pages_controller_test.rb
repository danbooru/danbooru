require 'test_helper'

class WikiPagesControllerTest < ActionController::TestCase
  context "The wiki pages controller" do
    setup do
      @user = FactoryGirl.create(:user)
      @mod = FactoryGirl.create(:moderator_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
    end

    context "index action" do
      setup do
        @wiki_page_abc = FactoryGirl.create(:wiki_page, :title => "abc")
        @wiki_page_def = FactoryGirl.create(:wiki_page, :title => "def")
      end

      should "list all wiki_pages" do
        get :index
        assert_response :success
      end

      should "list all wiki_pages (with search)" do
        get :index, {:search => {:title => "abc"}}
        assert_redirected_to(wiki_page_path(@wiki_page_abc))
      end

      should "list wiki_pages without tags with order=post_count" do
        get :index, {:search => {:title => "abc", :order => "post_count"}}
        assert_redirected_to(wiki_page_path(@wiki_page_abc))
      end
    end

    context "show action" do
      setup do
        @wiki_page = FactoryGirl.create(:wiki_page)
      end

      should "render" do
        get :show, {:id => @wiki_page.id}
        assert_response :success
      end

      should "render for a title" do
        get :show, {:id => @wiki_page.title}
        assert_response :success
      end

      should "redirect for a nonexistent title" do
        get :show, {:id => "what"}
        assert_redirected_to(show_or_new_wiki_pages_path(title: "what"))
      end

      should "render for a negated tag" do
        @wiki_page.update_attribute(:title, "-aaa")
        get :show, {:id => @wiki_page.id}
        assert_response :success
      end
    end

    context "show_or_new action" do
      setup do
        @wiki_page = FactoryGirl.create(:wiki_page)
      end

      should "redirect when given a title" do
        get :show_or_new, { title: @wiki_page.title }
        assert_redirected_to(@wiki_page)
      end

      should "render when given a nonexistent title" do
        get :show_or_new, { title: "what" }
        assert_response :success
      end
    end

    context "new action" do
      should "render" do
        get :new, { wiki_page: { title: "test" }}, { user_id: @mod.id }
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        wiki_page = FactoryGirl.create(:wiki_page)

        get :edit, { id: wiki_page.id }, { user_id: @mod.id }
        assert_response :success
      end
    end

    context "create action" do
      should "create a wiki_page" do
        assert_difference("WikiPage.count", 1) do
          post :create, {:wiki_page => {:title => "abc", :body => "abc"}}, {:user_id => @user.id}
        end
      end
    end

    context "update action" do
      setup do
        @tag = FactoryGirl.create(:tag, name: "foo", post_count: 42)
        @wiki_page = FactoryGirl.create(:wiki_page, title: "foo")
      end

      should "update a wiki_page" do
        post :update, {:id => @wiki_page.id, :wiki_page => {:body => "xyz"}}, {:user_id => @user.id}
        @wiki_page.reload
        assert_equal("xyz", @wiki_page.body)
      end

      should "not rename a wiki page with a non-empty tag" do
        post :update, {:id => @wiki_page.id, :wiki_page => {:title => "bar"}}, {:user_id => @user.id}

        assert_equal("foo", @wiki_page.reload.title)
      end

      should "rename a wiki page with a non-empty tag if secondary validations are skipped" do
        post :update, {:id => @wiki_page.id, :wiki_page => {:title => "bar", :skip_secondary_validations => "1"}}, {:user_id => @user.id}

        assert_equal("bar", @wiki_page.reload.title)
      end

      should "not allow non-Builders to delete wiki pages" do
        put :update, { id: @wiki_page.id, wiki_page: { is_deleted: true }}, { user_id: @user.id }
        assert_equal(false, @wiki_page.reload.is_deleted?)
      end
    end

    context "destroy action" do
      setup do
        @wiki_page = FactoryGirl.create(:wiki_page)
        @mod = FactoryGirl.create(:mod_user)
      end

      should "destroy a wiki_page" do
        CurrentUser.scoped(@mod) do
          post :destroy, {:id => @wiki_page.id}, {:user_id => @mod.id}
        end
        @wiki_page.reload
        assert_equal(true, @wiki_page.is_deleted?)
      end

      should "record the deleter" do
        CurrentUser.scoped(@mod) do
          post :destroy, {:id => @wiki_page.id}, {:user_id => @mod.id}
        end
        @wiki_page.reload
        assert_equal(@mod.id, @wiki_page.updater_id)
      end
    end

    context "revert action" do
      setup do
        @wiki_page = FactoryGirl.create(:wiki_page, :body => "1")
        Timecop.travel(1.day.from_now) do
          @wiki_page.update_attributes(:body => "1 2")
        end
        Timecop.travel(2.days.from_now) do
          @wiki_page.update_attributes(:body => "1 2 3")
        end
      end

      should "revert to a previous version" do
        version = @wiki_page.versions(true).first
        assert_equal("1", version.body)
        post :revert, {:id => @wiki_page.id, :version_id => version.id}, {:user_id => @user.id}
        @wiki_page.reload
        assert_equal("1", @wiki_page.body)
      end

      should "not allow reverting to a previous version of another wiki page" do
        @wiki_page_2 = FactoryGirl.create(:wiki_page)

        post :revert, { :id => @wiki_page.id, :version_id => @wiki_page_2.versions(true).first.id }, {:user_id => @user.id}
        @wiki_page.reload

        assert_not_equal(@wiki_page.body, @wiki_page_2.body)
        assert_response :missing
      end
    end
  end
end
