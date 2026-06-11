require "test_helper"

module Moderator
  module Post
    class PostsControllerTest < ActionDispatch::IntegrationTest
      context "The moderator posts controller" do
        setup do
          @admin = create(:admin_user)
          travel_to(1.month.ago) do
            @user = create(:gold_user)
          end

          as(@user) do
            @post = create(:post_with_file)
          end
        end

        context "confirm_move_favorites action" do
          should "render" do
            get_auth confirm_move_favorites_moderator_post_post_path(@post), @admin
            assert_response :success
          end
        end

        context "move_favorites action" do
          setup do
            @admin = create(:admin_user)
          end

          should "render" do
            as(@user) do
              @parent = create(:post)
              @child = create(:post, parent: @parent)
            end
            users = create_list(:user, 2)
            users.each do |u|
              Favorite.create!(post: @child, user: u)
              @child.reload
            end

            post_auth move_favorites_moderator_post_post_path(@child.id), @admin, params: { commit: "Submit" }
            assert_redirected_to(@child)
            @parent.reload
            @child.reload
            as(@admin) do
              assert_equal(users.map(&:id).sort, @parent.favorites.map(&:user_id).sort)
              assert_equal([], @child.favorites.map(&:user_id))
            end
          end

          should "not allow banned approvers to move favorites" do
            as(@user) do
              @parent = create(:post)
              @child = create(:post, parent: @parent)
            end
            users = create_list(:user, 2)
            users.each { |u| Favorite.create!(post: @child, user: u) }

            @banned_approver = create(:banned_user, level: User::Levels::APPROVER)
            post_auth move_favorites_moderator_post_post_path(@child.id), @banned_approver, params: { commit: "Submit" }

            assert_response 403
            assert_equal([], @parent.reload.favorites.to_a)
          end
        end

        context "expunge action" do
          should "render" do
            post_auth expunge_moderator_post_post_path(@post), @admin, params: { format: "js" }

            assert_response :success
            assert_equal(false, ::Post.exists?(@post.id))
          end
        end

        context "ban action" do
          should "render" do
            post_auth ban_moderator_post_post_path(@post), @admin

            assert_redirected_to @post
            assert_equal(true, @post.reload.is_banned?)
          end

          should "not allow banned approvers to ban posts" do
            @banned_approver = create(:banned_user, level: User::Levels::APPROVER)
            post_auth ban_moderator_post_post_path(@post), @banned_approver

            assert_response 403
            assert_equal(false, @post.reload.is_banned?)
          end
        end

        context "unban action" do
          should "render" do
            @post.ban!(@admin)
            post_auth unban_moderator_post_post_path(@post), @admin

            assert_redirected_to(@post)
            assert_equal(false, @post.reload.is_banned?)
          end

          should "not allow banned approvers to unban posts" do
            @post.update!(is_banned: true)
            @banned_approver = create(:banned_user, level: User::Levels::APPROVER)
            post_auth unban_moderator_post_post_path(@post), @banned_approver

            assert_response 403
            assert_equal(true, @post.reload.is_banned?)
          end
        end
      end
    end
  end
end
