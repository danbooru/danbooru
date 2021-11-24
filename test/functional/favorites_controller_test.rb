require 'test_helper'

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  context "The favorites controller" do
    setup do
      @user = create(:user)
      @post = create(:post)
      @faved_post = create(:post)
      create(:favorite, post: @faved_post, user: @user)
    end

    context "index action" do
      should "render for json" do
        get favorites_path, as: :json
        assert_response :success
      end

      should "render for html" do
        get favorites_path
        assert_response :success
      end

      should "render for /favorites?variant=tooltip" do
        get post_favorites_path(@post, variant: "tooltip")
        assert_response :success
      end

      should "render for /users/:id/favorites" do
        get user_favorites_path(@user)
        assert_response :success
      end

      should "render for /posts/:id/favorites" do
        get post_favorites_path(@faved_post)
        assert_response :success
      end

      should "render for /favorites?search[user_name]=<name>" do
        get favorites_path(search: { user_name: @user.name })
        assert_response :success
      end
    end

    context "create action" do
      should "create a favorite for the current user" do
        assert_difference [-> { @post.favorites.count }, -> { @post.reload.fav_count }, -> { @user.reload.favorite_count }], 1 do
          post_auth favorites_path(post_id: @post.id), @user, as: :javascript
          assert_response :redirect
        end
      end

      should "not allow creating duplicate favorites" do
        create(:favorite, post: @post, user: @user)

        assert_no_difference [-> { @post.favorites.count }, -> { @post.reload.fav_count }, -> { @user.reload.favorite_count }] do
          post_auth favorites_path(post_id: @post.id), @user, as: :javascript
          assert_response :redirect
        end
      end

      should "not allow banned users to create favorites" do
        @banned_user = create(:banned_user)

        assert_difference [-> { @post.favorites.count }, -> { @post.reload.fav_count }, -> { @banned_user.reload.favorite_count }], 0 do
          post_auth favorites_path(post_id: @post.id), @banned_user, as: :javascript
          assert_response 403
        end
      end

      should "not allow restricted users to create favorites" do
        @restricted_user = create(:restricted_user)

        assert_difference [-> { @post.favorites.count }, -> { @post.reload.fav_count }, -> { @restricted_user.reload.favorite_count }], 0 do
          post_auth favorites_path(post_id: @post.id), @restricted_user, as: :javascript
          assert_response 403
        end
      end

      should "not allow anonymous users to create favorites" do
        assert_no_difference [-> { @post.favorites.count }, -> { @post.reload.fav_count }] do
          post favorites_path(post_id: @post.id), as: :javascript
          assert_response 403
        end
      end
    end

    context "destroy action" do
      should "remove the favorite for the current user" do
        delete_auth favorite_path(@faved_post.id), @user, as: :javascript

        assert_response :redirect
        assert_equal(0, @faved_post.favorites.count)
        assert_equal(0, @faved_post.reload.fav_count)
        assert_equal(0, @faved_post.votes.active.count)
        assert_equal(1, @faved_post.votes.deleted.count)
        assert_equal(0, @user.reload.favorite_count)
      end

      should "allow banned users to destroy favorites" do
        assert_difference [-> { @faved_post.favorites.count }, -> { @faved_post.reload.fav_count }, -> { @user.reload.favorite_count }], -1 do
          delete_auth favorite_path(@faved_post.id), @user, as: :javascript
          assert_response :redirect
        end
      end
    end
  end
end
