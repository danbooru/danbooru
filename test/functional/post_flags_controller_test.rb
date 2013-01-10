require 'test_helper'

class PostFlagsControllerTest < ActionController::TestCase
  context "The post flags controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end
    
    context "index action" do
      setup do
        @post = FactoryGirl.create(:post)
        @post_flag = FactoryGirl.create(:post_flag, :post => @post)
      end
      
      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end
      
      context "with search parameters" do
        should "render" do
          get :index, {:search => {:post_id => @post_flag.post_id}}, {:user_id => @user.id}
          assert_response :success
        end
      end
    end
    
    context "create action" do
      setup do 
        @post = FactoryGirl.create(:post)
      end
      
      should "create a new flag" do
        assert_difference("PostFlag.count", 1) do
          post :create, {:format => "js", :post_flag => {:post_id => @post.id, :reason => "xxx"}}, {:user_id => @user.id}
          assert_not_nil(assigns(:post_flag))
          assert_equal([], assigns(:post_flag).errors.full_messages)
        end
      end
    end
  end
end
