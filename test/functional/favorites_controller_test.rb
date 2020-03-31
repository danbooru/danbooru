require 'test_helper'

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  context "The favorites controller" do
    setup do
      @user = create(:user)
      @post = create(:post)
      @faved_post = create(:post)
      @faved_post.add_favorite!(@user)
    end

    context "index action" do
      should "redirect the user_id param to an ordfav: search" do
        get favorites_path(user_id: @user.id)
        assert_redirected_to posts_path(tags: "ordfav:#{@user.name}", format: "html")
      end

      should "redirect members to an ordfav: search" do
        get_auth favorites_path, @user
        assert_redirected_to posts_path(tags: "ordfav:#{@user.name}", format: "html")
      end

      should "redirect anonymous users to the posts index" do
        get favorites_path
        assert_redirected_to posts_path(format: "html")
      end

      should "render for json" do
        get favorites_path, as: :json
        assert_response :success
      end
    end

    context "create action" do
      should "create a favorite for the current user" do
        assert_difference("Favorite.count", 1) do
          post_auth favorites_path(post_id: @post.id), @user, as: :javascript
          assert_response :redirect
        end
      end

      should "allow banned users to create favorites" do
        assert_difference("Favorite.count", 1) do
          post_auth favorites_path(post_id: @post.id), create(:banned_user), as: :javascript
          assert_response :redirect
        end
      end
    end

    context "destroy action" do
      should "remove the favorite from the current user" do
        assert_difference("Favorite.count", -1) do
          delete_auth favorite_path(@faved_post.id), @user, as: :javascript
          assert_response :redirect
        end
      end

      should "allow banned users to destroy favorites" do
        assert_difference("Favorite.count", -1) do
          delete_auth favorite_path(@faved_post.id), @user, as: :javascript
          assert_response :redirect
        end
      end
    end
  end
end
