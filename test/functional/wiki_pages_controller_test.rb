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
    end

    context "show action" do
      setup do
        @wiki_page = FactoryGirl.create(:wiki_page)
      end

      should "render" do
        get :show, {:id => @wiki_page.id}
        assert_response :success
      end

      should "render for a negated tag" do
        @wiki_page.update_attribute(:title, "-aaa")
        get :show, {:id => @wiki_page.id}
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
        @wiki_page = FactoryGirl.create(:wiki_page)
      end

      should "update a wiki_page" do
        post :update, {:id => @wiki_page.id, :wiki_page => {:body => "xyz"}}, {:user_id => @user.id}
        @wiki_page.reload
        assert_equal("xyz", @wiki_page.body)
      end
    end

    context "destroy action" do
      setup do
        @wiki_page = FactoryGirl.create(:wiki_page)
      end

      should "destroy a wiki_page" do
        post :destroy, {:id => @wiki_page.id}, {:user_id => @mod.id}
        @wiki_page.reload
        assert_equal(true, @wiki_page.is_deleted?)
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
