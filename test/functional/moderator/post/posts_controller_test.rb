require 'test_helper'

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
            @post = create(:post)
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
            users = FactoryBot.create_list(:user, 2)
            users.each do |u|
              @child.add_favorite!(u)
              @child.reload
            end

            post_auth move_favorites_moderator_post_post_path(@child.id), @admin, params: { commit: "Submit" }
            assert_redirected_to(@child)
            @parent.reload
            @child.reload
            as(@admin) do
              assert_equal(users.map(&:id).sort, @parent.favorited_users.map(&:id).sort)
              assert_equal([], @child.favorited_users.map(&:id))
            end
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
        end

        context "unban action" do
          should "render" do
            @post.ban!
            post_auth unban_moderator_post_post_path(@post), @admin

            assert_redirected_to(@post)
            assert_equal(false, @post.reload.is_banned?)
          end
        end
      end
    end
  end
end
