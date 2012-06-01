require 'test_helper'

class WikiPageVersionsControllerTest < ActionController::TestCase
  context "The wiki page versions controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      setup do
        @wiki_page = FactoryGirl.create(:wiki_page)
        @wiki_page.update_attributes(:body => "1 2")
        @wiki_page.update_attributes(:body => "2 3")
      end
      
      should "list all versions" do
        get :index
        assert_response :success
        assert_not_nil(assigns(:wiki_page_versions))
      end
      
      should "list all versions that match the search criteria" do
        get :index, {:search => {:wiki_page_id_equals => @wiki_page.id}}
        assert_response :success
        assert_not_nil(assigns(:wiki_page_versions))
      end
    end
  end
end
