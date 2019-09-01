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

      should "redirect the user_id param to an ordfav: search" do
        get favorites_path(user_id: @user.id)
        assert_redirected_to posts_path(tags: "ordfav:#{@user.name}")
      end

      should "redirect members to an ordfav: search" do
        get_auth favorites_path, @user
        assert_redirected_to posts_path(tags: "ordfav:#{@user.name}")
      end

      should "redirect anonymous users to the posts index" do
        get favorites_path
        assert_redirected_to posts_path
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
