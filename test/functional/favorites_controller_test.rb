require 'test_helper'

class FavoritesControllerTest < ActionController::TestCase
  context "The favorites controller" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      setup do
        @post = Factory.create(:post)
        @post.add_favorite!(@user)
      end
      
      context "with a specified tags parameter" do
        should "redirect to the posts controller" do
          get :index, {:tags => "abc"}, {:user_id => @user}
          assert_redirected_to(posts_path(:tags => "fav:#{@user.name} abc"))
        end
      end
      
      should "display the current user's favorites" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
        assert_not_nil(assigns(:favorite_set))
      end
    end
    
    context "create action" do
      setup do
        @post = Factory.create(:post)
      end

      should "create a favorite for the current user" do
        assert_difference("Favorite.count", 1) do
          post :create, {:format => "js", :post_id => @post.id}, {:user_id => @user.id}
        end
      end
    end
    
    context "destroy action" do
      setup do
        @post = Factory.create(:post)
        @post.add_favorite!(@user)
      end
      
      should "remove the favorite from the current user" do
        assert_difference("Favorite.count", -1) do
          post :destroy, {:format => "js", :id => @post.id}, {:user_id => @user.id}
        end
      end
    end
  end
end
