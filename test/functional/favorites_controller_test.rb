require 'test_helper'

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  context "The favorites controller" do
    setup do
      @user = create(:user)
    end

    context "index action" do
      setup do
        @post = create(:post)
        @post.add_favorite!(@user)
      end

      context "with a specified tags parameter" do
        should "redirect to the posts controller" do
          get_auth favorites_path, @user, params: {:tags => "fav:#{@user.name} abc"}
          assert_redirected_to(posts_path(:tags => "fav:#{@user.name} abc"))
        end
      end

      should "display the current user's favorites" do
        get_auth favorites_path, @user
        assert_response :success
      end
    end

    context "create action" do
      setup do
        @post = create(:post)
      end

      should "create a favorite for the current user" do
        assert_difference("Favorite.count", 1) do
          post_auth favorites_path, @user, params: {:format => "js", :post_id => @post.id}
        end
      end
    end

    context "destroy action" do
      setup do
        @post = create(:post)
        @post.add_favorite!(@user)
      end

      should "remove the favorite from the current user" do
        assert_difference("Favorite.count", -1) do
          delete_auth favorite_path(@post.id), @user, params: {:format => "js"}
        end
      end
    end
  end
end
