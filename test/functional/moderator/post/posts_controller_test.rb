require 'test_helper'

module Moderator
  module Post
    class PostsControllerTest < ActionController::TestCase
      context "The moderator posts controller" do
        setup do
          @admin = FactoryGirl.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"
          @post = FactoryGirl.create(:post)
        end

        teardown do
          CurrentUser.user = nil
          CurrentUser.ip_addr = nil
        end

        context "confirm_delete action" do
          should "render" do
            get :confirm_delete, { id: @post.id }, { user_id: @admin.id }
            assert_response :success
          end
        end

        context "delete action" do
          should "render" do
            post :delete, {:id => @post.id, :reason => "xxx", :format => "js", :commit => "Delete"}, {:user_id => @admin.id}
            assert(@post.reload.is_deleted?)
          end

          should "work even if the deleter has flagged the post previously" do
            PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
            post :delete, {:id => @post.id, :reason => "xxx", :format => "js", :commit => "Delete"}, {:user_id => @admin.id}
            assert(@post.reload.is_deleted?)
          end
        end

        context "undelete action" do
          should "render" do
            @post.update(is_deleted: true)
            post :undelete, {:id => @post.id, :format => "js"}, {:user_id => @admin.id}

            assert_response :success
            assert(!@post.reload.is_deleted?)
          end
        end

        context "confirm_move_favorites action" do
          should "render" do
            get :confirm_move_favorites, { id: @post.id }, { user_id: @admin.id }
            assert_response :success
          end
        end

        context "move_favorites action" do
          setup do
            @admin = FactoryGirl.create(:admin_user)
            CurrentUser.user = @admin
            CurrentUser.ip_addr = "127.0.0.1"
          end

          teardown do
            CurrentUser.user = nil
            CurrentUser.ip_addr = nil
          end

          should "1234 render" do
            parent = FactoryGirl.create(:post)
            child = FactoryGirl.create(:post, parent: parent)
            users = FactoryGirl.create_list(:user, 2)
            users.each { |u| child.add_favorite!(u) }

            put :move_favorites, { id: child.id, commit: "Submit" }, { user_id: @admin.id }

            CurrentUser.user = @admin
            assert_redirected_to(child)
            assert_equal(users, parent.reload.favorited_users)
            assert_equal([], child.reload.favorited_users)
          end
        end

        context "expunge action" do
          should "render" do
            put :expunge, { id: @post.id, format: "js" }, { user_id: @admin.id }

            assert_response :success
            assert_equal(false, ::Post.exists?(@post.id))
          end
        end

        context "confirm_ban action" do
          should "render" do
            get :confirm_ban, { id: @post.id }, { user_id: @admin.id }
            assert_response :success
          end
        end

        context "ban action" do
          should "render" do
            put :ban, { id: @post.id, commit: "Ban", format: "js" }, { user_id: @admin.id }

            assert_response :success
            assert_equal(true, @post.reload.is_banned?)
          end
        end

        context "unban action" do
          should "render" do
            @post.ban!
            put :unban, { id: @post.id, format: "js" }, { user_id: @admin.id }

            assert_redirected_to(@post)
            assert_equal(false, @post.reload.is_banned?)
          end
        end
      end
    end
  end
end
