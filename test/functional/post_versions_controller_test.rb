require 'test_helper'

class PostVersionsControllerTest < ActionController::TestCase
  context "The post versions controller" do
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
        @post = FactoryGirl.create(:post)
        @post.update_attributes(:tag_string => "1 2", :source => "xxx")
        @post.update_attributes(:tag_string => "2 3", :rating => "e")
      end
      
      should "list all versions" do
        get :index
        assert_response :success
        assert_not_nil(assigns(:post_versions))
      end
      
      should "list all versions that match the search criteria" do
        get :index, {:search => {:post_id_equals => @post.id}}
        assert_response :success
        assert_not_nil(assigns(:post_versions))
      end
    end
  end
end
