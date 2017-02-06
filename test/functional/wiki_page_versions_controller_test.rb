require 'test_helper'

class WikiPageVersionsControllerTest < ActionController::TestCase
  context "The wiki page versions controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @wiki_page = FactoryGirl.create(:wiki_page)
      @wiki_page.update_attributes(:body => "1 2")
      @wiki_page.update_attributes(:body => "2 3")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      should "list all versions" do
        get :index
        assert_response :success
        assert_not_nil(assigns(:wiki_page_versions))
      end

      should "list all versions that match the search criteria" do
        get :index, {:search => {:wiki_page_id => @wiki_page.id}}
        assert_response :success
        assert_not_nil(assigns(:wiki_page_versions))
      end
    end

    context "show action" do
      should "render" do
        get :show, { id: @wiki_page.versions.first.id }
        assert_response :success
      end
    end

    context "diff action" do
      should "render" do
        get :diff, { thispage: @wiki_page.versions.first.id, otherpage: @wiki_page.versions.last.id }
        assert_response :success
      end
    end
  end
end
